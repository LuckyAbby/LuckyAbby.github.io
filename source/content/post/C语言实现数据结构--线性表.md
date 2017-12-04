---
title: "C语言实现数据结构--线性表"
date: 2017-05-18T15:23:25+08:00
---
线性表是一种最简单的线性结构。
线性结构是一个数据元素的有序集。比较典型的线性结构：线性表、栈、队列、串等。
<!--more-->
线性表是n个数据元素的有限序列，可以表示为:（a1, a2, …，ai-1，ai，ai+1， …，an），其中数据元素可以是各种类型的元素。
线性表常用的两种表现形式是顺序表示与链式表示。

## 线性表的顺序表示--顺序表

线性表的顺序存储是指用一组地址连续的存储单元依次存储线性表中的各个元素，使得线性表中在逻辑结构上相邻的数据元素存储在相邻的物理存储单元中，即通过数据元素物理存储的相邻关系来反映数据元素之间逻辑上的相邻关系。

以“存储位置相邻”表示有序对,即：
```
LOC(ai) = LOC(ai-1) + l （一个数据元素所占存储量）
```
所有数据元素的存储位置均取决于第一个数据元素的存储位置。
```
LOC(ai) = LOC(a1) + (i-1)×l
```

用C语言来描述顺序映像就是：

```C
#define  LIST_INIT_SIZE  80   // 线性表存储空间的初始分配量
#define  LISTINCREMENT  10   // 线性表存储空间的分配增量

typedef  struct {
	ElemType *elem;
	int length;
	int listSize
}SqList;

```
顺序表简单实现数据的插入：

```C
Status ListInsert(SqList &L, int i, ElemType e) {
	q = &(L.elem[i-1]) ; //q指向插入的位置
	for(p = &(L.elem[L.length-1]); p >= q; --p) {
	*(p+1) = *p; //插入位置及之后的元素右移
	}
	*q = e;
	++L.length;
	return OK;
}
```

假如此顺序表的长度是 n,此时算法的时间复杂度是 O(n)。
由此可以看出顺序表的一些缺点比如：插入与删除的效率很低，需要预先分配存储的空间等等。
由此便得到线性表的另一种存储形式--链式存储。

## 线性表的链式表示--链表

数据元素除了具有代表其本身信息的数据域外，还有一个用来指示逻辑关系的指针域，这样的存储结构称为结点。链式存储通过每个结点的指针域将线性表的n个结点按其逻辑顺序链接在一起，称为线性表的链式存储表示。
用图片表示就是
![](http://ojzeprg7w.bkt.clouddn.com/%E9%93%BE%E8%A1%A8.png)

用C语言来描述链式映像就是：

```C
typedef  struct  LNode{
     ElemType  data；       //结点的数据域
     struct  LNode  *next； //结点的指针域
}LNode, *LinkList;

```
用C实现链表的常用操作：

#### 1. 链表初始化

```C
void InitList(LinkList &H) {
    H = (LNode *)malloc(sizeof(LNode));   //申请一个头结点        
    if (!H)  return ERROR;        
    H->next = NULL;                   //头结点的指针域置空
}
```

#### 2. 重置链表

```C
void ClearList(&L) {
	while (L->next) {
        p = L->next;
        L->next = p->next;
        free(p);       
    }
}
```

#### 3. 单链表的查找

```C
int Search(LinkList H, int e) {
	LinkList p;
	p = H->next;
	while(p) {
		if(p->data == e) return OK;
		else   p = p->next;
	}		
	return ERROR;
}
```

#### 4. 单链表的插入

```C
Status ListInsert(LinkList &L, int i, ElemType e)  // 在单链表L的第i个位置上插入值为e的元素
{
	LinkList p = L;
	int j = 0;
	while(p && j<i-1) {
		p = p->next;
		++j;
	}
	if(!p || j>i-1) {
		return ERROR;
	}
	s = (LinkList)malloc(sizeof(Lnode)); //创建一个新的存储空间
	s->data = e;
	//注意下面两步顺序千万不能写乱，不然会找不到插入前 p 前面的节点
	s->next = p->next;
	p->next = s;
	return OK;
}
```

#### 5. 单链表的删除

```C
Status ListDelete(LinkList &L, int i, ElemType e)
{
	LinkList p = L;
	int j = 0;
    while(p && j < i-1) {
    	p = p->next;
    	++j;
    }
    if(!p || j > i-1) return ERROR;
	q = p->next;
	p->next = q->next;
	e = q->data;
	free(q);
	return OK;
}
```

## 循环链表

将单链表最后一个结点的指针域由NULL改为指向头结点或线性表中的第一个结点，就得到了单链形式的循环链表，称为循环单链表。
![](http://ojzeprg7w.bkt.clouddn.com/%E5%BE%AA%E7%8E%AF%E9%93%BE%E8%A1%A8.JPG)


## 双向链表

循环单链表的出现，虽然能够实现从任一结点出发沿着链能找到其前驱结点，但时间复杂度是O(n) 。如果希望从表中快速确定某一个结点的前驱，另一个解决方法就是在单链表的每个结点里再增加一个指向其前驱的指针域。这样形成的链表中就有两条方向不同的链，称之为双向链表。
![](http://ojzeprg7w.bkt.clouddn.com/%E5%8F%8C%E5%90%91.JPG)
