---
title: "我所理解的RESTful api"
date: 2017-07-09T18:23:25+08:00
---
在解释我所理解的 RESTful api 的时候，先说说为什么会有 RESTful 结构， 因为之前的网页都是没有做到前后端分离的，使用一些类似于 JSP 进行嵌套，这样子就不易于前后端协作开发。所以就需要规范一些 api ，使得前后端通过 api 就能明晰地进行协作开发，只要按照 api 约定好的格式去传数据就好了。而这个 RESTful api就是 REST 风格的接口。至于 REST 风格是什么，英文全称是 REpresentational State Transfer，中文翻译为表现层状态转移，具体是什么我也看的很懵。。。

<!--more-->

现在就说说 RESTful api 好了。我理解的用一句话总结就是 URL 只表示资源的位置，使用 HTTP 的动作词表示操作。

##### URL 只表示资源的位置
URL里面只表示资源的位置，不能出现对资源的操作，因此只允许有名词，并且推荐使用复数，不允许出现动词，比如：
```
example.com／api/v1/books 获取所有的书本信息
example.com/api/v1/markets 获取所有的商场信息
```
这里的`v1`表示版本信息，可以省略的。Github 就是这种做法：[Github 的api](https://developer.github.com/v3/media/#request-specific-version)。

有一些不好的例子：
```
example.com／api/v1/getBooks 获取所有的书本信息
example.com／api/v1/deleteBooks 删除所有的书本信息
```

##### 使用 HTTP 动作次表示操作
在 RESTful api 里面使用的动作次一般包括 GET POST PUT DELETE PATCH
例如：
```
GET example.com／api/v1/books／id 获取某个指定id的书的信息
## 典型的例子就是: https://www.zhihu.com/question/20284816 获取id是20284816编号的问题
POST example.com/api/v1/books 新建一个书的信息
PUT example.com/api/v1/books/{id} 修改某本书的信息
PATCH example.com/api/v1/books/{id} 修改某本书的信息（局部更新）
DELSTE example.com/api/v1/books／{id} 删除某本书的信息
```
这里区分一下 PATCH 与 PUT 的区别
如果需要修改一个联系人的电话号码 这个联系人的信息是放在 userInfo 这个对象里面的，需要修改的只是 userPhone 这个字段，这个对象里面还有比如 userName userSex 等等字段 ，如果是 PUT 需要传一整个新的对象过去，这个对象除了电话号码是修改过的之外别的都是没变的，因此这样就比较浪费。但是PATCH 是只需要提供 userPhone 过去就好了，所以是局部更新。

##### 资源的传递约定格式，返回需要状态码
客户端和服务端之间传递的资源约定好格式，一般最常用的是 JSON，当然还有 XML等等，这也是这种资源的表现层。

使用 HTTP 状态码 传递服务器端的状态信息。例如使用 200 表示操作成功，404 表示未找到资源，500 表示服务器内部错误等。

对于一些状态码的后端要给出明确的文本信息，便于理解。

总的来说 ，RESTful api 只是一种推荐使用的规范，不是必须使用的，使用只是因为方便前后端沟通，应该根据实际情况变动。
