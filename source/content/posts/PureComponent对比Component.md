---
title: "PureComponent对比Component"
date: 2019-02-08T00:35:19+08:00
tags: ['React','JS']
---

PureComponent 是 react15.3 中发布的一个新类，对比 Component 主要是改变了生命周期方法 shouldComponentUpdate，不需要自己再去写代码检测是否重新 render，它会自动检查组件当检测到state或者props发生变化时，PureComponent才会调用render方法，提升了性能，具体的实现就是 React 做了一个 shallowEqual：

```
if (this._compositeType === CompositeTypes.PureClass) {
  shouldUpdate = !shallowEqual(prevProps, nextProps)
  || !shallowEqual(inst.state, nextState);
}
```

而 shallowEqual 做的是一个浅对比，对于引用类型的值（数组、对象）只能判断两者的引用是否相等，不会去深层次的对比每一层，因此在使用 PureComponent 时也需要注意 state 的值可能发生了变化，但是组件未被重新渲染

也可以直接使用 shouldComponentUpdate 函数，如果存在的话，会直接使用 shouldComponentUpdate 结果来判断是否更新，如果没有的话才会考虑是否是 PureComponent而去使用 shallowEqual 浅比较

## PureComponent 使用

### 经常变化的 state 避免使用引用类型

如下面的代码，我们定义了一个父组件 Words 和子组件 WordsList，当父组件点击 button 的时候，子组件并没有重新渲染，原来是因为 shallowEqual 认为两次传入的 words 引用值是相等的，虽然此时新的 state已经增加了一项 abby

```
class WordsList extends React.PureComponent {
  render() {
    return <div>{this.props.words.join(',')}</div>;
  }
 }

class Words extends PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      words: ['hello']
    };
    this.handleClick = this.handleClick.bind(this);
  }
  }

handleClick() {
  const words = this.state.words;
  words.push('abby');
  this.setState({ words });
}


  render() {
    return (
      <div>
        <button onClick={this.handleClick} />
        <WordsList words={this.state.words} />
      </div>
    )
  }
}
```

 为了解决上面的问题，只需要将每次返回一个全新的对象即可，例如使用 concat 来返回一个全新的数组，此时 shallowEqual 会判断新传入的 state 是不同的

 ```
handleClick() {
  this.setState(prevState => ({
    words: prevState.words.concat(['abby'])
  }));
}
 ```

可以考虑使用[Immutable.js](https://facebook.github.io/immutable-js/)来创建不可变对象，从而避免了引用的问题。

 ### 避免使用空数组和空对象

 很多时候，后端传回的数据如果为空的话会给一个 null，前端这个时候做处理一般是如下；

 ```
render() {
    return (
      <div>
        <button onClick={this.handleClick} />
        <WordsList words={this.state.words} || [] />
      </div>
    )
  }
 ```

这样就会导致如果数据每次都是 null 的话，也会导致组件重新渲染，因为 []
=== [] 是 false 的，为了避免这种情况，应该使用 defaultValue， 事先设置好 defaultValue = []，这样就不会出现为 null 重新渲染的情况。

### 函数避免直接使用 this.props

父组件像子组件传一个函数的时候，一般会使用

```
<WordInput onChange={e => this.props.update(e.target.value)} />
```

每次 render 的时候都会返回一个新的 onChange 函数，因为函数引用不一样会导致 WordInput 重新渲染，所以要避免这种写法，可以在 constructor 的时候使用 bind，或者直接使用箭头函数。
```
constructor(props) {
    super(props)
    this.update = this.update.bind(this)
}
update(e) {
    this.props.update(e.target.value)
}
render() {
    return <WordInput onChange={this.update} />
}

//或者

update = (e) => {
  this.props.update(e.target.value)
}
render() {
  return < WordInput onChange={this.update} />
}
```

尽量将 PureComponent 作为展示型组件，因为 PureComponent 判断是否重新渲染的时候还会影响到它的子元素，所以使用展示型组件可以避免一些子元素渲染问题。

## Stateless Functional Component 对比 Component

Stateless Functional Component 其实只是 Component 的另一种纯函数的写法，例如：

```
function Hello = (props) => {
  const hello = () => {
    console.log(`Hello, ${props.name}`);
  }

  return (
    <div>
      <button onClick ={hello}>Say Hello</button>
      <h1>Hello, {props.name}</h1>
    </div>
  )
}
```

Stateless Functional Component 组件的思想就是 Stateless，因此只有 porps 的值改变才会导致页面重新 render，因此在函数组件中，不能使用 state，因此也不能使用组件的生命周期方法，因此组件只能用来做展示型组件。组件接收 props, 渲染组件，无需关心页面交互。

函数组件编写前一定要考虑清楚，首先考虑的就是这个组件是否只是展示型组件，否则之后还是再改为类组件就会得不偿失。


## PureComponent 对比 Stateless Functional Component

### 区别

- PureComponent是有状态和生命周期的，只是在 shouldComponentUpdate 的时候帮忙做了一些判断使得组件性能更好一些，但是需要注意的是只是 shallowEqual，发挥作用更好的是用作展示型组件。

- Stateless Functional Component 是完全没有生命周期，只能用作展示型组件。
- Stateless Functional Component 不会生成组件的实例，但是类组件每次都会生成一个实例，因此 Stateless Functional Component 性能更优。