---
title: "实现CSS居中的多种方法 "
date: 2017-09-18T15:23:25+08:00
tags: ['居中布局','CSS']
---
居中在 CSS 中用的也比较常见，总结几种自己比较熟悉的居中的写法。当然，肯定还有更多更不错的写法，对于文中不足的地方也欢迎指正。

<!-- more -->

假设现在给出这种场景：
```html
<div class="parent">
  <div class="child">
    DEMO
  </div>
</div>
```
其中在 `class='child'` 这个 div 中的内容长度是不一定的，现在需要实现这个 div 的居中。

## 水平居中

### 1.1 display: inline-block
在块级父容器中让行内元素或者类行内元素居中，只需使用 text-align: center，
这种方法可以让 inline/inline-block/inline-table/inline/flex 居中。

```css
.child {
  display:inline-block;
  /*子元素文字会继承居中，因此要在上面写上向左边居中*/
  text-align:left;
}
.parent {
  text-align:center;
}
```


当有多个 child div 的时候如果设置 display: inline-block 的时候需要注意每个 div 之间会有缝隙，这不是什么 bug ，特性就是如此。。

如果想去掉这些缝隙的话，有几种解决方法：

1.去掉 HTML 中的空格。

元素之间留白间距出现的原因是因为标签段之间的空隙，这个时候只需要去除掉 HTML 之间的空隙就好了。
比如这种写法，当然写法也有很多种，只要保证把空隙去掉就可以了，但是这种方法总觉得写起来有点反人类。
```
<div class="parent">
  <div class="child">
  DEMO1</div
  ><div class="child">
  DEMO2</div
  ><div class="child">
  DEMO3</div>
</div>
```

2.使用 margin 负值

这种方法这个负的值不太好确定，和上下文的字体等等都有关，这种方法不太适合大规模的使用。
```
.child {
  margin-right; -5px;
}
```

3.使用 font-size: 0

这种方法能十分简单地这个间距问题，只需要将父 div 的 font-size 设为0 ，然后记得将子 div 的 font-size 属性设置回来即可。

```css
.parent {
  font-size: 0;
}

.chilc {
  font-size: 16px;
}
```
4.使用 letter-spacing 或者 word-spacing

```css
.parent {
  letter-spacing: -5px;
  /*或者*/
  word-spacing: -5px;
}

.chilc {
  letter-spacing: 0;
  /*或者*/
  word-spacing: 0;
}
```


### 1.2 display:table

`table` 元素的宽度也是跟着内容走，居中的时候加上 `margin` 即可。兼容IE8。

如果不设置成table,设置成别的块级元素也可以，但是要强调设置宽度width，不然会拉伸成父元素的宽度。(注意加上 width 这种方法拓展性不好，如果 child div 里面的内容很长的话可能超过设置的 width 的宽度)

```css
.child {
  display:table;
  margin:0 auto;
}
```
### 1.3 position: absolute

`absolute` 元素的宽度默认也是由内容决定

这种方法的优点是居中的元素不会对其他元素产生影响 脱离正常流

```css
.parent {
  position:relative;
}
.child{
  position:absolute; /*参照物是父容器*/
  left:50%;
  transform:translateX(-50%); /*百分比的参照物是自身*/
}
```

### 1.4 dispaly: flex

只兼容IE10+

```css
.parent {
  display:flex;
  justify-content:center;
}
/*或者*/
.child{
  margin：0 auto;
}
```

## 2.垂直居中

### 2.1 display: table-cell

可以使高度不同的元素都垂直居中

```css
.parent {
  display:table-cell;
  vertical-align:middle;
}
```

### 2.2 position: absolute

```css
.parent {
  position:relative;
}
.child{
  position:absolute;
  top:50%;   /* 参照物是父容器 */
  transform:translateY(-50%); /*百分比的参照物是自身 */
}
```

### 2.3 display: flex

只兼容IE10+

```css
.parent {
  display:flex;
  align-items:center;
}
/*或者*/
.child{
  margin：0 auto;
}
```
## 3.水平垂直居中

这种就只需要把前几种的结合起来就行了，主要有三种常见的方法。

### 3.1 inline-block text-align table-cell vertical-align

```css
.child {
  display:inline-block;
  text-align:left;
}

.parent {
  text-align:center;
  display:table-cell;
  vertical-align:middle;
}
/*子元素文字会继承居中，因此要在上面写上向左边居中*/
```

### 3.2 absolute + transform

```css
.parent {
  position:relative;
}
.child{
  position:absolute;
  left:50%;
  top:50%; /*参照物是父容器*/
  transform:translate(-50%,-50%); /*百分比的参照物是自身*/
}
```

### 3.3 flex + align-items + justify-content

```css
.parent {
  display:flex;
  justify-content:center;
  align-items:center;
}
```
