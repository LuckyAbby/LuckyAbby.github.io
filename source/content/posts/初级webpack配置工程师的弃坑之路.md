+++
title = "初级webpack配置工程师的弃坑之路"
date = 2018-03-23T10:49:18+08:00
tags = ["Webpack", "JS"]
categories = [""]
draft = false
+++

### webpack

webpack 是一个模块打包机，它能分析你项目的依赖结构。从入口文件的js文件进行打包，碰到 CSS 以及图片等等其它的类型的文件采用 loader 或者插件进行处理，最后将处理完的文件打包成一个或者多个合适格式的文件。

### 安装 webpack

首先初始化一个项目，安装 webpack

```
mkdir demo && cd demo
npm init
### 直接 enter 完成 package.json 的初始化
npm install --dev-save webpack
### 将 webpack 安装在开发环境的依赖中
```

#### 1.最简单的例子

建立如下的目录结构
```
|—— dist
     |-- index.html
|—— src
     |-- index.js
     |-- component.js     
```

index.js 文件中的代码如下：

```js
import component from './component.js';

document.body.appendChild(component());
```

component.js 文件中的代码如下：

```js
export default function component(name) {
  const ele = document.createElement('div');
  ele.textContent = 'hi, webpack';
  ele.className = name;
  return ele;
}
```

index.html 文件中的代码如下：

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>webpackTest</title>
</head>
<body>
  <script src="./bundle.js"></script>
</body>
</html>
```
然后在命令行中运行下面的命令调用 webpack 将 index.js 文件打包成 bundle.js 文件。

```
./node_modules/.bin/webpack src/index.js dist/bundle.js
```
这样在命令行中就能看到如下的输出表示已经成功打包了。

```
Hash: 951039c05a4f2aae70b8
Version: webpack 3.11.0
Time: 91ms
    Asset     Size  Chunks             Chunk Names
bundle.js  3.12 kB       0  [emitted]  main
   [0] ./src/index.js 81 bytes {0} [built]
   [1] ./src/component.js 165 bytes {0} [built]
```
这时候你再通过浏览器打开 index.html 这个页面就能看到 `hi, webpack`这句话了，同时，在 dist 目录下面也有新生成的 bundle.js 文件了。

好了，终于迈出第一步了。但是，这样使用还是太挫，我们需要提交一下姿势水平。

#### 2.使用配置文件

使用到 webpack 的配置文件才是发挥 webpack 最神奇文件的地方，当然，也是留坑最多的地方 :)

在项目的目录下面新建  webpack.config.js 文件，如下：

```js
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};

```
这里的 entry 指的是打包的入口，output指的是打包之后放在项目目录的 dist 目录下面，名称为 bundle.js。

配置好了之后每次都需要使用`./node_modules/.bin/webpack`来调用 webpack 也会觉得麻烦，因此我们使用 npm 脚本。

在 package.json 中添加：

```
"dist": "webpack --config webpack.config.js"
```

这样我们就可以通过 npm run dist 来打包文件，也可以省略后面的`--config webpack.config.js`,因为默认的配置文件就是 webpack.config.js。

#### 3.打包其他类型的文件

##### 3.1 打包 CSS

webpack 自己是不能处理 css 文件的，只能依靠 css-loader 和 style-loader 进行处理。css-loader 解释@import 和 url() ，会 import/require() 后再解析(resolve)它们。

首先需要先安装这两个插件:

```
npm install --save-dev style-loader css-loader
```
之后我们再在 src 目录下新建一个 style.css 文件：

```css
body {
  color: #999;
}
```
接着修改 index.js:

```js
import component from './component.js';
import './style.css';

document.body.appendChild(component());
```

这样我们就在 index.js 里面引入了 style.css, 需要在 webpack.config.js 里面去修改相关的配置信息：

```js
module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [{
      test: /\.css$/,
      use: [
        'style-loader',
        'css-loader'
      ]
    }]
  }
};
```

这样我们再运行 npm run dist，就能看到打包出来的信息：
```
Hash: 1384c9fdaeca40d22cac
Version: webpack 3.11.0
Time: 972ms
    Asset   Size  Chunks             Chunk Names
