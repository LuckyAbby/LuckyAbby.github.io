---
title: "《ES6入门》读书笔记之async/await"
date: 2017-09-01T15:23:25+08:00
tags: ['es6','JS']
---
## async 函数

### async

async 函数主要用来处理异步，相比于 Generator 和 yield ，主要有下面几点优点：
<!--more-->

##### 1.内置执行器

async 函数的执行与普通函数一摸一样，只需要执行即可，不需要像 Generator 函数需要调用 next 方法。因此更加方便。

##### 2.返回 Promise 对象

调用 async 函数返回一个 Promise 对象，因此可以调用 then 方法。如果里面还有 return 语句将作为 then 方法的参数。而 Generator 返回的是 Interator 对象。

##### 3.语义更清楚

async 表示函数里面有异步操作， await 表示紧跟在后面的表达式需要等待结果。

async 需要主要下面几点：

##### 1.async 函数返回一个 Promise 对象，函数内部 return 语句返回的值是 then 方法回调函数的参数。

```
async function f() {
  return 'hello world';
}

f().then(v => console.log(v))
// "hello world"
```
##### 2.同时当 async 函数内部抛出错误的时候会使得 Promise 状态变成 reject。

```
async function f() {
  throw new Error('出错了');
}

f().then(
  v => console.log('right',v),
  e => console.log('wrong',e)
)
// wrong Error: 出错了
```

##### 3.必须等到 await 命令后面的 Promise 对象执行完，才会使得 async 返回的 Promise 对象的状态发生改变，才能调用 then 方法，除非遇到 return 语句或者抛出错误。

#### async 函数实现原理

async 函数就是将 Generator 函数和自动执行器包装在一个函数里。

```
async function fn(args) {
  // ...
}

// 等同于

function fn(args) {
  return spawn(function* () { //自动执行器
    // ...
  });
}
```

### await

##### 1.await 命令后面一般是一个 Promise 对象。如果不是，会被转成一个立即被 resolve 的 Promise 对象。如 await 12, 那么这个 12 会被传入 then 回调的参数。如果 Promise 对象的变成 reject 状态，参数会传给 catch。

##### 2.只要一个 await 后面的 Promise 状态是 reject，整个 async 函数中止执行。

##### 3.一般可以使用 try catch 去接收 reject ，也可以使用自带的 catch。

```
async function f() {
  await Promise.reject('出错了')
    .catch(e => console.log(e));
  return await Promise.resolve('hello world');
}

f()
.then(v => console.log(v))
// 出错了
// hello world
```
##### 4.如果 await 后面的异步操作出错，那么等同于async函数返回的 Promise 对象被reject，可以使用 try catch 对错误进行处理。

```
async function f() {
  try {
    await new Promise(function (resolve, reject) {
      throw new Error('出错了');
    });
  } catch(e) {
  }
  return await('hello world');
}
```

##### 5.如果多个 await 命令不存在继发关系，应该让它们同时触发。

```
let foo = await getFoo();
let bar = await getBar();
```

上面代码里面是两个互不依赖的独立异步操作，这样写会比较耗时，应该让他们同时发生。

```
let [foo, bar] = await Promise.all([getFoo(), getBar()]);
```
