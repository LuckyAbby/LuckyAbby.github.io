---
title: "Git常用命令"
date: 2017-06-18T15:23:25+08:00
tags: ['Git','JS']
---
在前面的介绍中说完了 Git 的基本知识，这里记录一下自己常用的 Git 命令。常用的命令其实也就那么一些，一些很复杂的命令我觉得等到用的时候去查就好了，还有最重要的是我觉得理解原理更重要。

<!--more-->

### 配置
在向远程仓库提交信息之前最重要的就是配置你的账号和邮箱，这些出现在每次的commit信息之中。
```
git config --global user.name
git config --global user.email
```
使用`--global`选项，配置的信息是放在用户主目录上的。如果想在自己的项目里面使用单独的配置账号邮箱，可以不加这个选项，这个时候的配置信息是放在.git/config里面的。
```
git config --list
```
使用`--list`参数可以看到所有的配置信息，可能会看到重复的变量名，那就说明它们来自不同的配置文件，不过最终 Git 实际采用的是最后一个。

同时配置的时候可以为一些常用的命令命别名，这样可以提高工作效率，例如
```
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
```
这样我们想切换分支的时候只需要使用 `git co`即可。

### 帮助
查看命令怎么用有一个很好的的方式的是查看 Git 自身的 help，这是随时查看不需要联网的。可以使用下面的命令
```
git help <verb>
或者
git <verb> --help
```

### diff
对未暂存的文件使用`git diff`命令能查看工作区这次修改的文件和上次提交的文件之间的区别，使用`git status`命令是查看具体有哪些文件有改动，在使用`git status`之后推荐使用`git diff`来查看具体的改动是什么。

注意这里 `git diff`是查看未暂存的文件和暂存区域快照的区别，也就是修改之后还没有暂存起来的变化内容。如果是查看已经暂存的文件和上次提交的快照文件的区别使用 `git diff --cached`（Git 1.6.1 及更高版本还允许使用 `git diff --staged`）。

### 移除文件
移除文件主要使用的有两个命令`rm`,`git rm`。

对于使用`git add`加入暂存区但是还未提交的文件，可以使用`git rm -f`命令,也可以使用`rm`命令，然后再`git add`。

对于已经提交的文件，可以使用`git rm`命令,然后使用`git commit`,也可以使用`rm`命令，然后再`git add`,`git commit`。

这两个命令最主要的区别就是使用`rm`仅仅是删除工作区域的文件，需要再使用`git add/rm`命令，而`git rm`相当于删除暂存区的文件，可以一步做完。

还有一种情况：我们想删除一些已经加入暂存区或者已经提交的文件但是希望在工作区保留这些文件，例如应该加入.gitignore中的一些文件误上传，可以使用`git rm --cached`命令。

### 重命名
对于加入暂存区的文件或者已经提交的文件可以使用`git mv name.js othername`来重命名文件。对于已经提交的文件，使用该命令相当于运行了下面三条命令：`mv name.js othername` `git rm name.js` `git add othername`，相比而言,`git mv`要轻便很多

### 查看历史提交
查看历史消息一般使用`git log`，这个命令有很多参数可以使用，例如 -p 选项可以展开显示每次提交的内容差异等等，这里不细说。

这里可以推荐使用一个打log更方便的命令`git config --global alias.lo "log --graph --pretty=format:'%Cred%h%Creset - %C(yellow)%an%Creset<%ae> ,%C(bold blue)%ar%Creset :%Cgreen%s%Creset'"`

输入之后再输入`git lo`就可以打出更简单易懂的信息了。这里用的其实就是`pretty=format`参数来格式化我们自己想要的输出。其中`%C`可以来规定颜色。

### 修改前一次提交
如果在提交的时候发现自己的commit的信息写错了，你想修改这一次提交的信息，就可以使用`git commit -- amend`命令。

这个命令主要是用来修改最后一次提交，使用之后会出现 git 默认的文本编辑器，编辑它确认没问题后保存退出，就会使用新的提交说明覆盖刚才失误的提交。

如果在上一次的提交中发现还有一部分信息需要一起提交，也可以先`git add`上忘记的文件，然后使用`git commit -- amend`命令，成为一次提交。

### reset
如果自己在使用`git add`添加文件到暂存区的时候，一不小心将两个文件添加了，或者不小心使用了`-- all`参数，可是自己只想添加一个文件，这个时候如果想撤销之前的操作，就可以使用`git reset HEAD <file>`命令，这样这个文件就会变成未暂存的状态。

这个命令还有一个很强大的地方，就是可以**回退版本**，同时对于一个文件自己可以修改无数次，每次修改提交之后就会有一个commit 的 id，这个 id 是一个SHA1计算出来的一个非常大的数字，每个 id 都会是唯一的。

可以使用`git log`查看每个 commit 的 id，也可以使用`git reflog`，这个命令记录了每一次提交，如果自己想退回到某个版本去，可以使用`git reset --hard HEAD^`，在 git 中用 HEAD 表示当前版本， HEAD^表示上一个版本，如果想退回到前几十个版本之前，可以直接使用`git reset --hard commitID`就可以直接将HEAD指针指向那个版本。

