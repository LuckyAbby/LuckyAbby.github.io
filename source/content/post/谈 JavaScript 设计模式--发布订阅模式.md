---
title: "谈 JavaScript 设计模式--发布订阅模式"
date: 2017-08-23T15:23:25+08:00
---
发布订阅模式又称观察者模式，在现实生活中运用的十分常见。

比如某次你去商场看上了一件漂亮裙子，可是这件裙子没有你的号了，店员和你说可以先登记，等来货了会通知你。这个时候，你只需要在小本本上写下自己需要的裙子以及如果裙子到了需要进行的后续操作，可能是打电话通知你，也可能是给你送过来。这就是订阅的过程。

而如果这个店家知道观察者模式的话，他关心的只是登记的每件衣服，以及后面的注册的全部回调函数。因为可能人和你眼光一样好，登记了同一件衣服，但是注册了不同的回调函数。当每件衣服到了之后，店家只要对外宣布衣服到了，然后执行这件衣服注册的回调函数。这就是发布的过程。

我们将上面的过程抽象一下，对于发布订阅模式可以抽象出下面三步。

1.需要指定谁是发布者。

2.记录下来每个独一无二的发布项以及每个发布项的回调函数。

3.发布消息的时候，会对每个发布项的回调函数进行遍历执行。

说到这里，其实我们常用的事件也是一种发布订阅模式，比如

```
document.body.addEventListener( 'click', function(){ alert("我被点击了");
}, false );

document.body.click(); //模拟body点击
```

我们在 body 上面注册一个点击事件，当点击之后会有一个回调函数执行。这就是订阅的过程。当 body 被点击之后就会向外面发布‘我被点击了’，这个时候就会去执行点击这个发布项后面所有注册的回调函数。

说了这么大一堆，用代码实现的过程就是：

```
var event = {
  list: [], //存放每一个发布项和以及回调函数

  // 订阅
  subscribe: function(type, func) {
    if (!this.list[type]) {
	  this.list[type] = [];
    } else {
	  this.list[type].push(func);
    }
},

// 发布
  publish: function() {
    var type = Array.prototype.shift.call(arguments);
    var funcs = this.list[type];
    if(!funcs || funcs.length === 0) {
	  return false;
    }
    for(var i = 0,func; func = funcs[i++]) {
	  func.apply(this, arguments);
    }
},

  unsubscribe: function(type, func) {
    var funcs = this.list[type];

    if(!funcs) { // 如果对应的发布项没有被订阅，直接返回
	  return false;
    }
    if(!func) { //如果未制定取消的函数，则默认取消整个发布项后面的回调函数
	  funcs && (funcs.length = 0);
    } else {
	  for( var l = funcs.length - 1; l >= 0; l--) { // 反向遍历函数
	    var _func = funcs[l];
		  if (_func === func) {
		    funcs.splice(1, 1);
          }
        }
    }
}
};
```

下面使用代码来测试

```
var store = {};
var installEvent = function( obj ){
  for ( var i in event ){
    obj[ i ] = event[ i ];
    }
}
installEvent(store);

store.subscribe('mini-skirt', fn1 = function() { // 小明订阅了这个超短裙
  console.log('请给我寄过来');
});

store.subscribe('one-piece-dress', fn2 = function() { // 小红订阅了连衣裙
  console.log('请通知我到货了');
});

store.unsubscribe('mini-skirt', fn1); // 删除小明的订阅

store.unsubscribe('one-piece-dress', fn2); // 删除了小红的订阅
```
