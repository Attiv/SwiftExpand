# SwiftExpand

Swift 的 SDK 功能扩展,提高工作效率, 低耦合(Objective-C && Swift, iOS && macOS)

## Usage

### Runtime方法封装

```
@objc public extension NSObject{

    ///遍历成员变量列表
    func enumerateIvars(_ block: @escaping ((Ivar, String, Any?)->Void)) {
        var count: UInt32 = 0
        guard let list = class_copyIvarList(self.classForCoder, &count) else { return }
        defer {
            free(list)// 释放c语言对象
        }

        for i in 0..<Int(count) {
            let ivar = list[i]
            guard let ivarName = ivar_getName(ivar),
                  let name = String(utf8String: ivarName) else {
                continue
            }
            //利用kvc 取值
            let value = self.value(forKey: name)
            block(ivar, name, value)
        }
    }
    ///遍历属性列表
    func enumeratePropertys(_ block: @escaping ((objc_property_t, String, Any?)->Void)) {
        var count: UInt32 = 0
        guard let list = class_copyPropertyList(self.classForCoder, &count) else { return }
        defer {
            free(list)// 释放c语言对象
        }
        
        for i in 0..<Int(count) {
            let property: objc_property_t = list[i]
            //获取成员变量的名称 -> c语言字符串
            let pname = property_getName(property)
            //转换成String字符串
            guard let name = String(utf8String: pname) else {
                continue
            }
            //利用kvc 取值
            let value = self.value(forKey: name)
            block(property, name, value)
        }
    }
    ///遍历方法列表
    func enumerateMethods(_ block: @escaping ((Method, String)->Void)) {
        var count: UInt32 = 0
        guard let list = class_copyMethodList(self.classForCoder, &count) else { return }
        defer {
            free(list)// 释放c语言对象
        }

        for i in 0..<Int(count) {
            let method: Method = list[i]
            //获取成员变量的名称 -> c语言字符串
            let sel: Selector = method_getName(method)
            //转换成String字符串
            let name = NSStringFromSelector(sel)
            block(method, name)
        }
    }
    ///遍历遵循的协议列表
    func enumerateProtocols(_ block: @escaping ((Protocol, String)->Void)) {
        var count: UInt32 = 0
        guard let list = class_copyProtocolList(self.classForCoder, &count) else { return }

        for i in 0..<Int(count) {
            let proto: Protocol = list[i]
            //获取成员变量的名称 -> c语言字符串
            let pname = protocol_getName(proto)
            guard let name = String(utf8String: pname) else {
                continue
            }
            block(proto, name)
        }
    }

    /// 模型自动编码
    func se_encode(with aCoder: NSCoder) {
        enumeratePropertys { (property, name, value) in
            guard let value = self.value(forKey: name) else { return }
            //进行编码
            aCoder.encode(value, forKey: name)
        }
    }
    
    /// 模型自动解码
    func se_decode(with aDecoder: NSCoder) {
        enumeratePropertys { (property, name, value) in
            //进行解档取值
            guard let value = aDecoder.decodeObject(forKey: name) else { return }
            //利用kvc给属性赋值
            self.setValue(value, forKeyPath: name)
        }
    }
    /// 字典转模型
    convenience init(dic: [String: Any]) {
        self.init()
        self.setValuesForKeys(dic)
    }
    ///详情模型转字典(不支持嵌套)
    func toDictionary() -> [AnyHashable : Any] {
        var dic: [AnyHashable : Any] = [:]
        self.enumeratePropertys { (property, name, value) in
            dic[name] = value ?? ""
        }
        return dic
    }
    
    func synchronized(_ lock: AnyObject, block: () -> Void) {
        objc_sync_enter(lock)
        block()
        objc_sync_exit(lock)
    }
            
    // MARK: - KVC

    /// 返回key对应的值
    func valueText(forKey key: String, defalut: String = "-") -> String{
        if key == "" {
            return ""
        }
        if let result = self.value(forKey: key) {
            return "\(result)" != "" ? "\(result)" : defalut
        }
        return defalut
    }
    /// 返回key对应的值
    func valueText(forKeyPath keyPath: String, defalut: String = "-") -> String{
        if keyPath == "" {
            return ""
        }
        if let result = self.value(forKeyPath: keyPath) {
            return "\(result)" != "" ? "\(result)" : defalut
        }
        return defalut
    }

}
```

