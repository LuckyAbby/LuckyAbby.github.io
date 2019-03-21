---
title: "深入浅出Javascript事件循环机制(上)"
date: 2017-01-17T15:23:25+08:00
tags: ['事件循环','JS']
---
最近琢磨了好久的Javascript的事件循环机制，看了很多国内的博客总觉得写的还是不够深，很多都只说了Javascript的事件分为同步任务和异步任务，遇到同步任务就放在执行栈中执行，而碰到异步任务就放到任务队列之中，等到执行栈执行完毕之后再去执行任务队列之中的事件。自己对大概的基础有所了解之后也没接着深入去查资料，这就导致我在面试的时候被面试官一点一点深挖的时候就懵了(囧
## 函数调用栈与任务队列
Javascript有一个main thread 主进程和call-stack（一个调用堆栈），在对一个调用堆栈中的task处理的时候，其他的都要等着。当在执行过程中遇到一些类似于setTimeout等异步操作的时候，会交给浏览器的其他模块(以webkit为例，是webcore模块)进行处理，当到达setTimeout指定的延时执行的时间之后，**task(回调函数)会放入到任务队列之中**。一般不同的异步任务的回调函数会放入不同的任务队列之中。等到调用栈中所有task执行完毕之后，接着去执行任务队列之中的task(回调函数)。

用Philip Roberts的演讲[《Help, I'm stuck in an event-loop》](https://vimeo.com/96425312)之中的一张图表示就是

![](	https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A241.JPG)

在上图中，调用栈中遇到DOM操作、ajax请求以及setTimeout等WebAPIs的时候就会交给浏览器内核的其他模块进行处理，webkit内核在Javasctipt执行引擎之外，有一个重要的模块是webcore模块。对于图中WebAPIs提到的三种API，webcore分别提供了DOM Binding、network、timer模块来处理底层实现。等到这些模块处理完这些操作的时候将回调函数放入任务队列中，之后等栈中的task执行完之后再去执行任务队列之中的回调函数。

## 从setTimeout看事件循环机制
下面用Philip Roberts的演讲中的一个栗子来说明事件循环机制究竟是怎么执行setTimeout的。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A242.JPG)
首先main()函数的执行上下文入栈(对执行上下文还不了解的可以看我的上一篇博客)。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A243.png)
代码接着执行，遇到console.log('Hi'),此时log('Hi')入栈，console.log方法只是一个webkit内核支持的普通的方法，所以log('Hi')方法立即被执行。此时输出'Hi'。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A244.png)
当遇到setTimeout的时候，执行引擎将其添加到栈中。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A245.JPG)
调用栈发现setTimeout是之前提到的WebAPIs中的API，因此将其出栈之后将延时执行的函数交给浏览器的timer模块进行处理。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A246.png)
timer模块去处理延时执行的函数，此时执行引擎接着执行将log('SJS')添加到栈中，此时输出'SJS'。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A247.png)
当timer模块中延时方法规定的时间到了之后就将其放入到任务队列之中，此时调用栈中的task已经全部执行完毕。

![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A248.png)
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/%E5%8D%9A%E5%AE%A249.png)
调用栈中的task执行完毕之后，执行引擎会接着看执行任务队列中是否有需要执行的回调函数。这里的cb函数被执行引擎添加到调用栈中，接着执行里面的代码，输出'there'。等到执行结束之后再出栈。

## 小结
上面的这一个流程解释了当浏览器遇到setTimeout之后究竟是怎么执行的，相类似的还有前面图中提到的另外的API以及另外一些异步的操作。
总结上文说的，主要就是以下几点：
- 所有的代码都要通过函数调用栈中调用执行。
- 当遇到前文中提到的APIs的时候，会交给浏览器内核的其他模块进行处理。
- 任务队列中存放的是回调函数。
- 等到调用栈中的task执行完之后再回去执行任务队列之中的task。

## 测试
```
for (var i = 0; i < 5; i++) {
    setTimeout(function() {
      console.log(new Date, i);
    }, 1000);
}

console.log(new Date, i);
```
这段代码是我从网上前不久的一篇文章[80%应聘者都不及格的 JS 面试题](https://juejin.im/post/58cf180b0ce4630057d6727c)中找到的，现在我们就分析一下这段代码究竟是怎么输出最后文章中所说的最后的执行状态：
> 40% 的人会描述为：5 -> 5,5,5,5,5，即第 1 个 5 直接输出，1 秒之后，输出 5 个 5；

1. 首先i=0时，满足条件，执行栈执行循环体里面的代码，发现是setTimeout，将其出栈之后把延时执行的函数交给Timer模块进行处理。

2. 当i=1,2,3,4时，均满足条件，情况和i=0时相同，因此timer模块里面有5个相同的延时执行的函数。

3. 当i=5的时候，不满足条件，因此for循环结束,console.log(new Date, i)入栈，此时的i已经变成了5。因此输出5。

4. 此时1s已经过去，timer模块将5个回调函数按照注册的顺序返回给任务队列。

5. 执行引擎去执行任务队列中的函数，5个function依次入栈执行之后再出栈，此时的i已经变成了5。因此几乎同时输出5个5。

6. 因此等待的1s的时间其实只有输出第一个5之后需要等待1s，**这1s的时间是timer模块需要等到的规定的1s时间之后才将回调函数交给任务队列**。等执行栈执行完毕之后再去执行任务对列中的5个回调函数。这期间是不需要等待1s的。因此输出的状态就是：5 -> 5,5,5,5,5，即第1个 5 直接输出，1s之后，输出 5个5；

## 问题
看到这里，对事件循环机制有了一个大概的了解了，可是细想，其中还有一些另外值得深入的问题。
下面通过一个栗子来说明：
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
在这段代码里面，多了一个promise，那么我们可以思考下面这个问题：
1. promise的task会放在不同的任务队列里面，那么setTimeout的任务队列和promise的任务队列的执行顺序又是怎么的呢？

2. 到这里大家看了我说了这么多的task,那么上文中一直提到的task究竟包括了什么？具体是怎么分的？

如果到这里大家还是没太懂的话，那么接下来我会接着深入再细说不同task的事件循环机制。

当然，以上都是我自己鄙陋的见解，欢迎大家批评指正。

参考资料：
[JavaScript定时器的工作原理](http://ejohn.org/blog/how-javascript-timers-work/)
[《Help, I'm stuck in an event-loop》](https://vimeo.com/96425312)
[【转向Javascript系列】从setTimeout说事件循环模型](http://www.alloyteam.com/2015/10/turning-to-javascript-series-from-settimeout-said-the-event-loop-model/)
[JavaScript 运行机制详解：再谈Event Loop](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)