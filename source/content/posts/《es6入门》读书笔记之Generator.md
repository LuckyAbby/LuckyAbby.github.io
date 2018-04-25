---
title: "《ES6入门》读书笔记之Generator"
date: 2017-08-29T15:23:25+08:00
tags: ['es6','JS']
---
Generator 函数有两个特征:1. function 和函数名之间有一个`*`号。2. 函数体内部使用 yield 表达式，定义不同的内部状态，表达函数暂停执行。

<!-- more -->

执行 Generator 函数会返回一个遍历器对象。这个遍历器函数可以使用 next 方法遍历 Generator 函数内部的每一个状态。比如：
```
function* helloWorldGenerator() {
  yield 'hello';
  yield 'world';
  return 'ending';
}

var hw = helloWorldGenerator();
```
Generator 函数的调用方法与普通函数相同，不同的是调用 Generator 函数后，该函数并不执行，返回的也不是函数运行结果，而是一个指向内部状态的指针对象，就是遍历器对象。接着调用遍历器对象的 next 方法，使指针移向下一个状态，即 下一个 yield 表达式。

## yield 表达式

yield 表达式表示暂停，调用 next 方法将内部指针移到该语句的时候才会执行，返回一个对象，它的 value 属性就是当前 yield 表达式的值，done属性的值是一个布尔值，如果是false，表示遍历还没有结束。

遍历器对象的 next 方法执行逻辑如下：

1.遇到yield表达式，暂停执行后面的操作，将 yield 后面的值当成表达式的值返回。

2.次调用 next 方法时，再继续往下执行，直到执行到下一个 yield 表达式。

3.如果没有再遇到新的 yield 表达式，就一直运行到函数结束，直到 return 语句为止，并将 return 语句后面的表达式的值，作为返回的对象的 value 属性值。

4.如果该函数没有 return 语句，则返回的对象的 value 属性值是 undefined。

#### 与 return 的异同

##### 相同

返回紧跟在语句后面的表达式的值

##### 区别

1. yield 会暂停操作，下一次继续从这个位置执行。但是 return 语句只能执行一次。但是 yield 可以执行多次返回多个值，因为有多个 yield 。

2. yield 表达式只能在 Generator 函数里面使用，在其余地方使用会报错。

## next 方法的参数

yield 表达式本身返回 undefined 。next 方法的参数会被当成上一个 yield 表达式的的返回值。
使用 阮老师的例子：
```
function* foo(x) {
  var y = 2 * (yield (x + 1));
  var z = yield (y / 3);
  return (x + y + z);
}

var a = foo(5);
a.next() // Object{value:6, done:false}
a.next() // Object{value:NaN, done:false}
a.next() // Object{value:NaN, done:true}

var b = foo(5);
b.next() // { value:6, done:false }
b.next(12) // { value:8, done:false }
b.next(13) // { value:42, done:true }

```
next 不带参数的时候，yield(x+1) 返回 undefined，因此第二个打印出 NaN，对第三个同理。

当 next 带参数的时候，yield (x + 1) 的值就是参数 12，因此 yield (y / 3) 的值就是8。第三个的计算方法同理。

注意，第一个 next 一般是不带参数的，只表示启动遍历器。

## for of 循环

for...of循环可以自动遍历 Generator 函数时生成的Iterator对象，且此时不再需要调用next方法。

例如：
```
function *fn() {
	yield 'a';
	yield 'b';
	yield 'c';
	return 'd';
}
for(let i of fn()) {
	console.log(i);
}
// 'a' 'b' 'c'
```
注意这里不会返回 'd'，因为一旦 next 方法的返回对象的 done 属性是 true ,for of循环就会中止，并且不会包含这个返回对象。

对于原生的数组是具有内部的 Iterator 接口的，但是原生的对象没有。通常将 Generator 函数加到对象的Symbol.iterator属性上面即可。

## yeild* 表达式

在一个 Generator 函数里面执行另一个 Generator 函数。

看一个例子：
```
function* inner() {
  yield 'hello!';
}

function* outer1() {
  yield 'open';
  yield inner();
  yield 'close';
}

var gen = outer1()
gen.next().value // "open"
gen.next().value // 返回一个遍历器对象
gen.next().value // "close"

function* outer2() {
  yield 'open'
  yield* inner()
  yield 'close'
}

var gen = outer2()
gen.next().value // "open"
gen.next().value // "hello!"
gen.next().value // "close"
```
上面例子中，outer2使用了yield*，outer1没使用。结果就是，outer1返回一个遍历器对象，outer2返回该遍历器对象的内部值。

```
function* gen(){
  yield* ["a", "b", "c"];
}

gen().next() // { value:"a", done:false }

上面代码中，yield命令后面如果不加星号，返回的是整个数组，加了星号就表示返回的是数组的遍历器对象。
```
yield* 可以很方便地用来遍历嵌套数组的成员，不仅是数组，很多嵌套的解构都可以很方便取出来。
```
function* iterTree(tree) {
  if (Array.isArray(tree)) {
    for(let i=0; i < tree.length; i++) {
      yield* iterTree(tree[i]);
    }
  } else {
    yield tree;
  }
}

const tree = [ 'a', ['b', 'c'], ['d', 'e'] ];

for(let x of iterTree(tree)) {
  console.log(x);
}
// a
// b
// c
// d
// e

```
