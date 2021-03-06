+++
title = "我还是想谈谈JS里面的闭包"
date = 2017-12-08T16:11:59+08:00
tags = ["JS", "闭包"]
categories = [""]
draft = false
+++
其实自己不太写闭包了的，就那么一两句话谁都能背出来。可是闭包偏偏就是那种初学者十次面试八次可能会遇到，答不上来就是送命题、答得出来也不加分题。为了不让我们前端开发从入门到放弃，我还是来谈谈我认为的 JS 里面的闭包。

## 闭包是什么

闭包创建一个词法作用域，这个作用域里面的变量被引用之后可以在这个词法作用域外面被自由访问，是一个函数和声明该函数的词法环境的组合

还有一种说法，闭包就是引用了自由变量的函数，这个自由变量与函数一同存在，即使脱离了创建它的环境。所以你常看到的说闭包就是绑定了上下文环境的函数，也大概是这个意思。只要想明白了，就觉得其实是很简单的一个东西，并没有多么高深。

在下面的介绍中，我还是比较偏向闭包是一个函数和声明该函数的词法环境的组合这种解释，所以也会基于这种解释去阐述。

闭包其实是计算机科学里面的一个概念，并不是JS里面独有的。闭包的概念出现于60年代，最早实现闭包的程序语言是Scheme。(别问我 Scheme 是什么，问了我也不知道，这段是从维基上抄的。)之后，闭包被广泛使用于函数式编程语言。

### JS里面的闭包

现在，我就发大绝招了，徒手撸一个闭包。

```js
function sayHello(name) {
  let str = `Hello,${name}`;
  function say() {
    console.log(str);
  }
  return say;
}

let myHello = sayHello('abby');
myHello(); // Hello,abby
```

上面这段代码，其实就形成了一个闭包，其中在 sayHello 这个函数里面定义的函数 say 和其声明它的词法环境就形成了一个闭包，因为它引用了sayHello 里面定义的一个变量 str，并且将 say 这个函数 return 了出去，这样在 sayHello 这个函数的外面也能访问它里面定义的变量 str，就好像 say 这个函数和这个变量绑定了一样。

