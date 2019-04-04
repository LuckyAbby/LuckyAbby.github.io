---
title: "Webpack怎么打包一个文件"
date: 2019-04-02T20:36:01+08:00
ags: ['Webpack','JS']
---
之前零零碎碎写过一些 webpack 的配置，也没有整体的学习 webpack 打包文件的过程，今天整体梳理一下 webpack 究竟是怎么打包文件的，打包之后的文件究竟是什么样子。

首先很简单的配置一下配置信息：

```js
const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin'); //自动生成指定的文件
const CleanWebpackPlugin = require('clean-webpack-plugin'); //自动删除目录

module.exports = {
  entry: {
    index: path.join(__dirname, 'index.js'),
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'js/[name].[chunkhash].js'
  },
  module: {
  },
  plugins: [
    new CleanWebpackPlugin(['dist']),
    new HtmlWebpackPlugin({
      filename: 'index.html'
    }),
  ]
};
```

现在有一个如下目录结构的文件
```js
|—— src
     |-- testA.js
     |-- testB.js
|—— index.js
```
其中三个文件的关系如下：
```js
## index.js
const { hello, webpack } = require('./src/testA');
console.log('hello', hello, webpack);
const child = document.createElement('div');
child.innerHTML = `${hello},${webpack}`;
document.body.appendChild(child);

## testA.js
const webpack = require('./testB');
const hello = 'hello';
module.exports = { hello, webpack };

## testB.js
const webpack = 'webpack';
module.exports = webpack;
```

就是很简单的 index.js 依赖 testA.js，testA.js 依赖 testB.js，
我们在 scripts 脚本里面配置
```js
"scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dist": "webpack --config webpack.config.js",
  },
```
之后运行 npm run dist 可以看到打到之后的 index.[chunkhash].js的文件，我们看看这个文件里面究竟做了什么。

将这个文件精简之后看到的文件如下面的代码：

```js
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

const { hello, webpack } = __webpack_require__(1);
console.log('hello', hello, webpack);
const child = document.createElement('div');
child.innerHTML = `${hello},${webpack}`;
document.body.appendChild(child);

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

const webpack = __webpack_require__(2);
const hello = 'hello';
module.exports = { hello, webpack };

/***/ }),
/* 2 */
/***/ (function(module, exports) {

const webpack = 'webpack';
module.exports = webpack;

/***/ })
/******/ ]);
```
简单的可以归纳出几点：

- 这是一个立即执行的函数，函数的参数是一个函数数组，通过数组的下标来作为 moduleId。

- 立即执行的函数函数体里面定义了一个 `installedModules` 变量用户记录缓存后的模块

- 函数体里面还定义了最重要的函数 `__webpack_require__`，**这个函数用来加载导出的模块**，它会在模块记载之前去判断`installedModules`这个缓存里面是否有模块，有的话就直接从缓存中取出来，没有的话就将这个模块缓存下来，同时通过`	modules[moduleId].call(module.exports, module, module.exports, __webpack_require__)`这行代码执行模块里面的代码，这行代码就是在 module.exports 这个对象上执行传入的方法，并将`module, exports, __webpack_require__ `这三个参数传给执行的方法，这也是为什么我们看到立即执行函数的参数都是`(function(module, exports, __webpack_require__) {`这样开头的函数数组。

- `__webpack_require__`这个函数最后会将`module.exports`这个对象返回出去，这也是为什么我们需要将导出的模块定义在这个变量上的原因。

整体来说还是比较简单的，但是实际应用中还有很多比这个复杂的场景，比如异步加载模块等等，现在我们再加一个异步加载模块的文件 testC.js,并对 index.js进行一下改造,点击按钮之后再去加载 testC.js 这个文件。

```js
## index.js
const btn = document.getElementById('btn');
btn.addEventListener('click', function() {
    //只有触发事件才回家再对应的js 也就是异步加载 
    require.ensure([], function() {
      const data = require('./src/testC');
      const p = document.createElement('p');
      p.innerHTML = data;
      document.body.appendChild(p);
    })
})

## testC.js
const ensureRequire = 'ensure_require';
module.exports = ensureRequire;
```

我们这时候打开浏览器能看到加载的资源只有一个 js 文件,
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/webpackdemo1.jpg)

但是当我们点击按钮之后此时加载的资源多了一个 js 文件，这个文件就是我们异步加载的那个 testC.js,
![](https://abby-1253430270.cos.ap-shanghai.myqcloud.com/webpackdemo2.jpg)



