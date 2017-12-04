---
title: "webpack学习笔记"
date: 2017-07-08T15:23:25+08:00
---
# webpack学习笔记
最近研究了一阵子webpack，刚开始还是觉得很难啃，后来慢慢觉得好梳理一些了，就做了一些很简单的笔记，好记性不如烂笔头嘛哈哈哈。

<!--more-->

### 入口（entry）
入口就是告诉webpack从哪个文件开始生成依赖关系图表，并从依赖关系图表知道要打包哪些文件。可以有多个入口文件，入口文件的可以是一个String、Array、Object。
##### 单个入口
```
module.exports = {
  entry: './path/src/app.js'
}
```
这种写法是省略了main的省略写法，实际上写法是：
```
module.exports = {
  entry: {
    main: './path/src/app.js'
  }
}
```
##### 多个入口
```
module.exports = {
  entry: {
    pageOne: './path/pageOne/index.js',
    pageTwo: './path/pageTwo/index.js'
  }
}
或者写成数组形式
module.exports = {
  entry: [./path/pageOne/index.js, ./path/pageTwo/index.js]
}
```
当向 entry 传入数组的时候会建立多个主入口，这种方式适用于当多个依赖文件一起注入，并且把依赖文件导向一个chunk的时候。

### 输出(output)
输出就是 webpack 打包之后生成的文件所在的位置，也就是说你要告诉webpack打包之后的文件放在哪里，入口可以有多个但是输出配置只能指定一个。如果生成了多个chunk，应该使用占位符来标志每个chunk的唯一性。
```
module.exports = {
  entry: {
    pageOne: './path/pageOne/index.js',
    pageTwo: './path/pageTwo/index.js'
  },
  output: {
    filename: '[name].js',
    path: __dirname + '/page',
    chunkFilename: '[id].[hash].js'
  }
}
```
这里的[name]就是占位符，还有其余一些别的占位符（https://webpack.js.org/configuration/output/#output-filename)。
占位符指的是相应的入口的名字，譬如这里就是 pageOne.js pageTwo.js，这里的 chunkFilename 是不在入口列表中但是需要被打包的文件，一般是按需加载(异步)模块的，这些文件一般没有被列在 entry 之中。之前看到一个很好的回答:[怎么理解webpack中的output.filename 和output.chunkFilename](http://react-china.org/t/webpack-output-filename-output-chunkfilename/2256)。

### Loader
因为 webpack 把所有文件都当成模块处理但是它却只理解 JavaScript,因此需要webpack loader 会将已被添加到依赖图中的文件，转换为模块，loader 对模块的源代码进行转换，在加载文件的时候进行预处理文件，loader 可以将文件从不同的语言转换为 JavaScript。
loader写法一般是两步： test 以及 use
```
module: {
    rules: [
      {
        test: /\.js|jsx?$/,
        exclude: /node_modules/,
        loader: 'babel',
      },
      test: /\.css$/,
      use: [
        { loader: 'style-loader' },
        {
          loader: 'css-loader',
          options: {
            modules: true
          }
        }
      ]
    ]
  }
```
test 是表示需要处理的文件名或者后缀格式，一般是正则表达式。

exclude 表示忽略掉的文件路径。

include 表示loader是处理哪些路径里面的文件。

loader 表示使用什么加载器。

loader另外一些特性包括：

1.loader 接收查询参数。用于 loader 间传递配置。

2.loader 也能够使用 options 对象进行配置。

3.loader能被链式调用，loader 链中的第一个 loader 返回值给下一个 loader。在最后一个 loader，返回 webpack 所预期的 JavaScript。

### Plugin(插件)
plugin可以做一些 loader 无法解决的事情，webpack plugin 是一个有 apply 属性的 JavaScript 对象。 apply 属性会被 webpack compiler 调用，并且 compiler 对象可在整个 compilation 生命周期访问。这是文档上面的例子。
```
function ConsoleLogOnBuildWebpackPlugin() {

};

ConsoleLogOnBuildWebpackPlugin.prototype.apply = function(compiler) {
  compiler.plugin('run', function(compiler, callback) {
    console.log("webpack 构建过程开始！！！");

    callback();
  });
};
```
使用 plugin ,需要向 plugins 属性传入 new 实例。举例说常见的插件:

- CommonsChunkPlugin
这个插件是用来将多个文件公用的模块打包成一个独立的 js 文件，之后在各个公用文件之间就只需要引入这个独立的 js 文件即可。
- html-webpack-plugin
html-webpack-plugin，是用来生产page的，其中filename是生产的文件路径和名称，template是使用的模板，inject是指将js放在body还是head里。为true会将js放到body里.

```
new HtmlWebpackPlugin({
  filename: 'pa ge.html',
  template: 'pa ge.html',
  inject: true
}),
```