bundle.js  20 kB       0  [emitted]  main
   [0] ./src/index.js 103 bytes {0} [built]
   [1] ./src/component.js 162 bytes {0} [built]
   [2] ./src/style.css 1.07 kB {0} [built]
   [3] ./node_modules/css-loader!./src/style.css 186 bytes {0} [built]
    + 3 hidden modules
```
同时我们再通过浏览器打开 index.html 这个页面就能看到 `hi, webpack`的字体颜色已经变成 #999 了。

##### 3.2 打包图片

图片等静态资源在开发阶段时的相对路径与生产环境中的不尽相同，所以需要对这些文件进行路径转换，此时可以使用file-loader。

首先`npm install --save-dev file-loader`安装 file-loader 对图片进行处理。

我们在 src 下新加一张图片 bg.jpg 和一个 imgComponent.js 文件。现在我们的目录结构如下：
```
|—— dist
     |-- index.html
|—— src
     |-- index.js
     |-- component.js    
     |-- imgComponent.js
     |-- bg.jpg
     |-- style.css
|—— webpack.config.js
```

imgComponent.js 主要是创建一个 img，如下：
```js
export default function imgComponent(url) {
  const ele = new Image();
  ele.src = url;
  return ele;
}
```
再修改 index.js:
```js
import component from './component.js';
import imgComponent from './imgComponent.js';

import './style.css';
import bgUrl from './bg.jpg';

document.body.appendChild(component());
document.body.appendChild(imgComponent(bgUrl));
```
最后我们修改 webpack.config.js:
```js
module: {
    rules: [
    ...
    , {
      test: /\.(jpg|png|jpeg)$/,
      use: [
        'file-loader'
      ]
    }]
  }
```
再运行npm run dist之后我们就能看到图片已经打包进bundle.js里面了，在页面上就能看到图片了。

#### 4.分片打包

在上面的配置中我们都是打包成一个 bundle.js 文件，可是如果以后代码越来越复杂，就需要将原来的一个 bundle.js 打包成多个文件，在 html 里面去引入多个 js。

修改 webpack.config.js 配置：
```js
module.exports = {
  entry: {
    index: './src/index.js',
    component: './src/component.js',
    imgComponent: './src/imgComponent.js',
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  ...
};
```

这里我们打包三个文件，输出文件名中的 [name] 表示 entry 里面指定的名称，最后会生成三个 js 文件：index.bundle.js、component.bundle.js 以及 imgComponent.bundle.js。运行 npm run dist 就能看到，但是此时我们在 html 里面文件里面就需要再手动修改引入的文件，这样会比较麻烦。因此我们引入 HtmlWebpackPlugin 插件，这个插件会自动生成指定的文件。

安装： `npm install --save-dev html-webpack-plugin`

修改配置：
``` js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  ...
  plugins: [
    new HtmlWebpackPlugin({
      title: 'webpack test demo',  // 生成的 HTML 文件的标题
      filename: 'index.html' // 生成的 HTML 文件的文件名，默认 `index.html`
    })
  ]
};
```

把之前的 bundle.js 以及 index.html 删掉，这样我们再编译就能看到自动生成了 index.html 文件放在 dist 目录下，其中引入了生成的三个 js 文件。

但是这样每次都需要我们手动去删掉 dist 里面的文件，尤其是当加上 hash 打包之后就会更麻烦，因此我们需要 clean-webpack-plugin 插件来帮我们清理 dist 目录。

安装 `npm install --save-dev clean-webpack-plugin`

修改配置
```js
...
const CleanWebpackPlugin = require('clean-webpack-plugin');

module.exports = {
  ...
  plugins: [
    new HtmlWebpackPlugin({
      title: 'webpack test demo',  // 生成的 HTML 文件的标题
      filename: 'index.html' // 生成的 HTML 文件的文件名，默认 `index.html`
    }),
    new CleanWebpackPlugin(['dist'])
  ]
};
```

这样之后每次打包之前都会帮我们删掉 dist 目录。

#### 开发环境

##### 1.自动打包代码

自己在开发环境下为了更高效的开发，不会自己手动一遍一遍去打包代码，因此需要 webpack-dev-server 帮你在代码发生改变的时候自动打包代码。

同时为了区分开发环境和生产环境，我们使用 webpack-merge 分离开发环境 dev 和生产环境 prod。

安装 `npm install --save-dev webpack-dev-server webpack-merge`

在项目目录下新建 webpack.dev.js 文件:
```js
const path = require('path');
const Merge = require('webpack-merge');
const CommonConfig = require('./webpack.config.js');

