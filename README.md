# DBXKit

##Chain
* 链条式调用
* 一个任务是一个DBXChainTask实例
* 支持同步和异步任务
* 任务执行成功，就给task.result赋值，失败给task.error赋值，这两个任何一个赋值即表示当前task执行完毕，进入下一个任务
如语音包下载的需求用Chain来完成
需求流程图