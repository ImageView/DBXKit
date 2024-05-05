# DBXKit

自动上报
点击按钮button1，找到按钮所在的ViewController，即vc1
通过vc1确定button的路径，如：view/button2;


DBXAutoReportManager
中心管理类，包括是否启动自动上报功能，设置上报配置，hook相应方法等

DBXARUtils
工具类，生成view的路径，reportID等

UIGestureRecognizer+DBXAR.h
hook UIGestureRecognizer的实现，交换相应方法，以便在手势中添加一对额外的target/action用于上报

DBXGestureTarget
用于额外上报的事件，DBXGestureTarget即添加的这个target

UIControl的点击
UIControl的点击都会走到UIApplication 的sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event，因此hook掉这个方法就可以
获取到UIControl的target和对应的action，拼接起来作为reportID
上报配置以reportID作为key，上报参数作为value，读取对应的reportID，如果对应的reportID存在，则进行上报
上报功能抽象出来，需要实现对应的协议DBXAutoReportImpl

UIGestureRecognizer手势点击事件
hook手势的初始化initWithTarget:(id)target action:(SEL)action和addTarget:(id)target action:(SEL)action方法，hook之后新添加一对自行实现的target/action，在手势被触发时会同时触发新添加的这对target/action，在其中进行数据上报
手势同样将target/action拼接作为reportID
