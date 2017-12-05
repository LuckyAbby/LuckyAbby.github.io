---
title: "C语言实现数据结构--队列"
date: 2017-05-22T15:29:25+08:00
tags: ['数据结构','C']
---
队列 (Queue)：简称队，是另一种限定性的线性表，它只允许在表的一端插入元素，而在另一端删除元素。q=(a1, a2, a3, … an),其中a1为队头，an为队尾。
<!--more-->

队列在生活中也比较常见，例如购物排队——新来的成员总是加入队尾,每次离开的成员总是队列头上的。

队列按存储方式可以分为两种：顺序队列和链队列。

## 链队列
链式队列中每个元素定义成一个结点，含数据域与指针域（指向下一结点），并设头尾指针。用图表示就是。
![](http://ojzeprg7w.bkt.clouddn.com/%E9%98%9F%E5%88%9711_%E7%9C%8B%E5%9B%BE%E7%8E%8B.png)

### 链队的表示
前面的链式结构，总是使用一个结点的结构来表示链表，但是在这里使用新的存储结构。定义一个结点结构，和一个队列结构。两个结构嵌套。
```C
//定义节点结构
typedef struct QNode
{
    QElemType   data;   /*数据域*/
    struct QNode   * next;   /*指针域*/
 }QNode, *QueuePtr;

//定义队列结构
 typedef struct
 {
    QueuePtr front;
    QueuePtr rear;
 }LinkQueue;
```
### 链队的基本操作

#### 1. 链队的初始化
```C
Status initQueue(LinkQueue *Q)
{
    Q.front = Q.rear = (QueuePtr)malloc(sizeof(QNode));
    if(!Q.front) exit(OVERFLOW);
    Q.front->next = NULL;
    return OK;
}
```
#### 2. 链队的销毁
```C
Status destroyQueue(LinkQueue *Q)
{
    while (Q.front)
    {
        Q.rear = Q.front->next;
        free(Q.front);
        Q.front = Q.rear;
    }
   return OK;
}
```

#### 3. 入队
```C
Status enQueue(LinkQueue *Q, QElemType e)
{
    QueuePtr p = (QueuePtr)malloc(sizeof(QNode));
    if(!p) exit(OVERFLOW);
    //插入数据
    p->data = e;
    p->next = NULL;
    //Q.rear一直指向队尾
    Q.rear->next = p;
    Q.rear = p;
    return OK;
 }

```
#### 4. 出队

```C
Status deQueue(LinkQueue *Q, QElemType e)
{
    if(Q.front == Q.rear)return ERROR;
    QueuePtr p = Q.front->next;
    e = p->data;
    Q.front->next = p->next;   //队头元素p出队
    if(Q.rear == p)   //如果队中只有一个元素p, 则p出队后成为空队
    Q.rear = Q.front;     //给队尾指针赋值
    free(p);   //释放存储空间
    return OK;
}
```

## 顺序队列
用一组连续的存储单元依次存放队列的元素，并设两个指针front、rear分别指示队头和队尾元素的位置。
front：指向实际的队头；rear：指向实际队尾的下一位置。
初态：front＝rear＝0；队空：front＝rear;队满：rear＝M;
入队：q[rear]=x; rear＝ rear+1; 出队：x=q[front];front=front+1;

### 顺序队列的表示

```C
#define MAXQSIZE  100
typedef struct
{
    QElemType *base;
    int  front;   //头指针指示器
    int  rear;  //尾指针指示器
} SqQueue;

```

### 存在的问题

随着入队、出队操作的进行，整个队列会整体向后移动，这样就出现了下图的现象：队尾指针虽然已经移到了最后，而队列却未真满的“假溢出”现象，使得队列的空间没有得到有效的利用。
![](http://ojzeprg7w.bkt.clouddn.com/%E9%98%9F%E5%88%972.png)

那我们该如何解决假溢出的问题呢？
有以下两种方法：
1.将队中元素向队头移动
当移动数据较多时将会影响队列的操作速度。
2.采用循环队列：Q[0]接在Q[MAXQSIZE-1]之后
一个更有效的方法是将队列的数据区Q[0 .. MAXQSIZE-1]看成是首尾相连的环，即将表示队首的元素Q[0]与表示队尾的元素Q[MAXQSIZE–1]连接起来，形成一个环形表，这就成了循环队列。当Q.rear=MAXQSIZE-1时再入队，令Q.rear=0, 则可以利用已被删除的元素空间。如下图。
![](http://ojzeprg7w.bkt.clouddn.com/%E9%98%9F%E5%88%973.JPG)

### 循环队列
在循环队列中，不可以根据等式front == rear可以判别队满和队空。因为此时条件是相同的，解决这种问题的方法一般有两种。
1.少用（损失）一个空间,以尾指针加1等于头指针作为队满的标志。因此：当front==rear，表示循环队列为空；当front ==（rear+1）% MAXLEN，表示循环队列为满。
2.在定义结构体时，附设一个存储循环队列中元素个数的变量n，当n==0时表示队空；当n==MAXLEN时为队满。

### 循环队列的基本操作

#### 1. 初始化

```C
Status initQueue (SqQueue *Q)
{
    Q.base=(QElemType *) malloc(MAXQSIZE * sizeof(QElemType));
    if (!Q.base) exit(OVERFLOW);
    Q.front = Q.rear = 0;
    return OK;
}

```

#### 2. 求队列长度
```C
int queueLength(SqQueue *Q)
{
    return (Q.rear - Q.front+MAXQSIZE) % MAXQSIZE;
}

```

#### 3. 入队
```C
Status enQueue (SqQueue *Q, QElemType e)
{
    if((Q.rear+1)%MAXQSIZE == Q.front)  return ERROR;
    Q.base[Q.rear] = e;
    Q.rear = (Q.rear+1) % MAXQSIZE;
    return OK;
}
```

#### 4. 出队
```C
Status deQueue (SqQueue *Q, QElemType e)
{
    if(Q.front == Q.rear)
    return ERROR;
    e = Q.base[Q.front];
    Q.front = (Q.front+1)%MAXQSIZE;
    return OK;
}
```
欢迎指正 orz...
