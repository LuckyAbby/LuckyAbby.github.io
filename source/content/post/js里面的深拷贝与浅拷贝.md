---
title: "js里面的深拷贝与浅拷贝"
date: 2017-07-18T15:23:25+08:00
---

### 为什么会有浅拷贝与深拷贝

在说浅拷贝与深拷贝的时候先说说为什么会有浅拷贝与深拷贝。在js里面，变量分为基本类型与引用类型。对于基本类型，基本类型是简单的数据段，但是引用类型是指那样可能由多个值构成的对象等。深拷贝主要是由引用类型的复制引起的。

#### 基本类型
基本类型只有 Undefined Null Boolean Number String 这五种，基本类型的值存放在栈内存中，可以直接访问，当进行复制的时候，是重新开辟一块内存存放一个相同的值，这两个值相同但是是完全独立的，之后任何操作都是互不影响的。

#### 引用类型
引用类型在js中指的是对象和数组等等，引用类型的值是存放在堆内存中，但是不需要直接操作变量在堆内存中的位置，因此在栈内存中存放了引用类型的地址，因此对栈内存的值的操作其实是对堆内存的一个引用的操作，因此复制的时候也是复制一个地址过去，真实操作的时候还是对堆内存数据的操作。

正是因为引用类型的值在栈内存中存放的只是一个地址，这个时候如果只是复制这个地址过去，操作新复制变量的时候还会对原来的变量值产生影响，这就是浅拷贝（shallow copy）的弊端，这些情况有时会让代码变得很混乱。

### 如何实现浅拷贝与深拷贝

浅拷贝就是只将值复制过去，如果是基本类型直接复制，如果是引用类型也是将地址复制过去，因此对于引用类型的变量还会操作同一块数据。

深拷贝就是递归地复制，直到最后一层是基本类型，因此深拷贝对基本类型直接复制，对于引用类型是递归复制，直到把最后一层的基本类型值复制过去，这样就完全成为两个变量值，之后不会再互相影响。

**深浅拷贝最主要的区别只针对引用类型，不针对基本类型**

#### 实现浅拷贝

##### 直接赋值
最典型的浅拷贝就是直接赋值，例如：
```
let object1 ={a:1,b:2};
let object2 = object1;
object2.a = 3;
console.log(object1.a); // 3
```
在上面对 object2 进行操作的时候也会改变原来 object1 的值。

##### Array.prototype.concat 与 Array.prototype.slice
MDN对于concat的描述：
> concat 方法并不修改调用它的对象(this 指向的对象) 和参数中的各个数组本身的值,而是将他们的每个元素拷贝一份放在组合成的新数组中.原数组中的元素有两种被拷贝的方式:
对象引用(非对象直接量):concat 方法会复制对象引用放到组合的新数组里,原数组和新数组中的对象引用都指向同一个实际的对象,所以,当实际的对象被修改时,两个数组也同时会被修改.
字符串和数字(是原始值,而不是包装原始值的 String 和 Number 对象): concat 方法会复制字符串和数字的值放到新数组里.

对于slice的描述也如上，这两个方法都是浅复制，对于引用类型都只是复制了一份地址。
具体见下例：
```
let arr = [1, {a: 2, b: 3}];
let arrConcat = arr.concat();
var arrSlice = arr.slice(0);
arrSlice[1].a = 4;
console.log(arr); //[1, {a: 4, b: 3}]
console.log(arrSlice); //[1, {a: 4, b: 3}]
```
由此可见，这两个方法还是操作的是堆内存中的同一块区域数值。

##### Object.assign
Object.assign() 方法用于将所有可枚举的属性的值从一个或多个源对象复制到目标对象。假设源对象中有属性是引用类型，那么也只会拷贝这个引用，也就是堆内存数据的地址。具体例子见下：
```
var obj = { a: 1, b: {c: 2, d: 3}};
var copy = Object.assign({}, obj);
copy.b.c = 4;
console.log(obj.b); //{c: 4, d: 3}
```
这里copy中的b属性是一个对象，操作这个对象也会引起obj中b属性的变化。

#### 如何实现深拷贝
##### JSON.parse与JSON.stringify
JSON.stringify()方法可以将一个JavaScript值转换为一个JSON字符串，相反，JSON.parse()方法解析一个JSON字符串，构造由字符串描述的JavaScript值或对象。
见下面的例子：
```
var obj = {a: 1, b: 2};
var copy = JSON.parse(JSON.stringify(obj));
copy.a = 3;
console.log(obj.a); //1
```
这种方法虽然能实现深拷贝，但是会丢弃对象的constructor,同时对于函数、正则表达式等等会无法拷贝。如下例:
```
var obj = {a: function() {}};
var copy = JSON.parse(JSON.stringify(obj));
console.log(copy.a); //undefined
```

#### 自己实现拷贝
```
function judgeClass(o) {
  return Object.prototype.toString.call(o).slice(8, -1)
}

function copy(obj, deep) {
  if (judgeClass(obj)!== 'Array' && judgeClass(obj)!=='Object'){
    return obj;
  } else {
      var name ,target = judgeClass(obj)==='Array' ? [] : {},value;
      for(name in obj) {
          value = obj[name];
          if(value === obj) {
              continue;
          }
          if(deep && (judgeClass(value)==='Array' || judgeClass(value)==='Object')) {
              target[name] = copy(deep, value);
          } else {
              target[name] = value;
          }
      }
      return target;
  }
}
```
上面是大致实现的一个拷贝，实现参考了[jQuery中`$_extend()` 方法](https://github.com/jquery/jquery/blob/1472290917f17af05e98007136096784f9051fab/src/core.js#L121)的实现,下面是测试的例子:
```
var oldValue = {name: 'abby', info:{age: 19, sex: '女'}};
var copyValue = copy(oldValue, true);
copyValue.info.age = 20;
console.log(oldValue.info.age); // 19
```
这种方法也有缺陷就是对于一些新增的对象无法实现深拷贝，比如新增的Int16Array等对象，这种方法还需要不断改进。
