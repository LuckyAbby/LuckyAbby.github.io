---
title: "深入setState"
date: 2019-03-09T17:42:51+08:00
tags: ['React','JS']
---

## 例子

对于这样一个例子：
<!--more-->
```js
import React, { Component } from 'react';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0
    };
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.setState({
      count: this.state.count + 1
    });
    this.setState({
      count: this.state.count + 1
    });
  }

  render() {
    return (
      <div className="App">
        <p>
          {this.state.count}
        </p>
        <button onClick={this.handleClick}>Click!</button>
      </div>
    );
  }
}

export default App;
```

对于上述例子，点击按钮之后 count 值只会变成 1，不会变成2，和之前预想的不太一样，究竟 setState 做了什么呢？

文档对于 setState 的解释是：

> setState() does not always immediately update the component. It may batch or defer the update until later. This makes reading this.state right after calling setState() a potential pitfall. Instead, use componentDidUpdate or a setState callback (setState(updater, callback)), either of which are guaranteed to fire after the update has been applied. If you need to set the state based on the previous state, read about the updater argument below.

 setState()并不总是立即更新组件，它可能会进行批处理或者推迟更新。这使得在调用setState（）之后立即读取this.state成为一个可能不符合预期结果的操作。

## 深入源码

### 定义
关于 setState 的定义在这里

```js
ReactComponent.prototype.setState = function(partialState, callback) {
  this.updater.enqueueSetState(this, partialState);
  if (callback) {
    this.updater.enqueueCallback(this, callback, 'setState');
  }
};
```

从这里我们可以看到， enqueueSetState 这个函数才是最终执行的函数，如果 setState 传入了第二个回调函数，则放在 enqueueCallback 这个函数里面去执行。

### enqueueSetState

我们先看 enqueueSetState 这个方法做了什么

```js
enqueueSetState: function(publicInstance, partialState) {
var internalInstance = getInternalInstanceReadyForUpdate(
    publicInstance,
    'setState',
);

var queue =
    internalInstance._pendingStateQueue ||
    (internalInstance._pendingStateQueue = []);
queue.push(partialState);

enqueueUpdate(internalInstance);
},

// ...
```

React在内存中为每一个组件都生成一个内部实例，在 queue 赋值那里可以看到内部实例用于处理状态更新的一个关键数组，_pendingStateQueue（如果不存在，则赋值一个新的空的数组），然后将新的状态推进数组queue中，因此内部实例有了我们想要更新的所有 state 信息。最后关键是调用了 euqueueUpdate(internalInstance)方法。

### enqueueUpdate
```js
function enqueueUpdate(component) {
  ensureInjected();

  if (!batchingStrategy.isBatchingUpdates) {
    batchingStrategy.batchedUpdates(enqueueUpdate, component);
    return;
  }

  dirtyComponents.push(component);
  if (component._updateBatchNumber == null) {
    component._updateBatchNumber = updateBatchNumber + 1;
  }
}

```

这才是批处理的核心，说的是
如果现在 isBatchingUpdates 为 true 时，即已经处于批量更新模式，只是将需要更新的 component 添加到 dirtyComponents（dirtyComponents是一个用于存储『脏组件』的数组，所谓的脏组件，就是组件的一些属性发生了变动，但是还没有将新属性更新到视图的组件。）数组中；
如果为 false, 不处于批量更新模式，对所有队列中的更新执行 batchedUpdates 方法。

但是其实我们现在已经处于一个批量更新的模式中了，到目前为止，也没发现 setState 在哪里更新了数据，总结一下 setState 做的事情就是：

**根据当前组件实例获取 React 的内部实例，将新的状态放到 _pendingStateQueue 队列中，然后调用 enqueueUdate 方法。如果当前React更新组件的策略不处于更新状态，则执行策略的 batchedUpdates 方法，否则将当前内部实例放到一个 dirtyComponents 的数组中**。

但是状态肯定是在某处更新了，推测应该是在 handleClick 的某处更新了，打印一下 handleClick 的调用栈，发现有一个 batchedUpdates 方法，刚好之前在上面那段代码里面也出现了，我们来看一下这个代码。

### batchedUpdates