### 反射方法封装 NNClassFromString

    //get class by name
    public func NNClassFromString(_ name: String) -> AnyClass? {
        if let cls = NSClassFromString(name) {
    //        print("✅_Objc类存在: \(name)")
            return cls;
         }
         
         let swiftClassName = "\(UIApplication.appBundleName).\(name)";
         if let cls = NSClassFromString(swiftClassName) {
    //         print("✅_Swift类存在: \(swiftClassName)")
             return cls;
         }
         print("❌_类不存在: \(name)")
        return nil;
    }

### 反射方法封装 UICtrFromString

    /// get UIViewController by name
    public func UICtrFromString(_ vcName: String) -> UIViewController {
        let cls: AnyClass = NNClassFromString(vcName)!;
        // 通过类创建对象， 不能用cls.init(),有的类可能没有init方法
        // 需将cls转换为制定类型
        let vcCls = cls as! UIViewController.Type;
        // 创建对象
        let controller: UIViewController = vcCls.init();
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return controller;
    }

### 重构 UITableViewCell

    /// custom - UITableViewCell
    class UITableViewCellOne: UITableViewCell {}
    
    /// Reusable
    let cell = UITableViewCellOne.dequeueReusableCell(tableView)

    /// custom - UITableViewHeaderFooterView
    class UITableHeaderFooterViewZero: UITableViewHeaderFooterView {}

    /// Reusable
    let view = UITableHeaderFooterViewZero.dequeueReusableHeaderFooterView(tableView)

### 重构 UICollectionViewCell

    ctView.dictClass = [UICollectionView.elementKindSectionHeader: ["UICTReusableViewOne",],
                        UICollectionView.elementKindSectionFooter: ["UICTReusableViewZero",],
                        UICollectionView.elementKindSectionItem: ["UICTViewCellZero","UICTViewCellOne"],]
                        
    /// custom - UICollectionViewCell
    class UICTViewCellOne: UICollectionViewCell { )   
    /// Reusable
    let cell = collectionView.dequeueReusableCell(for: UICTViewCellZero.self, indexPath: indexPath)
    
    /// custom - UICollectionReusableView
    class UICTViewCellOne: UICollectionReusableView { )  
    /// Reusable
    let view = collectionView.dequeueReusableSupplementaryView(for: UICTReusableViewOne.self, kind: kind, indexPath: indexPath)

