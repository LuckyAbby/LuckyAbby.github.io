---
title: "博客迁移到hugo"
date: 2017-12-05T10:06:52+08:00
tags: ["hugo"]
---
在经过昨天一天的捣鼓之后，把之前写过的博客从hexo迁移到了hugo

<!-- more -->

## 为什么要迁移

hexo 太慢了，编译到部署一般需要3s左右，而 hugo 却快的多，大概只需要几十毫秒的样子。没有对比就没有伤害。。

其实很早就想迁移了，只是之前一直太懒了，没动，等我 hexo 的博客长草了一个多月之后终于决定要迁移了。。。

## 迁移
hugo 和 hexo 一样，也是静态网站生成器，但是是用最近很热门的 Go 语言编写的，高效快速部署是最典型的特征。

### 安装 hugo

#### mac下安装

使用 Homebrew 安装
```
brew install hugo
```

#### 其他操作系统安装

其他操作系统的安装包可以在[hugo/release](https://github.com/gohugoio/hugo/releases)里面找到，点击下载即可。

### 生成站点

使用 hugo 可以快速生成站点。

```
hugo new site /yourPath
```

使用上述命令会在你想要的路径下面生成一个站点，接着你使用`cd yourPath`进入到自己的站点里面，可以看到如下图的站点目录结构

```
▸ archetypes/
▸ content/
▸ data/
▸ themes/
▸ layouts/
▸ static/
config.toml
```
一般的配置信息写在 config.toml里面，文章在content里面，archetypes 里面一般放的是使用 hugo new 生成页面的时候头部配置信息格式。themes里面放的是你需要的主题。

### 生成博客

使用 `hugo new yourBlogName.md`命令生成的页面一般放在 content 目录下面，但是到时候我们的博客可能有一些除了博客之外的页面，比如 about 页面等等，因此我们可以使用 `hugo new post/yourBlogName.md`生成一篇博客，我们把所有的博客都放在新建的一个 post 目录下面，这个 post 目录是默认放在 content 目录下面的。

这个时候我们查看 yourBlogName.md，会发现自动配置的头部信息格式如下

```
---
title: "YourBlogName"
date: 2017-12-05T11:34:20+08:00
draft: true
---

## Hello

hello hugo!
```
这个头部配置的信息是和 archetypes 里面的 default.md 里面的格式一样的，是可以改成自己想要的格式的。

```
### default.md格式

---
title: "{{ replace .TranslationBaseName "-" " " | title }}"
date: {{ .Date }}
draft: true
---
```
### 安装主题

你可以从[主题列表](https://themes.gohugo.io/)里面选择自己喜欢的主题，如果你和我一样恰好也喜欢[Cactus Plus](https://themes.gohugo.io/hugo-theme-cactus-plus/) 的话，你可以把它 clone 下来。

```
cd themes
git clone https://github.com/nodejh/hugo-theme-cactus-plus.git
```

接下来只需要 **按照这个主题的文档进行配置一些页面的信息** 就好了 ，最后只需要运行`hugo server`命令,在浏览器里打开： http://localhost:1313 即可。

### 部署到 Github

这个时候我们可以部署到 Github Pages，免费托管美滋滋。只需要在你自己的 github 里面创建一个命名为 yourGithubName.github.io 的仓库。

注意，如果你的文章头部有 draft=true ，先去掉，然后在站点根目录执行 hugo 命令生成最终页面，其实 public 目录下面存放的就是你最后生成的所有静态页面，最后只需要把 public 目录里面的文件 push 到你的仓库里面就好了。
```
cd public
$ git init
$ git remote add origin https://github.com/yourGithubName/yourGithubName.github.io.git
$ git add -A
$ git commit -m "first commit"
$ git push -u origin master
```
在浏览器里面访问：http://yourGithubName.github.io/

大功告成，嘻嘻。