这里面 ReactDefaultBatchingStrategy 应该就是 React 默认的批更新策略。
```js
var ReactDefaultBatchingStrategy = {
  isBatchingUpdates: false,

  batchedUpdates: function(callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;

    ReactDefaultBatchingStrategy.isBatchingUpdates = true;

    if (alreadyBatchingUpdates) {
      return callback(a, b, c, d, e);
    } else {
      return transaction.perform(callback, null, a, b, c, d, e);
    }
  },
};

module.exports = ReactDefaultBatchingStrategy;
```
在这里我们可以看到，有一个全局默认的 isBatchingUpdates 为 false，从 euqueueUpdate 方法里面的可以看到如果不处于批量更新模式中的话，执行 batchUpdates 方法，进行 batchedUpdates 可以看到全局的 isBatchingUpdates被设置为 true, 然后执行 transcation 事务的 perform 方法。

## transcation

batchUpdate 的功能都是通过 transaction 实现的。事务如下图所示。

```
/**
 *                       wrappers (injected at creation time)
 *                                      +        +
 *                                      |        |
 *                    +-----------------|--------|--------------+
 *                    |                 v        |              |
 *                    |      +---------------+   |              |
 *                    |   +--|    wrapper1   |---|----+         |
 *                    |   |  +---------------+   v    |         |
 *                    |   |          +-------------+  |         |
 *                    |   |     +----|   wrapper2  |--------+   |
 *                    |   |     |    +-------------+  |     |   |
 *                    |   |     |                     |     |   |
 *                    |   v     v                     v     v   | wrapper
 *                    | +---+ +---+   +---------+   +---+ +---+ | invariants
 * perform(anyMethod) | |   | |   |   |         |   |   | |   | | maintained
 * +----------------->|-|---|-|---|-->|anyMethod|---|---|-|---|-|-------->
 *                    | |   | |   |   |         |   |   | |   | |
 *                    | |   | |   |   |         |   |   | |   | |
 *                    | |   | |   |   |         |   |   | |   | |
 *                    | +---+ +---+   +---------+   +---+ +---+ |
 *                    |  initialize                    close    |
 *                    +-----------------------------------------+
 */
```

>简单地说，一个所谓的 Transaction 就是将需要执行的 method 使用 wrapper 封装起来，再通过 Transaction 提供的 perform 方法执行。而在 perform 之前，先执行所有 wrapper 中的 initialize 方法；perform 完成之后（即 method 执行后）再执行所有的 close 方法。一组 initialize 及 close 方法称为一个 wrapper，从上面的示例图中可以看出 Transaction 支持多个 wrapper 叠加。

具体到状态更新的事务时，处理 handleClick 和 setState 就在最中间的 anyMethod 那里被执行，但是状态的更新却是在某个 wrapper 的 close 时被执行。

这就是为什么 setState 之后无法立刻获取到最新的状态的原因了，因为最新的状态一直到事务的目标函数执行结束，都只存在 _pendingStateQueue中，直到某个wrapper 执行 close 时才真正被更新。

其实从点击事件开始，React 就会启动默认的组件更新策略（ReactDefaultBatchingStrategy），该策略有一个事务ReactDefaultBatchingStrategyTransaction， 我们看一下这个事务，在和上面的更新策略一个 ReactDefaultBatchingStrategy.js 文件中。

```js
var RESET_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: function () {
    ReactDefaultBatchingStrategy.isBatchingUpdates = false;
  }
};

var FLUSH_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: ReactUpdates.flushBatchedUpdates.bind(ReactUpdates)
};

var TRANSACTION_WRAPPERS = [FLUSH_BATCHED_UPDATES, RESET_BATCHED_UPDATES];

function ReactDefaultBatchingStrategyTransaction() {
  this.reinitializeTransaction();
}

_assign(ReactDefaultBatchingStrategyTransaction.prototype, Transaction, {
  getTransactionWrappers: function () {
    return TRANSACTION_WRAPPERS;
  }
});

var transaction = new ReactDefaultBatchingStrategyTransaction();

//  下面相同
var ReactDefaultBatchingStrategy = {
  isBatchingUpdates: false,

  batchedUpdates: function (callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;

    ReactDefaultBatchingStrategy.isBatchingUpdates = true;

    if (alreadyBatchingUpdates) {
      return callback(a, b, c, d, e);
    } else {
      return transaction.perform(callback, null, a, b, c, d, e);
    }
  }
};

module.exports = ReactDefaultBatchingStrategy;

```

