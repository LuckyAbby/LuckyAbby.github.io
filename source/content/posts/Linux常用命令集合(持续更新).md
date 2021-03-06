---
title: "Linux常用命令集合(持续更新)"
date: 2017-02-18T20:23:25+08:00
tags: ['Linux']
---
自从开始接触命令行之后，就开始感叹命令行效率的强大，自己接触命令行也没多久，这篇博客就当自己的日记本，把自己常用的命令行写进来，有些自己总是记不住，记下来也免得自己又得去查。

## 常用命令行

### 1. cd
后面的参数可以是绝对路径也可能是相对路径。
```
cd /A/b.html # 定位到目录A下面的b.html文件  
cd ./        # 定位到当前目录 “.”表示当前目录    
cd ../        # 定位到上层目录 “..”表示上一层目录
```

### 2. ls
ls主要用来查看文件和目录
```
-l ：列出长数据串，包含文件的属性与权限数据等  
-a ：列出全部的文件，连同隐藏文件（开头为.的文件）一起列出来（常用）  
-d ：仅列出目录本身，而不是列出目录的文件数据  
-R ：连同子目录的内容一起列出（递归列出），等于该目录下的所有文件都会显示出来
```
这些参数可以同时使用，如下面的三个命令的区别
```
1. ls 显示当前下面的文件及文件夹
2. ls -a 显示当前目录下的所有文件及文件夹包括隐藏的.和..等
3. ls -al 显示当前目录下的所有文件及文件夹包括隐藏的.和..等并显示详细信息，详细信息包括大小，属组，创建时间
```
### 3. cp
cp=copy,就是复制的意思，可以将一个文件复制给另一个文件，也可以将多个文件复制到一个文件夹。
```
-a ：将文件的特性一起复制  
-p ：连同文件的属性一起复制，而非使用默认方式，与-a相似，常用于备份  
-i ：若目标文件已经存在时，在覆盖时会先询问操作的进行  
-r ：递归持续复制，用于目录的复制行为  
-u ：目标文件与源文件有差异时才会复制
```
```
cp -a a.html b.html test #将a.html b.html连同特性一起复制到test目录下
```
如果把一个文件复制到一个目标文件中，而目标文件已经存在，那么，该目标文件的内容将被破坏。此命令中所有参数既可以是绝对路径名，也可以是相对路径名。通常会用到点.或点点..的形式。例如，下面的命令将指定文件复制到当前目录下：
```
 cp ../mary/homework/assign .
```
所有目标文件指定的目录必须是己经存在的，cp命令不能创建目录。如果没有文件复制的权限，则系统会显示出错信息。 将文件file复制到目录/usr/men/tmp下，并改名为file1
```
cp file /usr/men/tmp/file1
```
将目录/usr/men下的所有文件及其子目录复制到目录/usr/zh中
```
cp -r /usr/men /usr/zh
```
交互式地将目录/usr/men中的以m打头的所有.c文件复制到目录/usr/zh中
```
cp -i /usr/men m*.c /usr/zh
```

### 4. mv
mv=move,可用来移动文件目录或者更名
```
# 文件更名 将a改名为b
mv a.html b.html
# 文件移动 将a.html b.html移动到test目录下
mv a.html b.html test
```

### 5. rm
rm=remove,删除的意思，可用来删除文件或者目录
```
-f ：就是force的意思，忽略不存在的文件，不会出现警告消息  
-i ：互动模式，在删除前会询问用户是否操作  
-r ：递归删除，最常用于目录删除，它是一个非常危险的参数
```
参数可以组合使用
```
rm -fr dir # 强制删除目录dir中的所有文件
```
### 6. find
查找文件,使用起来较为复杂。
```
find <指定目录> <指定条件> <指定动作>
　　- <指定目录>： 所要搜索的目录及其所有子目录。默认为当前目录。
　　- <指定条件>： 所要搜索的文件的特征。
　　- <指定动作>： 对搜索结果进行特定的处理
```
如果什么参数也不加，find默认搜索当前目录及其子目录，并且不过滤任何结果（也就是返回所有文件），将它们全都显示在屏幕上。
```
# 与文件权限及名称有关的参数：  
-name filename ：找出文件名为filename的文件  
-size [+-]SIZE ：找出比SIZE还要大（+）或小（-）的文件  
-tpye TYPE ：查找文件的类型为TYPE的文件，TYPE的值主要有：一般文件（f）、设备文件（b、c）、目录（d）、连接文件（l）、socket（s）、FIFO管道文件（p）；  
-perm mode ：查找文件权限刚好等于mode的文件，mode用数字表示，如0755；  
-perm -mode ：查找文件权限必须要全部包括mode权限的文件，mode用数字表示  
-perm +mode ：查找文件权限包含任一mode的权限的文件，mode用数字表示  
```
```
# / 表示根目录
# . 表示当前目录
# 查找根目录下面名字为a.html的文件
find / -name a.html
# 查找当前目录中，所有文件名以my开头的文件，并显示它们的详细信息。
find . -name 'my*' -ls
# 查找当前目录中文件权限的0755的文件  
find . -perm 0755
```

