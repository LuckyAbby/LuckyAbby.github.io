---
title: "《es6入门》读书笔记之let const"
date: 2017-08-28T15:23:25+08:00
---
## let const 与 var

let 与 const 创建了块级作用域。

#### 为什么要有块级作用域

我觉得这也是 ES5 中还没有完善的地方之一，没有块级作用域会导致一大堆问题。比如：控制计数的循环变量会泄漏成全局变量，在使用块级作用域的比如 if 语句以及 for while 循环等地方都会导致问题出现。

<!--more-->

与 var 最具体的区别在于：

#### 1. 不存在变量提升

var 命令会发生变量提升的现象，即变量可以放在声明之前使用，值是 undefined。 而在 let const 中，变量只有声明之后才可以使用，在声明之前是不存在的，如果在声明之前使用会报错。

#### 2. 暂时性死区

在一个块级作用域内，使用 let const 声明的变量在声明之前是不能获取的，使用阮老师的例子就是
```
if (true) {
  // TDZ开始
  tmp = 'abc'; // ReferenceError
  console.log(tmp); // ReferenceError

  let tmp; // TDZ结束
  console.log(tmp); // undefined

  tmp = 123;
  console.log(tmp); // 123
}
```
在使用 let const 声明 tmp 之前，都属于 变量的tmp 的“死区”。

#### 3. 不允许重复声明

```
let a = 1;
var a = 2; // error: 'a' has already been declared
```

#### 4. 全局变量不属于顶层变量

js 里面的顶层变量，在浏览器里面是 window ，在 Node.js 里面是 global， 在 ES5 使用 var 声明的变量会自动挂载在顶层变量上面，但是使用 let const 声明的变量不会挂载在顶层变量上。

```
var d = 1;
console.log(window.d); // 1

let g = 1;
console.log(window.g); // undefined
```

### let 与 const 的区别

let可以先声明再赋值，但是 const在声明的时候就需要赋值。

使用 let 定义的是一个变量，在后面还可以改变这个变量的值，但是使用 const 创建的是一个常量的，但是要弄懂这个常量的本质。

在 js 里面，如果是基本数据类型，存放的就是就是这个变量的值。但是对于引用数据类型，比如 数据对象等等，存放的是它的地址，因此下面的一些操作是合法的。

```
const foo = {};

// 为 foo 添加一个属性，可以成功
foo.prop = 123;
foo.prop // 123

// 将 foo 指向另一个对象，就会报错
foo = {}; // TypeError: "foo" is read-only
```

如果想把对象冻结，可以使用 Object.freeze 方法。
将对象和对象的属性冻结。
```
var constantize = (obj) => {
  Object.freeze(obj);
  Object.keys(obj).forEach( (key, i) => {
    if ( typeof obj[key] === 'object' ) {
      constantize( obj[key] );
    }
  });
````