### 封装 DateFormatter

    @objc public extension DateFormatter{
    /// 获取DateFormatter(默认格式)
    static func format(_ formatStr: String = kDateFormat) -> DateFormatter {
        let dic = Thread.current.threadDictionary;
        if dic.object(forKey: formatStr) != nil {
            return dic.object(forKey: formatStr) as! DateFormatter;
        }
        
        let fmt = DateFormatter();
        fmt.dateFormat = formatStr;
        fmt.locale = .current;
        fmt.locale = Locale(identifier: "zh_CN");
        fmt.timeZone = formatStr.contains("GMT") ? TimeZone(identifier: "GMT") : TimeZone.current;
        
        dic.setObject(fmt, forKey: formatStr as NSCopying)
        return fmt;
    }
    
    /// Date -> String
    static func stringFromDate(_ date: Date, fmt: String = kDateFormat) -> String {
        let formatter = DateFormatter.format(fmt);
        return formatter.string(from: date);
    }
    
    /// String -> Date
    static func dateFromString(_ dateStr: String, fmt: String = kDateFormat) -> Date {
        let formatter = DateFormatter.format(fmt);
        return formatter.date(from: dateStr)!;
    }
    
    /// 时间戳字符串 -> 日期字符串
    static func stringFromInterval(_ interval: String, fmt: String = kDateFormat) -> String {
        let date = Date(timeIntervalSince1970: interval.doubleValue)
        return DateFormatter.stringFromDate(date, fmt: fmt);
    }

    /// 日期字符串 -> 时间戳字符串
    static func intervalFromDateStr(_ dateStr: String, fmt: String = kDateFormat) -> String {
        let date = DateFormatter.dateFromString(dateStr, fmt: fmt)
        return "\(date.timeIntervalSince1970)";
    }

### 重构 UIBarButtonItem 事件转回调

    @objc extension UIBarButtonItem{
        private struct AssociateKeys {
        static var systemType = "UIBarButtonItem" + "systemType"
        static var closure = "UIBarButtonItem" + "closure"
    }
    /// UIBarButtonItem 回调
    public func addAction(_ closure: @escaping ((UIBarButtonItem) -> Void)) {
        objc_setAssociatedObject(self, &AssociateKeys.closure, closure, .OBJC_ASSOCIATION_COPY_NONATOMIC);
        target = self;
        action = #selector(p_invoke);
    }
    
    private func p_invoke() {
        if let closure = objc_getAssociatedObject(self, &AssociateKeys.closure) as? ((UIBarButtonItem) -> Void) {
            closure(self);
        }
    }
}

### 呈现方法封装 UIViewController

    @objc public extension UIViewController {
    
        /// 呈现    
        func present(_ animated: Bool = true, completion: (() -> Void)? = nil) {
            guard let keyWindow = UIApplication.shared.keyWindow,
                  let rootVC = keyWindow.rootViewController
                  else { return }
            if let presentedViewController = rootVC.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
            
            self.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                switch self {
                case let alertVC as UIAlertController:
                    if alertVC.preferredStyle == .alert {
                        if alertVC.actions.count == 0 {
                            rootVC.present(alertVC, animated: animated, completion: {
                                DispatchQueue.main.after(TimeInterval(kDurationToast), execute: {
                                    alertVC.dismiss(animated: animated, completion: completion)
                                })
                            })
                            return
                        }
                        rootVC.present(alertVC, animated: animated, completion: completion)
                    } else {
                        //防止 ipad 下 sheet 会崩溃的问题
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            if let controller = alertVC.popoverPresentationController {
                                controller.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                                controller.sourceView = keyWindow;
                                
                                let isEmpty = controller.sourceRect.equalTo(.null) || controller.sourceRect.equalTo(.zero)
                                if isEmpty {
                                    controller.sourceRect = CGRect(x: keyWindow.bounds.midX, y: 64, width: 1, height: 1);
                                }
                            }
                        }
                        rootVC.present(alertVC, animated: animated, completion: completion)
                    }
                    
                default:
                    rootVC.present(self, animated: animated, completion: completion)
                }
            }
        } 
        ///判断上一页是哪个页面
        public func pushFromVC(_ type: UIViewController.Type) -> Bool {
            
            guard let viewControllers = navigationController?.viewControllers else {
                return false }
            if viewControllers.count <= 1 {
                return false }
            guard let index = viewControllers.firstIndex(of: self) else {
                return false }
            let result = viewControllers[index - 1].isKind(of: type)
            return result
        }
    } 