这里面包含了两个wrapper，是 RESET_BATCHED_UPDATES和 FLUSH_BATCHED_UPDATES，通过合并，两个事务的close 方法，将在 enqueueUpdate 执行结束后，先把 isBatchingUpdates 复位，再发起一个批更新。这里  FLUSH_BATCHED_UPDATES 的 close 方法就是批更新。我们着重看一下，是 ReactUpdates.flushBatchedUpdates，我们看一下。

```js
var flushBatchedUpdates = function () {
  while (dirtyComponents.length || asapEnqueued) {
    if (dirtyComponents.length) {
      var transaction = ReactUpdatesFlushTransaction.getPooled();
      transaction.perform(runBatchedUpdates, null, transaction);
      ReactUpdatesFlushTransaction.release(transaction);
    }

    if (asapEnqueued) {
      asapEnqueued = false;
      var queue = asapCallbackQueue;
      asapCallbackQueue = CallbackQueue.getPooled();
      queue.notifyAll();
      CallbackQueue.release(queue);
    }
  }
};
```
flushBatchedUpdates 这个方法里面 会检测dirtyComponents的长度，如果存在脏组件，就会对其进行真正的状态更新。

到这里，我们梳理一下上面的几步
- 最开始，点击事件处于一个默认事务中，isBatchingUpdates 为 true
- 调用 setState 时， isBatchingUpdates 已经是 true 了，将拥有更新状态的内部实例都统一 push 到 dirtyComponents 中
- 事务结束时，通过 close 里面的 ReactUpdates.flushBatchedUpdates 方法更新最新的状态。


## 非事件导致的更新

```
sconstructor(props) {
  super(props);
  this.state = {
    count: 0
  };
}
componentDidMount() {
  setTimeout(() => {
    this.setState({
      count: this.state.count + 1
    });
    console.log(this.state.count);
    this.setState({
      count: this.state.count + 1
    });
    console.log(this.state.count);
  }, 1000);
}
```
对于上面的代码，最终会导致 count 变成2，那这个 setState 又是如何变成“同步”执行的呢？

```js
if (!batchingStrategy.isBatchingUpdates) {
    batchingStrategy.batchedUpdates(enqueueUpdate, component);
    return;
  }
```
如上面代码，之前我们提到如果此时 isBatchingUpdates 为 false,即不处于批量更新模式中，会执行  batchingStrategy.batchedUpdates 这个方法。
```js
 batchedUpdates: function(callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;

    ReactDefaultBatchingStrategy.isBatchingUpdates = true;

    if (alreadyBatchingUpdates) {
      return callback(a, b, c, d, e);
    } else {
      return transaction.perform(callback, null, a, b, c, d, e);
    }
  },
```
在这个方法里面，我们可以看到 isBatchingUpdates 为 false,就会执行 transaction.perform 这个方法，因此可以看到此时 setState 只是唤起了一次批量更新而已，然后在这个 perform 里面将内部实例传进去去执行 enqueueUpdate 方法。等到这个 setState 之行结束之后这个事务就结束了，再次执行 setState 又得重新唤起一次批量更新模式，因此表现的像同步。

因此总结一下 setState，可以得到如下结论：

- React的批量更新模式已经被启动时（事件触发时），表现的类似于异步：
  React响应事件处理 => 启动更新策略事务（绑定了wrapper） => 事务perform => **setState => 获取内部实例 => 存储新的状态 => 发现更新策略事务已启动 => 将当前内部实例放入脏组件数组 => setState执行结束** => 更新策略事务perform完毕 => wrapper处理组件状态的更新
- React的批量更新模式没有被启动时（异步触发时），表现的类似于同步：
  **setState => 获取内部实例 => 存储新的状态 => 发现更新策略事务未启动 => 启动更新策略事务（绑定了wrapper） => 事务perform => 将当前内部实例放入脏组件数组 => 更新策略事务perform完毕 => wrapper处理组件状态的更新 => setState执行结束**

因此不能说 setState 究竟是异步还是同步，还是得具体分析情况。