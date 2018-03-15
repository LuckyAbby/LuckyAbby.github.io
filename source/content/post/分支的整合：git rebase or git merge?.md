---
title: "分支的整合：git rebase Or git merge"
date: 2018-03-14T20:56:29+08:00
tags: ["Git"]
---

Git 整合分支一般有 git merge 和 git rebase 两种。rebase 通常就是我们所说的“变基”、“衍合”。

假设我们现在有两个分支，master和 develop 分支，master上的分支永远都是稳定版本的，develop上的分支存放的是暂定的开发版本的代码。我们需要将自己开发分支上的代码先合并到 develop 上。

假设你从 master 新拉了一个分支，但是此时你的小伙伴已经上传了她的代码到了 develop 分支，此时分支的提交历史如下：

![](http://ojzeprg7w.bkt.clouddn.com/gitn1.png)

此时你将你的分支整合到 develop 上就会有两种整合方案，一是 git merge 另一种就是 git rebase。

### git merge

使用 git merge 命令它会把两个分支最新的快照（C4 和 C5）以及二者最新的共同祖先（C3）进行三方合并，合并的结果是产生一个新的提交对象（C6）。

![](http://ojzeprg7w.bkt.clouddn.com/gitn9.png)

<!-- ```
➜  gitOwn git:(lyt/bugfix) git co develop
Switched to branch 'develop'
➜  gitOwn git:(develop) git merge lyt/bugfix
Merge made by the 'recursive' strategy.
 bugfix.js | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 bugfix.js
``` -->

由于当前 develop 分支所指向的提交对象（C4）并不是 lyt/bugfix 分支的直接祖先，Git 不得不进行一些额外处理。就此例而言，Git 会用两个分支的末端（C4 和 C5）以及它们的共同祖先（C3）进行一次简单的三方合并计算 **并重新做一个新的快照，并自动创建一个指向它的提交对象**，因此我们会看到git merge 之后会创建一个默认为`Merge branch 'lyt/bugfix' into develop`的commit信息。

最后的提交历史如图：

![](http://ojzeprg7w.bkt.clouddn.com/gitn10.png)

用 git merge 是最方便的合并操作，也会保留真实完整的 commit 信息。但是也会导致一个问题，就是会使得提交历史发生很多分叉，如下图:

![](http://ojzeprg7w.bkt.clouddn.com/gitn6.png)

由图可见，提交从 master 开始分叉，分成 develop 和 lyt/bugfix 两个分支，最后又合并到 develop 分支上。

这样如果提交变得多了，分支分叉就会导致提交历史历史线变得十分混乱。因此，就有 rebase 操作，可以使得分支的线变得十分干净。

### git rebase

使用 git merge 命令会使得提交的历史出现分叉，使得提交变得十分混乱。

如果此时我们使用`git rebase develop`就会使得  lyt/bugfix 这个分支变基到 develop 上，也就是说提取在 C5 中引入的补丁和修改，然后在 C4 的基础上应用一次。

简单来说，使用 rebase 命令将提交到某一分支上的所有修改都移至另一分支上，就好像“重新播放”一样。

![](http://ojzeprg7w.bkt.clouddn.com/gitn3.png)

<!-- ```
➜  gitOwn git:(master) git co lyt/bugfix
Switched to branch 'lyt/bugfix'
➜  gitOwn git:(lyt/bugfix) git rebase develop
First, rewinding head to replay your work on top of it...
Applying: add bugfix.js
➜  gitOwn git:(lyt/bugfix)
``` -->

rebase 的原理就是会找到当前分支（lyt/bugfix）和变基的基底分支(develop)这两个分支的共同提交祖先C3，然后对比当前分支相对于祖先之后的历次提交，将这些提交存储为临时文件，最后找到基底分支的目标提交C4，将这些暂存的临时文件依次应用。

之后我们看到的提交历史就如下：

![](http://ojzeprg7w.bkt.clouddn.com/gitn2.png)

变基之后再回到 develop 分支，就可以进一次快进合并。

![](http://ojzeprg7w.bkt.clouddn.com/gitn4.png)

<!-- ```
➜  gitOwn git:(lyt/bugfix) git co develop
Switched to branch 'develop'
➜  gitOwn git:(develop) git merge lyt/bugfix
Updating 334d473..9d499f5
Fast-forward
 bugfix.js | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 bugfix.js
``` -->

合并时出现了“Fast forward”的提示就是快进合并。由于当前 develop 分支所在的提交对象是要并入的 lyt/bugfix 分支的直接上游，Git 只需把 develop 分支指针直接右移。**换句话说，如果顺着一个分支走下去可以到达另一个分支的话，那么 Git 在合并两者时，只会简单地把指针右移，因为这种单线的历史分支不存在任何需要解决的分歧，所以这种合并过程可以称为快进（Fast forward）。**

同时快进合并不会创建上面使用 git merge 直接整合分支的过程中自动创建的一个第三方提交信息。

最后合并之后的提交历史如图：

![](http://ojzeprg7w.bkt.clouddn.com/gitn8.png)

现在的 C5' 对应的快照，其实和普通的三方合并，即 git merge 中的 C6 对应的快照内容一模一样了,但是会使得历史更清晰。

如下图，我们使用图形化的界面可以看到现在的提交历史是一根线，没有分叉的地方，看上去十分干净，但是我们也可以注意到此时更改了提交历史。lyt/bugfix 这个分支能向前追溯到原来不属于它的提交(其余人在 someOtherCommits 上提交的 commit 信息)，这样就会篡改提交历史。

![](http://ojzeprg7w.bkt.clouddn.com/gitn5.png)

#### 解决冲突

如果在 rebase 的操作过程中遇到了冲突，比如我重新从 master 新建了一个分支，同时修改了 develop 分支中修改的一个文件。再 rebase 的时候就会遇到这样的问题。

![](http://ojzeprg7w.bkt.clouddn.com/gitn11.png)

<!-- ```
➜  gitOwn git:(lyt/bugfix11) git rebase develop
First, rewinding head to replay your work on top of it...
Applying: update
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging bugfix.js
CONFLICT (add/add): Merge conflict in bugfix.js
error: Failed to merge in the changes.
Patch failed at 0001 update
The copy of the patch that failed is found in: .git/rebase-apply/patch

When you have resolved this problem, run "git rebase --continue".
If you prefer to skip this patch, run "git rebase --skip" instead.
To check out the original branch and stop rebasing, run "git rebase --abort".
``` -->

上面说的意思就是遇到了冲突，此时我们使用`git status`查看是哪个文件冲突之后，再手动解决冲突。之后添加到暂存区再继续进行 rebase。 rebase 完成之后通过 `git log`就能看到之前在 develop 分支上的提交出现在 lyt/bugfix11 这个分支上了，说明已经变基成功。

![](http://ojzeprg7w.bkt.clouddn.com/gitn12.png)

### git merge or git rebase?

关于这个问题，每个团队都会有不一样的标准。有的团队会觉得 Git 最关键的就是要保留最原始最真实的提交信息，方便后面进行查阅。有的团队会觉得认为提交历史是项目过程中发生的事，最核心的是要使得提交历史一目了然。选择哪种操作还是根据团队去决定。

但是对于变基操作，最关键的一点就是如果自己的分支被别人使用了成为了一个公共的分支，此时千万不要再进行变基操作。如果使用 rebase 操作了那些已经公开的提交对象，并且已经有人基于这些提交对象开展了后续开发工作的话，就会使得提交历史变得十分混乱。

借用一句话：**只对尚未推送或分享给别人的本地修改执行变基操作清理历史，从不对已推送至别处的提交执行变基操作，这样，你才能享受到两种方式带来的便利。**


### 参考资料：

[Pro Git](http://git.oschina.net/progit/3-Git-%E5%88%86%E6%94%AF.html)

[3.6 Git 分支 - 变基](https://git-scm.com/book/zh/v2/Git-%E5%88%86%E6%94%AF-%E5%8F%98%E5%9F%BA)