### 重构 UIView 手势方法

    @objc public extension UIView {
        ///手势 - 轻点 UITapGestureRecognizer
        @discardableResult
        func addGestureTap(_ target: Any?, action: Selector?) -> UITapGestureRecognizer {
            let obj = UITapGestureRecognizer(target: target, action: action)
            obj.numberOfTapsRequired = 1  //轻点次数
            obj.numberOfTouchesRequired = 1  //手指个数
    
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
            return obj
        }
        
        ///手势 - 轻点 UITapGestureRecognizer
        @discardableResult
        func addGestureTap(_ action: @escaping ((UITapGestureRecognizer) ->Void)) -> UITapGestureRecognizer {
            let obj = UITapGestureRecognizer(target: nil, action: nil)
            obj.numberOfTapsRequired = 1  //轻点次数
            obj.numberOfTouchesRequired = 1  //手指个数
    
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
    
            obj.addAction(action)
            return obj
        }
        
        ///手势 - 长按 UILongPressGestureRecognizer
        @discardableResult
        func addGestureLongPress(_ target: Any?, action: Selector?, for minimumPressDuration: TimeInterval) -> UILongPressGestureRecognizer {
            let obj = UILongPressGestureRecognizer(target: target, action: action)
            obj.minimumPressDuration = minimumPressDuration;
          
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
            return obj
        }
        
        ///手势 - 长按 UILongPressGestureRecognizer
        @discardableResult
        func addGestureLongPress(_ action: @escaping ((UILongPressGestureRecognizer) ->Void), for minimumPressDuration: TimeInterval) -> UILongPressGestureRecognizer {
            let obj = UILongPressGestureRecognizer(target: nil, action: nil)
            obj.minimumPressDuration = minimumPressDuration;
          
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
          
            obj.addAction { (recognizer) in
                action(recognizer as! UILongPressGestureRecognizer)
            }
            return obj
        }
          
        ///手势 - 拖拽 UIPanGestureRecognizer
        @discardableResult
        func addGesturePan(_ action: @escaping ((UIPanGestureRecognizer) ->Void)) -> UIPanGestureRecognizer {
            let obj = UIPanGestureRecognizer(target: nil, action: nil)
              //最大最小的手势触摸次数
            obj.minimumNumberOfTouches = 1
            obj.maximumNumberOfTouches = 3
              
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
              
            obj.addAction { (recognizer) in
                if let gesture = recognizer as? UIPanGestureRecognizer {
                    let translate: CGPoint = gesture.translation(in: gesture.view?.superview)
                    gesture.view!.center = CGPoint(x: gesture.view!.center.x + translate.x, y: gesture.view!.center.y + translate.y)
                    gesture.setTranslation( .zero, in: gesture.view!.superview)
                                 
                    action(gesture)
                }
            }
            return obj
        }
          
        ///手势 - 屏幕边缘 UIScreenEdgePanGestureRecognizer
        @discardableResult
        func addGestureEdgPan(_ target: Any?, action: Selector?, for edgs: UIRectEdge) -> UIScreenEdgePanGestureRecognizer {
            let obj = UIScreenEdgePanGestureRecognizer(target: target, action: action)
            obj.edges = edgs
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
            return obj
        }
        
        ///手势 - 屏幕边缘 UIScreenEdgePanGestureRecognizer
        @discardableResult
        func addGestureEdgPan(_ action: @escaping ((UIScreenEdgePanGestureRecognizer) ->Void), for edgs: UIRectEdge) -> UIScreenEdgePanGestureRecognizer {
            let obj = UIScreenEdgePanGestureRecognizer(target: nil, action: nil)
            obj.edges = edgs
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
           
            obj.addAction { (recognizer) in
                action(recognizer as! UIScreenEdgePanGestureRecognizer)
            }
            return obj
        }
          
        ///手势 - 清扫 UISwipeGestureRecognizer
        @discardableResult
        func addGestureSwip(_ target: Any?, action: Selector?, for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
            let obj = UISwipeGestureRecognizer(target: target, action: action)
            obj.direction = direction
          
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
            return obj
        }
        
        ///手势 - 清扫 UISwipeGestureRecognizer
        @discardableResult
        func addGestureSwip(_ action: @escaping ((UISwipeGestureRecognizer) ->Void), for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
            let obj = UISwipeGestureRecognizer(target: nil, action: nil)
            obj.direction = direction
          
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
          
            obj.addAction { (recognizer) in
                action(recognizer as! UISwipeGestureRecognizer)
            }
            return obj
        }
          
        ///手势 - 捏合 UIPinchGestureRecognizer
        @discardableResult
        func addGesturePinch(_ action: @escaping ((UIPinchGestureRecognizer) ->Void)) -> UIPinchGestureRecognizer {
            let obj = UIPinchGestureRecognizer(target: nil, action: nil)
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
          
            obj.addAction { (recognizer) in
                if let gesture = recognizer as? UIPinchGestureRecognizer {
                    let location = recognizer.location(in: gesture.view!.superview)
                    gesture.view!.center = location;
                    gesture.view!.transform = gesture.view!.transform.scaledBy(x: gesture.scale, y: gesture.scale)
                    gesture.scale = 1.0
                    action(gesture)
                }
            }
            return obj
        }
        
        ///手势 - 旋转 UIRotationGestureRecognizer
        @discardableResult
        func addGestureRotation(_ action: @escaping ((UIRotationGestureRecognizer) ->Void)) -> UIRotationGestureRecognizer {
            let obj = UIRotationGestureRecognizer(target: nil, action: nil)
            isUserInteractionEnabled = true
            isMultipleTouchEnabled = true
            addGestureRecognizer(obj)
          
            obj.addAction { (recognizer) in
                if let gesture = recognizer as? UIRotationGestureRecognizer {
                    gesture.view!.transform = gesture.view!.transform.rotated(by: gesture.rotation)
                    gesture.rotation = 0.0;
                              
                    action(gesture)
                }
            }
            return obj
        }
    }
    
    extension Array where Element : UIView {
        ///手势 - 轻点 UITapGestureRecognizer
        @discardableResult
        public func addGestureTap(_ action: @escaping RecognizerClosure) -> [UITapGestureRecognizer] {
            
            var list = [UITapGestureRecognizer]()
            forEach {
                let obj = $0.addGestureTap(action)
                list.append(obj)
            }
            return list
        }
    }