module.exports = Merge(CommonConfig, {
  devtool: 'cheap-module-eval-source-map',
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    host: '127.0.0.1',
    port: 8088,
  }
});
```

这里的 devtool 是选择一个合适的代码映射。代码映射其实就是将打包后的代码映射回原始的源码。尤其是当打包后的代码发生错误时，选择一个合适的代码映射就能追踪到错误发生的原始位置。

devServer 里面的配置就是设置打包之后文件的位置，同时默认打开本机的 8088 端口。

同时我们再修改 package.json 文件修改脚本：

```
"scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dist": "webpack --config webpack.config.js",
    "dev": "webpack-dev-server --config webpack.dev.js --open"
  }
```

我们再运行`npm run dev` 浏览器就会默认打开 8088 端口，同时能看到我们之前的页面。

##### 2.热加载HMR

HRM能够让应用运行的时候替换、增加或删除模块，而无需进行完全的重载,这样可以显著加快开发速度，一旦打开了 webpack-dev-server 的 hot 模式，在试图重新加载整个页面之前，热模式会尝试使用 HMR 来更新。

修改 webpack.dev.js:
```js
...
const webpack = require('webpack');

module.exports = Merge(CommonConfig, {
  devtool: 'cheap-module-eval-source-map',
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    hot: true, // 告诉 dev-server 使用 HMR
    hotOnly: true // 如果热加载失败了禁止刷新页面，可以分析失败原因
    host: '127.0.0.1',
    port: 8088,
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin()
  ]
});
```
这时我们再修改 style.css 将 body 的字体颜色变成 red,再重新运行`npm run dev`,我们会发现页面并没有重新刷新（webpack默认行为是重载页面），但是字体颜色已经变成红色了。

开启了 HMR 功能，HMR 的接口已经暴露在module.hot属性之下，我们就可以使用 [HRM API](https://webpack.js.org/api/hot-module-replacement/)来使得依赖“被加载模块”的原模块在“被加载模块”发生改变时，检测到改变并接收改变之后的模块。

#### 生产环境

一般发布到开发环境的代码需要经过混淆压缩来保证安全，同时在生产环境下面的文件需要加上 hash 防止浏览器缓存。

 新建一个 webpack.prod.js:
 ```js
 const path = require('path');
 const webpack = require('webpack');
 const Merge = require('webpack-merge');
 const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
 const CommonConfig = require('./webpack.config.js');

 module.exports = Merge(CommonConfig, {
   devtool: 'cheap-module-source-map',
   output: {
     filename: '[name].[chunkhash].js'
   },
   plugins: [
     new UglifyJSPlugin()
   ]
 });
 ```
 在这里使用 [name].[chunkhash]就能在文件名字后面加上 hash ,这样就部署在开发环境的时候就不会有缓存问题。

#### 公共代码分离

##### webpack3 公共代码分离

 有时候我们需要在多个文件里面引入一个公共库，比如常见的 lodash。如果我们不把这些公共库的代码分开打包，我们的项目就会变得十分臃肿。在 webpack3 里面，我们使用 CommonsChunkPlugin 来分离公共库。当然咯，webapck4就把它废除了:)。

 安装 lodash :`npm install lodash`

 修改index.js 引入 lodash:
 ```js
 import _ from 'lodash';

 ...
 document.body.appendChild(imgComponent(bgUrl));
 ```

 同时我们也修改 component.js ，同样引入 lodash:
 ```js
 import _ from 'lodash';

 export default function component(name) {
   const ele = document.createElement('div');
   ele.textContent = _.join(['hi', 'webpack'], ' ')
   ele.className = name;
   return ele;
 }
 ```

 如果此时我们直接运用 npm run dist 打包，我们会看到
 ```
 Hash: 5c928a60ca077c1435a0
 Version: webpack 3.11.0
 Time: 1775ms
                                Asset       Size   Chunks                    Chunk Names
 5fc6e7227e5d7416b1b72d7ff15be182.jpg      36 kB           [emitted]
                      index.bundle.js     563 kB  0, 1, 2  [emitted]  [big]  index
                  component.bundle.js     544 kB        1  [emitted]  [big]  component
               imgComponent.bundle.js    2.77 kB        2  [emitted]         imgComponent
                           index.html  329 bytes           [emitted]
    [1] (webpack)/buildin/global.js 509 bytes {0} {1} [built]
 ```
 此时 index.bundle.js 和 component.bundle.js 十分大，因为都引入了 lodash 这个库。因此我们需要把它抽取出来。

 修改 webpack.config.js:

 ```js
 module.exports = {
   entry: {
     index: './src/index.js',
     component: './src/component.js',
     imgComponent: './src/imgComponent.js',
     vendor: [ // 第三方库可以统一放在这个入口一起合并
       'lodash'
     ]
   },
   ...
   plugins: [
     new HtmlWebpackPlugin({
       title: 'webpack test demo',
       filename: 'index.html'
     }),
     new CleanWebpackPlugin(['dist']),
     new webpack.optimize.CommonsChunkPlugin({
       name: 'vendor' // 抽取出的模块的模块名
     }),
   ],
 };
 ```

 我们在入口这里新建了一个 vendor 的入口，同时在 plugins 里面引入了插件，这样我们再打包看看终端输出：

 ```
 Hash: a96dbe4172371d7bfbae
 Version: webpack 3.11.0
 Time: 1687ms
                                Asset       Size   Chunks                    Chunk Names
 5fc6e7227e5d7416b1b72d7ff15be182.jpg      36 kB           [emitted]
                      index.bundle.js    19.3 kB  0, 1, 2  [emitted]         index
               imgComponent.bundle.js  375 bytes        1  [emitted]         imgComponent
                  component.bundle.js  720 bytes        2  [emitted]         component
                     vendor.bundle.js     545 kB        3  [emitted]  [big]  common
                           index.html  392 bytes           [emitted]
    [1] ./src/component.js 203 bytes {0} {2} [built]
 ```

 我们看到此时 index.bundle.js 和 component.bundle.js 变得小了，同时 lodash 也被打包到 vendor.bundle.js 里面去了，从代码里面分离出来了，同样我们也可以打包一些公用的组件。

##### webpack4 公共代码分离

webpack4 已经废弃了 CommonsChunkPlugin 这个插件，使用两个新的配置项（optimization.splitChunks 和 optimization.runtimeChunk。

修改 webpack.config.js:
```js
module.exports = {
  entry: {
      index: './src/index.js',
      imgComponent: './src/imgComponent.js',
      // vendor: [ // 第三方库可以统一放在这个入口一起合并
      //   'lodash'
      // ]
    },
  ...
    // webpack4 使用这个配置项拆分打包
    optimization: {
      splitChunks: {
        chunks: 'all',
      },
      runtimeChunk: true
    },
    plugins: [
      ..
      // new webpack.optimize.CommonsChunkPlugin({
      //   name: 'vendor' // 抽取出的模块的模块名
      // }),
    ],
}
```

通过设置 optimization.splitChunks.chunks:  "all" 来启动默认的代码分割配置项。

当满足如下条件时，webpack 会自动打包 chunks:

- 当前模块是公共模块（多处引用）或者模块来自 node_modules
- 当前模块大小大于 30kb
- 如果此模块是按需加载，并行请求的最大数量小于等于 5
- 如果此模块在初始页面加载，并行请求的最大数量小于等于 3

同样我们打包得到：
```
                               Asset       Size  Chunks             Chunk Names
