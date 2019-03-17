---
title: "CSS常见的浮动与清除浮动"
date: 2018-03-14T15:30:13+08:00
tags: ['浮动','CSS','清除浮动']
---

这篇博客自己之前好像是写过的。。后来换电脑之后博客静态文件备份好像丢了几篇博客(突然心痛)。最近又遇到这个问题，想着再写一遍就当温习一遍了。

浮动(float)属性指的是某个元素脱离正常流，沿着容器的左侧或者右侧进行排列，允许文本或者内联元素环绕它，类似于排版印刷里面的文本环绕。

### 浮动元素如何进行定位

如果一个元素被设置成浮动之后，它就会脱离正常流，向左或者向右平移，直到碰到它的边界碰到它的包含块的边界或者另一个浮动元素。由于浮动元素脱离了正常流，正常流里面的块级元素会表现得似乎它不存在一样。

例如下图中有三个 div, 按正常流的排列顺序，块级元素会单独占据一行。此时我们将 div2 设置成 `float: left`，之后可以看到 div3 占据了 div2 原本的位置，div2 因为脱离文档流浮动到最左侧，遮盖住了 div3 的一部分。

将 div2 设置成右浮动便会右移排列到最右侧。如下图：
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float11.jpg)

具体的表现如下图所示。
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float1.png)
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float2.png)
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float3.png) 

### 浮动带来的一些影响

以及拿上面的例子举例。我们给这三个 div 加上一个容器 div， 再将其设置一个 border, 会发现容器 div 并没有被撑起来，如下图：
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float-new-2.png)

代码如下：

```html
<div class="box">
  <div class="div1 item">1</div>
  <div class="div2 item">2</div>
  <div class="div3 item">3</div>
</div>
```

```css
.item {
  width: 100px;
  height: 100px;
  float: left;
}
.div1 {
  background-color: #333;
  height: 150px;
}
.div2 {
  background-color: yellow;
}
.div3 {
  background-color: #999;
  height: 150px;
}
.box {
  border: 1px solid black;
}
```
这是因为浮动的元素已经脱离原来的正常流，因此也并不占据位置，无法使容器的高度撑起来。此时就需要清除浮动。

### 清除浮动

#### 1.带 clear 标签的空 div

这也是常见的清除浮动的方法， clear 属性指定一个元素是否可以在它之前的浮动元素旁边。比如`clear: left`即是指不允许该元素出现在它之前的左浮动元素旁边。

到这个例子，我们只需要在容器 div 的末尾添加一个空 div，设置` clear: left`即可将这个 div 下移到所有左浮动的 div 的下面，这样容器 div 就能包含住所有的元素了。

代码：
```html
<div class="box">
  <div class="div1 item">1</div>
  <div class="div2 item">2</div>
  <div class="div3 item">3</div>
  <div class="clear"></div>
</div>
```
```css
.clear {
  clear: left;
}
```

清楚浮动之后的图片如下：
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/float-new-3.png)

#### 2.使用 ::after 伪元素

其实和第一中原理一样，只是第一中需要自己再创造一个空的无用的 div,这样会改变页面的结构，因此使用 ::after 来创造一个伪元素做为已选中元素的最后一个子元素。代码如下：
```html
<div class="box clearfix">
  <div class="div1 item">1</div>
  <div class="div2 item">2</div>
  <div class="div3 item">3</div>
</div>
```

```css
.clearfix::after{
  content: '';
  display: block;
  height: 0;
  clear: left;
}
```

#### 3.触发容器元素的BFC

BFC 即 Block Formatting Context(块格式化上下文), BFC 是Web页面的可视化CSS渲染的一部分，是布局过程中生成块级盒子的区域，也是浮动元素与其他元素的交互限定区域。简单来说，BFC 会使得元素成为一个隔离的独立元素，不会影响到外部。

触发 BFC 有下面几种方式：

- body 根元素
- 浮动元素：float除了none之外
- 用position绝对定位的元素，以及fixed固定定位的元素
- display: inline-block、table、table-cell、table-caption等
- overflow：除了visiable

这里我们可以将触发容器 div 的 BFC，这个时候浮动元素就只能在这个容器里面了，不能影响外面的布局。因此常见的我们可以给容器元素设置 `overflow:hidden` 触发 BFC，还有另一些触发 BFC 的方法，比如给容器设置`float: left`也可以做到，但是会影响页面之后的布局，还有例如设置`display: table`等等也可以做到。

BFC 常见的好玩的除了可以用来清除浮动之外，还可以用来处理外边距折叠，比如在一个 BFC 下面的两个兄弟块级元素会发生外边距折叠，详情可见之前的文章[外边距折叠——磨人的小妖精](https://github.com/LuckyAbby/LuckyAbby.github.io/issues/2)。还可以用来做两栏布局，将左侧的元素设置成浮动，右侧的元素则可以使用`overflow:hidden`触发一个 BFC这样就不会被左侧的浮动元素遮住了。

还有一些好玩的可以之后慢慢探索，也欢迎交流~