### 重构 UIControl 事件转回调

    @objc extension UIControl {
        private struct AssociateKeys {
            static var closure   = "UIControl" + "closure"
        }
        /// UIControl 添加回调方式
        public func addActionHandler(_ action: @escaping ControlClosure, for controlEvents: UIControl.Event = .touchUpInside) {
            addTarget(self, action:#selector(p_handleAction(_:)), for:controlEvents);
            objc_setAssociatedObject(self, &AssociateKeys.closure, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        /// 点击回调
        private func p_handleAction(_ sender: UIControl) {
            if let block = objc_getAssociatedObject(self, &AssociateKeys.closure) as? ControlClosure {
                block(sender);
            }
        }
    }

### 重构 NSAttributedString 链式编程实现

    ///属性链式编程实现
    @objc public extension NSAttributedString {
            
        func addAttributes(_ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
            let mattr = NSMutableAttributedString(attributedString: self)
            mattr.addAttributes(attributes, range: NSMakeRange(0, self.length))
            return mattr
        }
        
        func font(_ font: UIFont) -> NSAttributedString {
            return addAttributes([NSAttributedString.Key.font: font])
        }
        
        func color(_ color: UIColor) -> NSAttributedString {
            return addAttributes([NSAttributedString.Key.foregroundColor: color])
        }
        
        func bgColor(_ color: UIColor) -> NSAttributedString {
            return addAttributes([NSAttributedString.Key.backgroundColor: color])
        }
        
        func link(_ value: String) -> NSAttributedString {
            return linkURL(URL(string: value)!)
        }
        
        func linkURL(_ value: URL) -> NSAttributedString {
            return addAttributes([NSAttributedString.Key.link: value])
        }
        //设置字体倾斜度，取值为float，正值右倾，负值左倾
        func oblique(_ value: CGFloat = 0.1) -> NSAttributedString {
            return addAttributes([NSAttributedString.Key.obliqueness: value])
        }
           
        //字符间距
        func kern(_ value: CGFloat) -> NSAttributedString {
            return addAttributes([.kern: value])
        }
        
        //设置字体的横向拉伸，取值为float，正值拉伸 ，负值压缩
        func expansion(_ value: CGFloat) -> NSAttributedString {
            return addAttributes([.expansion: value])
        }
        
        //设置下划线
        func underline(_ color: UIColor, _ style: NSUnderlineStyle = .single) -> NSAttributedString {
            return addAttributes([
                .underlineColor: color,
                .underlineStyle: style.rawValue
            ])
        }
        
        //设置删除线
        func strikethrough(_ color: UIColor, _ style: NSUnderlineStyle = .single) -> NSAttributedString {
            return addAttributes([
                .strikethroughColor: color,
                .strikethroughStyle: style.rawValue,
            ])
        }
        
        ///设置基准位置 (正上负下)
        func baseline(_ value: CGFloat) -> NSAttributedString {
            return addAttributes([.baselineOffset: value])
        }
        
        ///设置段落
        func paraStyle(_ alignment: NSTextAlignment,
                              lineSpacing: CGFloat = 0,
                              paragraphSpacingBefore: CGFloat = 0,
                              lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> NSAttributedString {
            let style = NSMutableParagraphStyle()
            style.alignment = alignment
            style.lineBreakMode = lineBreakMode
            style.lineSpacing = lineSpacing
            style.paragraphSpacingBefore = paragraphSpacingBefore
            return addAttributes([.paragraphStyle: style])
        }
            
        ///设置段落
        func paragraphStyle(_ style: NSMutableParagraphStyle) -> NSAttributedString {
            return addAttributes([.paragraphStyle: style])
        }
    }
    
    public extension String {
    
        /// -> NSAttributedString
        var attributed: NSAttributedString{
            return NSAttributedString(string: self)
        }
    }

### UIImage 加载 gif (<https://github.com/kiritmodi2702/GIF-Swift/blob/master/GIF-Swift/iOSDevCenters%2BGIF.swift>)

- `UIImage.gifImageWithName("Name")`
- `gifImageWithData(gifData)`
- `UIImage.gifImageWithURL(gifURL)`

### 延时执行

- `VTUtil.delayExecution(seconds: Double, closure: @escaping () -> Void)`

### 通知

```
var observer: NotificationObserver = .init()
observer.addObserver(forName: Name) { notification in
 // your handle
}
```

## Requirements

    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.13'
    
    s.swift_version = "5"

## Author

shang1219178163, <shang1219178163@gmail.com>

## License

SwiftExpand is available under the MIT license. See the LICENSE file for more info.
