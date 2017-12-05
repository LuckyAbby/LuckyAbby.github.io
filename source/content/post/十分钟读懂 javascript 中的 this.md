---
title: "十分钟读懂 javascript 中的 this"
date: 2017-04-06T19:22:25+08:00
tags: ['JS']
---
最近刚熬过了一大波考试和大作业，半个月没更文还有点心生愧疚Orz。今天就总结一下 JS 里面的 this，之前面试的时候也被面试官问到过，自己下来就整理了一下。

<!--more-->

在我之前的一篇文章[你不知道的执行上下文](http://luckyabby.com/2017/03/27/%E4%BD%A0%E4%B8%8D%E7%9F%A5%E9%81%93%E7%9A%84%E6%89%A7%E8%A1%8C%E4%B8%8A%E4%B8%8B%E6%96%87/)中有提到过 this，对那篇文章进行概括就是：
1. 上下文是在函数调用的时候被创建的。
2. this 是组成上下文的一部分。

因此每次函数被调用的时候就会产生一个新的 this。具体的分为下面几种。

## 1. 作为普通函数被调用

在全局环境里面，this 永远指向 window，因此作为普通函数被调用的时候，this 也是指向 window。
```javascript
var name = 'Abby';
function fn() {
    console.log(this); //window
    console.log(this.name); //Abby
}

fn();
```
这里，fn 其实是作为 window 的一个方法被调用的，而 name 也是 window 的一个属性，因此 fn() 实际上就是 window.fn()。


## 2. 作为对象的属性被调用

如果函数作为一个对象的属性方法，并且被调用的时候，this 就指向这个对象。

```javascript
var name = 'Jane';
var person = {
	name: 'Abby',
	sayName: function() {
		console.log(this.name);
	}
};
var sayNameWin = person.sayName;

person.sayName(); //Abby
sayNameWin(); //Jane   作为 window 的方法被调用的
```
在这里，sayName 方法是作为 person 的一个属性方法被调用的，因此指向 person，但是 sayNameWin 方法却是作为 window 的一个属性方法被调用的，因此 console.log 的值是 Jane。我们再看一个变形。

```javascript
var person1 = {
	name: 'Jane',
	sayName: function() {
		console.log(this.name)
	}
}

var person2 = {
	name: 'Abby',
	sayName: person1.sayName
}

person2.sayName(); //Abby  作为 person2 的属性方法被调用
```

**但是当在在对象方法中再定义函数，这时候 this 又是 window **。

```javascript
var name = 'Jane';
var person = {
    name: 'Abby',
    sayName: function () {
        function fn(){
            console.log(this);      //window
            console.log(this.name);    //Jane
        }
        fn();
    }
}
person.sayName();
```

如果想让 this 指向 person 的话，只需要用 that 保存下来 this 的值即可，也可以使用 apply 等改变 this。

```javascript
var name = 'Jane';
var person = {
    name: 'Abby',
    sayName: function () {
    	var that = this;
        function fn(){
            console.log(that);      //Object {name: "Abby"}
            console.log(that.name);    //Abby
        }
        fn();
    }
}

person.sayName();
```


## 3. 作为构造函数被调用

作为构造函数被调用的时候，this 代表它即将 new 出来的对象。

```javascript
function Person(name) {
	this.name = name;
	console.log(this);  //Person {name: "Abby"}
}

var person = new Person('Abby');
console.log(person.name);  //Abby
```

如果不加 new,表示即作为普通函数调用，指向 window

```javascript
function Person(name) {
	this.name = name;
	console.log(this);  //window
}

Person('Jane');
console.log(window.name); //Jane
```


## 4. 作为 call/apply/bind 方法的调用

作为 call/apply/bind 方法被调用的时候指向传入的值
```javascript
var person = {
	name: 'Abby'
};
function fn() {
	console.log(this); //Object {name: "Abby"}
	console.log(this.name); //Abby
}

fn.apply(person);
```

## 5. 严格模式下面
在严格模式下，在全局环境中执行函数调用的时候 this 并不会指向 window 而是会指向 undefined

```javascript
'use strict';
function person() {
  console.log(this); //undefined
};

person();

```


## 6. setTimeout、setInterval中的this
《 javascript 高级程序设计》中写到：“超时调用的代码需要调用 window 对象的 setTimeout方法”。setTimeout/setInterval 执行的时候，this 默认指向 window 对象，除非手动改变 this 的指向。
```javascript
var name = 'Jane';
function Person(){
    this.name = 'Abby';
    this.sayName=function(){
    	console.log(this); //window
        console.log(this.name); //Jane
        };
    setTimeout(this.sayName, 10);
    }

var person=new Person();
```

在这里如果想改变 this，可是使用 apply/call/bind 等，也可以使用 that 保存 this。
**setTimeout 中的回调函数在严格模式下也指向 window 而不是 undefined (是个坑)**
因为 setTimeout 的回调函数如果没有指定的 this ，会做一个隐式的操作，将全局上下文注入进去，不管是在严格还是非严格模式下。
```javascript
'use strict';

function person() {
  console.log(this);  //window
}

setTimeout(person, 0);

```

## 7. 构造函数 prototype 属性
```javascript
var name = 'Jane';
function Person(){
    this.name = 'Abby';
}
Person.prototype.sayName = function () {
    console.log(this);        // Person {name: "Abby"}
    console.log(this.name);      // Abby
}
var person = new Person();
person.sayName();
```

在 Person.prototype.sayName 函数中，this 指向的 person 对象。即便是在整个原型链中,this 也代表当前对象的值。


## 8. Eval函数

在 Eval 中，this 指向当前作用域的对象。

```javascript
var name = 'Jane';
var person = {
    name: 'Abby',
    getName: function(){
        eval("console.log(this.name)");
    }
}
person.getName();  //Abby

var getNameWin=person.getName;
getNameWin();  //Jane
```

在这里，和不使用 Eval ，作为对象的方法调用的时候得出的结果是一样的。

## 9. 箭头函数

箭头函数里面 this 始终指向外部对象，因为箭头函数没有 this，因此它自身不能进行new实例化，同时也不能使用 call, apply, bind 等方法来改变 this 的指向。

```javascript
var person = {
    name: 'Abby',
    sayName: function() {
        var fn = () => {
            return () => {
                console.log(this);   //Object {name: "Abby"}
                console.log(this.name); //Abby
            }
        }
        fn()();
    }
}
person.sayName();
```

如果有不恰当之处，欢迎指出。

参考资料：

[深入理解javascript原型和闭包（10）——this](http://www.cnblogs.com/wangfupeng1988/p/3988422.html)

[深入浅出 JavaScript 中的 this](https://www.ibm.com/developerworks/cn/web/1207_wangqf_jsthis/index.html)

http://www.cnblogs.com/justany/archive/2012/11/01/the_keyword_this_in_javascript.html