### 7. mkdir
用来创建一个目录
```
  -m, --mode=模式，设定权限<模式> (类似 chmod)，而不是 rwxrwxrwx 减 umask
  -p, --parents  可以是一个路径名称。此时若路径中的某些目录尚不存在,加上此选项后,系统将自动建立好那些尚不存在的目录,即一次可以建立多个目录;
  -v, --verbose  每次创建新目录都显示信息
      --help   显示此帮助信息并退出
      --version  输出版本信息并退出
```
实例
```
# 创建test的目录
mkdir test
# 递归创建多个目录
mkdir -p test2/test22
# 创建权限为777的目录
mkdir -m 11 test3
```

### 8. touch
可以修改文件或者目录的时间属性，包括存取时间和更改时间。若文件不存在，系统会建立一个新的文件。
ls -l 可以显示档案的时间记录。
```
# 将b.html的时间戳改为a.html的时间戳 如果美誉参考的文件则为系统的时间
touch a.html b.html
# 如果c.html不存在的话则创建该文件
touch c.html
```

### 9. vim命令
该命令主要用于文本编辑，它接一个或多个文件名作为参数，如果文件存在就打开，如果文件不存在就以该文件名创建一个文件。vim是一个文本编辑器，常用的命令等使用多了以后再整理

### 10. cat命令
常用来显示文件内容，或者将几个文件连接起来显示
cat主要有三大功能：
1. 一次显示整个文件:cat filename
2. 从键盘创建一个文件:cat > filename 只能创建新文件,不能编辑已有文件.
3. 将几个文件合并为一个文件:cat file1 file2 > file

```
# 显示出c.html的具体内容
cat c.html
```
### 11. ps命令
ps=process status,用来列出系统中当前运行的进程。ps命令列出的是当前那些进程的快照，就是执行ps命令的那个时刻的那些进程，如果想要动态的显示进程信息，就可以使用top命令。
```
#显示所有进程的信息
ps -a
#显示指定用户下面的进程信息
ps -u root
#显示所有进程信息，连同命令行
ps -ef
#列出目前所有的正在内存中的程序
ps aux
```
其中部分显示命令的含义是
```
UID     //用户ID、但输出的是用户名
PID     //进程的ID
PPID    //父进程ID
C       //进程占用CPU的百分比
STIME   //进程启动到现在的时间
TTY     //该进程在那个终端上运行，若与终端无关，则显示? 若为pts/0等，则表示由网络连接主机进程。
CMD     //命令的名称和参数
```

### 12. pstree命令
linux中，每一个进程都是由其父进程创建的。此命令以可视化方式显示进程，通过显示进程的树状图来展示进程间关系。如果指定了pid了，那么树的根是该pid，不然将会是init（pid： 1）。

### 13. top命令
top是一个更加有用的命令，可以监视系统中不同的进程所使用的资源。它提供实时的系统状态信息。显示进程的数据包括 PID、进程属主、优先级、%CPU、%memory等。可以使用这些显示指示出资源使用量。

### 14. nice命令
通过nice命令的帮助，用户可以设置和改变进程的优先级。提高一个进程的优先级，内核会分配更多CPU时间片给这个进程。默认情况下，进程以0的优先级启动。进程优先级可以通过top命令显示的NI（nice value）列查看。进程优先级值的范围从-20到19。值越低，优先级越高。
```
#不加任何参数 显示当前的优先级 0
nice
#默认增加10个优先级
nice nice
```
-n, --adjustment=ADJUST 指定程序运行优先级的调整值
```
#以参数“-n”的形式指定程序运行优先级的调整值，系统缺省优先级0加上调整值-21得到新的优先级-21(小于-20，因此程序最终的运行优先级为-20
nice -n -21 nice
#大于19显示19
nice --adjustment=20 nice
```
还可以使用参数“-ADJUST”的形式来指定程序运行优先级的调整值，其中，ADJUST为指定的程序运行优先级调整值，可以为负数，也可以为正数
```
#显示-1
nice --1 nice
#显示1
nice -+1 nice
nice -1 nice
```
在nice命令中，可以同时指定多个程序运行优先级调整值，但只有最后一次指定的数值有效
```
#显示3
nice -n -20 --adjustment +19 -3 nice
```