### 撤销修改
可以使用`git commit --amend`修改最后一次提交，比如漏加文件或者提交信息写错了想修改。使用这个命令如果不增加新的文件的话会重新编辑你的提交信息，如果漏加文件，使用`git add`增加文件之后再使用这个命令会使得提交合并成一次提交。

如果自己将工作区的某个文件改动完之后**还未添加到暂存区**发现之前的改动是完全没有必要的，这个时候也有一个命令可以撤销之前的修改，就是`git checkout -- file`。

这个命令只有自己真的觉得自己的修改是完全没有必要的情况下再使用，因为这个命令会将之前版本的复制过来重写整个文件，如果觉得自己当前的修改是想保留下来可以提交之后选择回退版本。

如果自己的文件在改动之后已经**添加到暂存区**了，这个时候可以使用`git reset HEAD <file>`命令，使文件变成未暂存的状态，然后使用 checkout 即可。

如果已经提交了，可以选择版本回退到自己想要的版本。

### 远程仓库
在本地建了一个仓库之后如果需要关联到某个远程仓库进行文件的上传下拉等操作，需要先使用`git remote add <name> <url>`将远程的仓库关联到本地仓库，这里的 name 是自己为这个仓库取得名字，url是远程仓库的地址。

可以使用`git remote -v`来查看自己的仓库关联了哪些远程仓库，关联到远程仓库之后可以使用`git fetch <remote-name>`将远程分支上面的数据抓取到本地。在克隆完某个项目后，至少可以看到一个名为 origin 的远程库，**Git 默认使用这个名字来标识你所克隆的原始仓库**：

之后可以使用`git branch -a`查看自己的分支并可以使用`git checkout <branch-name>`切换到自己新抓取的那个分支上面看看都下拉了什么，也可以使用`git merge`合并分支。

一般我们都会选择克隆一个仓库到本地，这个时候查看`git remote -v`会发现自动将远程仓库命名为 origin，所以`git fetch origin`会拉取上次自从上次fetch之后别人上传的更新，fetch只会拉取数据到本地，但不会自动合并到当前工作分支。

这样我们有另一个命令叫`git pull`，这个命令自动抓取数据下来，会将远端分支自动合并到本地仓库中当前分支。相当于fetch + merge。

说完拉取数据之后，还有一个命令`git push [remote-name] [branch-name]`(`git push origin master`)可以将本地的数据推到远程仓库上面，如果在推数据前，已经有其他人推送了若干更新，那这个 push 就会被拒绝。必须先把他们的更新抓取到本地，合并到自己的项目中，然后才可以再次推送。

对远程仓库如果想更名可以使用`git remote rename <name> <anothername>`命令，如果想删除，可以使用`git remote rm <name>`。

### 分支管理
有时候当新建的分支多了之后，对一些分支进行管理的时候可能会遇到不知道哪些分支已经合并过的问题。

这个时候我们可以使用`git branche --merged`来列出所有已经合并到当前分支的所有分支。注意当前分支就是前面带有`*`的分支。同样我们也可以使用`git branch --no-merged`来列出所有还未被合并到当前分支的分支。

当你对一个已经合并过的分支使用`git branch -d branchName`的时候会直接删除这个分支，但是对一个还未合并过的分支使用这个命令的时候会提示你`error: The branch 'test' is not fully merged.If you are sure you want to delete it, run 'git branch -D test'.`。但是当你确实是想删掉这个分支的话，也可以使用`git branch -D branchName`删掉这个未合并过的分支

上面罗列出来的就是常用的一些命令，先写到这里，下次再对一些内容进行补充。

----------2018.03.20补充-----------

### 挑拣(cherry-pick)之前的历史

挑拣类似于针对某次特定提交的衍合。它首先提取某次提交的补丁，然后试着应用在当前分支上。如果某个特性分支上有多个提交，但你只想引入其中之一就可以使用这种方法。

假设现在你在 lyt/bugfix 分支上做了两个 commit 提交，但是你只想合并其中第一个提交，因此你可以使用 cherry-pick 挑选出这一个你想合并的 commit 。

![](http://ojzeprg7w.bkt.clouddn.com/gitnn1.png)

代码如下：
![](http://ojzeprg7w.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-03-16%20%E4%B8%8B%E5%8D%885.24.55.png)

之后你的提交记录就会变成这样：

![](http://ojzeprg7w.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202018-03-16%20%E4%B8%8B%E5%8D%885.43.55.png)

注意此时的 c5' 和之前的 c5 虽然内容是一样的，但是会得到不同的SHA-1值，因为应用日期不同。

如果在挑拣的过程遇到冲突，手动解决冲突，再 continue 代码如下：

![](http://ojzeprg7w.bkt.clouddn.com/gitnnnn3.png)

### 参考：

《Pro Git》

[廖雪峰老师的Git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