看到这里可能会疑问为什么在外部还能访问到这个变量呢，因为在有些语言中，一般认为函数的局部变量只在函数的执行期间可访问。说到这里又不得不说到执行环境，不太了解的朋友可能先去看我这篇文章：[你不知道的执行上下文](http://luckyabby.com/post/%E4%BD%A0%E4%B8%8D%E7%9F%A5%E9%81%93%E7%9A%84%E6%89%A7%E8%A1%8C%E4%B8%8A%E4%B8%8B%E6%96%87/)。其实当执行到`let myHello = sayHello('abby');`这段代码的时候按理会销毁掉 sayHello()的执行环境，但是这里却没有，原因是因为 sayHello() 返回的是一个函数，这个函数里面的 str 引用了外部的变量 str,如果销毁了就找不到了，因此 sayHello() 这个函数的执行环境会一直在内存中，所以会有闭包会增加内存开销balabala之类的。

其实说到这里，闭包就应该是说完了的。。。但是毕竟是话很多的小仙女嘛，我们再来看几个例子，巩固一下。

### 举个栗子

#### 栗子1: 闭包并不是一定需要 return 某个函数

虽然常见的闭包都是 return 出来一个函数，但是闭包并不一定非要 return，return 出一个函数只是为了能在作用域范围之外访问一个变量，我们用另一种方式也能做到，比如：
```js
let say;
function sayHello(name) {
  let str = `Hello,${name}`;
  say = function() {
    console.log(str);
  }
}
let myHello = sayHello('abby');
say(); // Hello,abby
```
在这个例子里面，say和声明它的词法环境其实也形成了一个闭包，在它的作用域里面持有了 sayHello 这个函数里面定义的 str 变量的引用，因此也能在 str 变量定义的作用域之外访问它。只要弄清楚闭包的本质即可。

但是在 JS 里面，最常用的形成闭包的方式便是在一个函数里面嵌套另一个函数，另一个函数持有父作用域里面定义的变量。

#### 栗子2: 同一个调用函数生成同一个闭包环境，在里面声明的所有函数同时具有这个环境里面自由变量的引用。

这句话说起来很绕，其实我给个很简单的例子就可以了。
```js
let get, up, down
function setUp() {
  let number = 20
  get = function() {
    console.log(number);
  }
  up = function() {
    number += 3
  }
  down = function() {
    number -=2;
  }
}
setUp();
get(); // 20
up();
down();
get(); // 21
```
在这个例子里面，我们用setUp这个函数生成了一个闭包环境，在这个环境里面的三个函数共享了这个环境里面的 number 变量的引用，因此都可以对 number 进行操作。

#### 栗子3: 每一个调用函数都会创建不同的闭包环境。

还是给一个很简单的例子。
```js
function newClosure() {
  let array = [1, 2];
  return function(num) {
    array.push(num);
    console.log(`array:${array}`);
  }
}
let myClosure = newClosure();
let yourClosure = newClosure();
myClosure(3); // array:1,2,3
yourClosure(4); // array:1,2,4
myClosure(5); // array:1,2,3,5
```
上面这个例子里面， myClosure 和 yourClosure 的赋值语句，也就是 newClosure 这个函数被调用了两次，因此创建了两个不同的闭包环境，因此里面的变量是互不影响的。

#### 栗子4: 在循环里面创建闭包
在 let 被引入之前，一个常见的错误就是在循环中创建闭包，例如：
```js
function newClosure() {
  for(var i = 0; i < 5; i++) {
    setTimeout(function() {
      console.log(i);
      })
  }
}
newClosure(); // 5个5
```
打印的结果大家也知道是5个5，因为 setTimeout 里面的函数保持对 i 的引用，在setTimeout的回调函数被执行的时候这个循环早已经执行完成，这里我之前在另一篇文章里面做过更深入的介绍：[深入浅出Javascript事件循环机制(上)](http://luckyabby.com/post/%E6%B7%B1%E5%85%A5%E6%B5%85%E5%87%BAjavascript%E4%BA%8B%E4%BB%B6%E5%BE%AA%E7%8E%AF%E6%9C%BA%E5%88%B6%E4%B8%8A/)。

这里我要说的是我们如何才能得到我们想要的01234,在这里有两种做法。

一种是 **创建一个新的闭包对象，这样每个闭包对象里面的变量就互不影响**。例如下面的代码种每次 log(i)都会创建不同的闭包对象，所有的回调函数不会指向同一个环境。
```js
function log(i) {
  return function() {
    console.log(i);
  }
}

function newClosure() {
  for(var i = 0; i < 5; i++) {
    setTimeout(log(i));
  }
}
newClosure(); // 0 1 2 3 4
```

另一种做法就是使用自执行函数，外部的匿名函数会立即执行，并把 i 作为它的参数，此时函数内 e 变量就拥有了 i 的一个拷贝。当传递给 setTimeout 的匿名函数执行时，它就拥有了对 e 的引用，而这个值是不会被循环改变的。写法如下：
```js
function newClosure() {
  for(var i = 0; i < 5; i++) {
    (function(e) {
      setTimeout(function() {
        console.log(e);
      })
    })(i)  
  }
}
newClosure(); // 0 1 2 3 4
```
看看，写这么多，多累是不是，还是let省事，所以赶紧拥抱 es6 吧。。。

好了，这次是真的结束了，我所理解的闭包大概就是这样了，如果理解有所偏差，欢迎指出，谁当初不是从颗白菜做起的呢

如果看完之后还是很懵的话，那就找个有阳光的午后，在窗边沏一杯西湖龙井，然后再把这篇文章和下面的参考链接看个千百遍。。如果都看了，还是实在理解不了的话：

**非官方劝退：前端开发，从入门到放弃**

参考链接：

[闭包](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Closures)

[闭包的概念、形式与应用](https://www.ibm.com/developerworks/cn/linux/l-cn-closure/)

[闭包](https://zh.wikipedia.org/w/index.php?title=%E9%97%AD%E5%8C%85_%28%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6%29&variant=zh-cn)

[闭包和引用](http://bonsaiden.github.io/JavaScript-Garden/zh/#function.closures)

[深入理解javascript原型和闭包（15）——闭包](http://www.cnblogs.com/wangfupeng1988/p/3994065.html)

[how do javascript closures work](https://stackoverflow.com/questions/111102/how-do-javascript-closures-work)
