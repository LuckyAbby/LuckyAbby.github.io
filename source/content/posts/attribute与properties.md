---
title: "attribute与properties"
date: 2019-03-12T23:23:35+08:00
tags: ['JS']
---

attribute 属于 html,一般翻译为 特性
properties 属于 DOM，翻译为属性，因为一个 html 元素就是一个 DOM 节点，而每个节点都是一个 JS 对象，因此具有属性，DOM元素属性和普通对象的属性一样，就是DOM对象这个javascript对象上的属性而已。

<!--more-->

### attribute

attribute 出现在 html 元素中，比如 id、class、type等。

例如

```html
<input type="text" id="myInput" a=111 A=2222 />
```

HTML 元素映射到 DOM 是 HTMLElement 类型的节点对象，HTMLElement 类型的节点对象有一个 attributes 属性，这个属性本身也是一个对象，HTML 元素的所有 attribute 都包含在这个对象里面。

HTMLElement 节点对象有几个方法可以操作 attribute。
```
elem.hasAttribute(name)  // 检查 attribute 是否存在
elem.getAttribute(name)  // 获得 attribute
elem.setAttribute(name, value)  // 设置 attribute 的值
elem.removeAttribute(name)  // 删除 attribute
```

我们打印出上面的 attributes 属性，得到的结果是：
```
NamedNodeMap {0: type, 1: id, 2: a, type: type, id: id, a: a, length: 3}
    0: type
    1: id
    2: a
    baseURI: "file:///Users/jh/index/html%20css%20test/attribute.html"
    childNodes: NodeList []
    firstChild: null
    isConnected: false
    lastChild: null
    localName: "a"
    name: "a"
    namespaceURI: null
    nextSibling: null
    nodeName: "a"
    nodeType: 2
    nodeValue: "111"
    ownerDocument: document
    ownerElement: input#myInput
    parentElement: null
    parentNode: null
    prefix: null
    previousSibling: null
    specified: true
    textContent: "111"
    value: "111"
    __proto__: Attr
    length: 3
```
可以看到只有三个值，定义的 A 并没有显示出来，因此可以归纳出有如下特点：

- 只能是字符串
- 大小写不敏感
- 以动态集合的方式存在（NamedNodeMap）


### properties
properties 是 DOM 节点对象的属性，因此可以直接通过 . 或者 []来获取值。具有如下特点：

- 可以是任何类型的值
- 大小写敏感
- js 中自定义的 properties 不会出现在 html 中

但是注意有些 attribute 是 JS 保留字比如 class attribute 转化为 properties 时是 className。

### dataset 属性

HTML 元素的每一个 公认的（非自定义的） attribute 映射为节点对象上一个个的 property，但是自定义的除了 attribute 通过  data- 自定义的可以通过 dataset 获取之外，别的都不可以获取。

因此对于通过  data-  自定义的 HTML attribute 可以有两种方法获取

```html
<input type="text" id="myInput" data-name="input" data-my-name="myInput"/>
```
- el.getAttribute('data-name')/el.getAttribute('data-my-name')
- el.dataset.name/el.dataset.myName

### 同步机制

- 对于自定义的 properties/Attribute不会同步，但是修改 dataset 会同步
- 对于非自定义的attribute，如id、class、title等，都会有对应的 property 映射，property 或 attribute 的变化多数是同步。

```js
<input type="text" id="myInput" class="myInputClass" />

var el = document.getElementById('myInput');

el.id = 'renamedId';
console.log('el.id', el.getAttribute('id')); //renamedId

el.setAttribute('class', 'renamedClass');
console.log('el.className', el.className); //renamedClass
```

带有默认值的 attribute 不会随 property 而变化，property 会随着变化。比如

```js
<input type="text" id="myInput" class="myInputClass" />
var el = document.getElementById('myInput');

el.setAttribute('value', 'AttrValue');
console.log('el.value', el.value); // AttrValue

el.value= 'proValue';
console.log('el.proValue', el.getAttribute('value'))// AttrValue
```

### 特殊值

有几种特殊的特性，通过getAttribute()返回的值和 properties 并不相同。如href，src，onclick等事件处理程序。比如下面href的例子,getAttribute会获取和 html 编写的值一样的值，而 href 返回来的是却不一样。

```js
 <a href="//m.taobao.com" id="link"></a>

var el = document.getElementById('link');

console.log('el.link', el.href); // file://m.taobao.com/
console.log('el.getAttribute', el.getAttribute('href'));// //m.taobao.com
```