5fc6e7227e5d7416b1b72d7ff15be182.jpg   35.1 KiB          [emitted]
      runtime~imgComponent.bundle.js   1.04 KiB       0  [emitted]  runtime~imgComponent
             runtime~index.bundle.js   1.04 KiB       1  [emitted]  runtime~index
             vendors~index.bundle.js   74.7 KiB       2  [emitted]  vendors~index
              imgComponent.bundle.js  192 bytes       3  [emitted]  imgComponent
                     index.bundle.js  844 bytes    4, 3  [emitted]  index
                          index.html  480 bytes          [emitted]
Entrypoint index = runtime~index.bundle.js vendors~index.bundle.js index.bundle.js
Entrypoint imgComponent = runtime~imgComponent.bundle.js imgComponent.bundle.js
```
可以看到多了一个 vendors~index.bundle.js 文件，会把 lodash 抽取出来放在这个文件里面。 因为 lodash 是公用模块，大于 30kb,最大请求数量为2小于5，因此会被 webpack 自动打包创建一个包含 lodash 的分离代码块。当import调用时候，这个代码块就会与 index.js 代码被并行加载。也可以自己配置来更换自动打包的条件。

通过设置 optimization.runtimeChunk: true 为每一个入口默认添加一个只包含 runtime 的 chunk。

#### 指定环境

 许多库将通过与 process.env.NODE_ENV 环境变量关联，来决定库中应该引用哪些内容。例如，当不处于生产环境中时，某些库为了使调试变得容易，可能会添加额外的日志记录(log)和测试(test)。可以使用 webpack 内置的 DefinePlugin 为所有的依赖定义这个变量。

 修改 webpack.prod.js：
 ```js
 module.exports = Merge(CommonConfig, {
  ...
  plugins: [
    new UglifyJSPlugin()
  ],
  new webpack.DefinePlugin({
    'process.env.NODE_ENV': JSON.stringify('production')
  })
});
 ```

 修改 webpack.dev.js:
 ```js
 module.exports = Merge(CommonConfig, {
   ...
   plugins: [
     ...
     new webpack.DefinePlugin({
       'process.env.NODE_ENV': JSON.stringify('development')
     })
   ]
 });
 ```
 然后我们在 index.js 里面就可以直接访问 process.env.NODE_ENV 这个变量了，修改 index.js:

 ```js
 ...
 if (process.env.NODE_ENV === 'development') {
    console.log('开发环境');
  }
 ```

 这样我们运行 npm run dev 之后就能看到控制台输出了开发环境这几个字，表示能成功访问这个变量。


#### 动态加载模块

 我们可以使用 import 动态加载模块，就不需要在页面初始的时候将所有模块加载出来，可以在我们需要的时候再加载模块，这样也能优化性能。

 我们修改 index.js：
 ```js
 import _ from 'lodash';

 import './style.css';
 import bgUrl from './bg.jpg';

 const btn = document.createElement('button');
 btn.innerHTML = 'click me';
 document.body.appendChild(btn);

 btn.onclick = function() {
   import(/* webpackChunkName: "component" */ './component.js')
   .then(function(module) {
     const component = module.default; // 引入模块的默认函数
     document.body.appendChild(component());
   });
 };
 ```
 同时修改 webpack.config.js：
 ```js
 ...
 module.exports = {
  ...
   output: {
     filename: '[name].bundle.js',
     chunkFilename: '[name].bundle.js', // 非入口文件打包出来的名字
     path: path.resolve(__dirname, 'dist'),
   },
   ...
}
 ```
 import之后返回一个 promise，上面的注释中的 webpackChunkName结合 chunkFilename 可以表示新 chunk 的名称（不然会默认是数字）,同时还支持 webpackMode: "lazy" 注释，表示懒加载，不过这个也是默认的，可以省略。还有其余属性例如 "lazy-once", "eager", "weak"等。 详见 [import](https://doc.webpack-china.org/api/module-methods/#import-)

打包之后我们打开页面只能看到有一个按钮，并没有 hi webpack 这句话。当我们点击按钮之后，页面上才会出现这句话，说明 ./component.js 是动态引入的。

这个入门级的很长的文章暂时告一段落。。。写这个文章的目的只是为了帮自己梳理一下最近学的 webpack， 真正需要学习的还有很多，这篇文章远远不够。

任重道远:) 互勉。

代码地址：https://github.com/LuckyAbby/webpackTestDemo.git


#### 推荐阅读
[对Webpack的hash稳定性的初步探索](https://zhuanlan.zhihu.com/p/35093098?utm_medium=social&utm_source=wechat_session)

[Webpack Guides](https://webpack.js.org/guides/)
