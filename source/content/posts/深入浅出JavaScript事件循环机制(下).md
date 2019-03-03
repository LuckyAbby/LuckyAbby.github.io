---
title: "深入浅出Javascript事件循环机制(下)"
date: 2017-01-18T15:23:25+08:00
tags: ['事件循环','JS']
---
在上一篇文章里面我大致介绍了JavaScript的事件循环机制，但是最后还留下了一段代码和几个问题。

那我们先从这段代码开始看哇。
<!-- more -->

```
(function test() {
    setTimeout(function() {console.log(4)}, 0);
    new Promise(function executor(resolve) {
        console.log(1);
        for( var i=0 ; i<10000 ; i++ ) {
            i == 9999 && resolve();
        }
        console.log(2);
    }).then(function() {
        console.log(5);
    });
    console.log(3);
})()
```
在这段代码里面，setTimeout和Promise都被称之为任务源，来自不同任务源的回调函数会被放进不同的任务队列里面。

setTimeout的回调函数被放进setTimeout的任务队列之中。而对于Promise,它的回调函数并不是传进去的executer函数，而是其异步执行的then方法里面的参数，被放进Promise的任务队列之中。也就是说Promise的第一个参数并不会被放进Promise的任务队列之中，而会在当前队列就执行。

其中setTimeout和Promise的任务队列叫做macro-task(宏任务)，当然如我们所想，还有micro-task(微任务)。

1.macro-task包括：script(整体代码), setTimeout, setInterval, setImmediate, I/O, UI rendering。

2.micro-task包括：process.nextTick, Promises, Object.observe, MutationObserver

其中上面的setImmediate和process.nextTick是Node.JS里面的API,浏览器里面并没有，这里就当举例，不必纠结具体是怎么实现的。

事件循环的顺序是从script开始第一次循环，随后全局上下文进入函数调用栈，碰到macro-task就将其交给处理它的模块处理完之后将回调函数放进macro-task的队列之中，碰到micro-task也是将其回调函数放进micro-task的队列之中。直到函数调用栈清空只剩全局执行上下文，然后开始执行所有的micro-task。当所有可执行的micro-task执行完毕之后。循环再次执行macro-task中的一个任务队列，执行完之后再执行所有的micro-task，就这样一直循环。

## 分析执行过程

以之前的栗子作为分析的对象，来分析事件循环机制究竟是怎么执行代码的
```
(function test() {
    setTimeout(function() {console.log(4)}, 0);
    new Promise(function executor(resolve) {
        console.log(1);
        for( var i=0 ; i<10000 ; i++ ) {
            i == 9999 && resolve();
        }
        console.log(2);
    }).then(function() {
        console.log(5);
    });
    console.log(3);
})()
```
**注意下面所有图中的setTimeout任务队和最后的函数调用栈中存放的都是setTimeout的回调函数，并不是整个setTimeout定时器。**

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A251.JPG)
1.首先，script任务源先执行，全局上下文入栈。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A252.JPG)
2.script任务源的代码在执行时遇到setTimeout,作为一个macro-task，将其回调函数放入自己的队列之中。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A253.JPG)
3.script任务源的代码在执行时遇到Promise实例。Promise构造函数中的第一个参数是在当前任务直接执行不会被放入队列之中，因此此时输出 1 。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A254.JPG)

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A255.JPG)
4.在for循环里面遇到resolve函数，函数入栈执行之后出栈，此时Promise的状态变成Fulfilled。代码接着执行遇到cosole.log(2),输出2。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A256.JPG)
5.接着执行，代码遇到then方法，其回调函数作为micro-task入栈，进入Promise的任务队列之中。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A257%E6%94%B9.JPG)
6.代码接着执行，此时遇到console.log(3),输出3。

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A258%E6%94%B9.JPG)

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A259.JPG)
7.输出3之后第一个宏任务script的代码执行完毕，这时候开始开始执行所有在队列之中的微任务。then的回调函数入栈执行完毕之后出栈，这时候输出5

![](http://ojzeprg7w.bkt.clouddn.com/%E5%8D%9A%E5%AE%A260.JPG)
8.这时候所有的micro-task执行完毕，第一轮循环结束。第二轮循环从setTimeout的任务队列开始，setTimeout的回调函数入栈执行完毕之后出栈，此时输出4。

## 总结

总的来说就是：
1. 不同的任务会放进不同的任务队列之中。

2. 先执行macro-task，等到函数调用栈清空之后再执行所有在队列之中的micro-task。

3. 等到所有micro-task执行完之后再从macro-task中的一个任务队列开始执行，就这样一直循环。

4. 当有多个macro-task(micro-task)队列时，事件循环的顺序是按上文macro-task(micro-task)的分类中书写的顺序执行的。

## 测试
说到这里，我们应该都明白了，下面是一个复杂的代码段(改自[深入核心，详解事件循环机制](http://www.jianshu.com/p/12b9f73c5a4f))，里面有混杂着的micro-task和macro-task，自己画图试试流程哇，然后再用node执行看看输出的顺序是否一致。

```
console.log('golb1');

setImmediate(function() {
    console.log('immediate1');
    process.nextTick(function() {
        console.log('immediate1_nextTick');
    })
    new Promise(function(resolve) {
        console.log('immediate1_promise');
        resolve();
    }).then(function() {
        console.log('immediate1_then')
    })
})

setTimeout(function() {
    console.log('timeout1');
    process.nextTick(function() {
        console.log('timeout1_nextTick');
    })
    new Promise(function(resolve) {
        console.log('timeout1_promise');
        resolve();
    }).then(function() {
        console.log('timeout1_then')
    })

    setTimeout(function() {
    	console.log('timeout1_timeout1');
    process.nextTick(function() {
        console.log('timeout1_timeout1_nextTick');
    })
    setImmediate(function() {
    	console.log('timeout1_setImmediate1');
    })
    });
})

new Promise(function(resolve) {
    console.log('glob1_promise');
    resolve();
}).then(function() {
    console.log('glob1_then')
})

process.nextTick(function() {
    console.log('glob1_nextTick');
})
```

以上就是我所理解的事件循环机制，有偏差之处烦请指正。欢迎大家来交流哇，嘻嘻嘻。

参考资料：

[Promise规范](https://promisesaplus.com/)

[Difference between microtask and macrotask within an event loop context](http://stackoverflow.com/questions/25915634/difference-between-microtask-and-macrotask-within-an-event-loop-context)

[深入核心，详解事件循环机制](http://www.jianshu.com/p/12b9f73c5a4f)

[从Promise来看JavaScript中的Event Loop、Tasks和Microtasks](https://github.com/creeperyang/blog/issues/21)
