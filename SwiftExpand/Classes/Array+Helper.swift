
//
//  NSArray+Helper.swift
//  SwiftTemplet
//
//  Created by Bin Shang on 2018/9/6.
//  Copyright © 2018年 BN. All rights reserved.
//



public extension Array{
    
    /// ->Data
    var jsonData: Data? {
        return (self as NSArray).jsonData;
    }
    
    /// ->String
    var jsonString: String {
        return (self as NSArray).jsonString;
    }
    
    /// 快速生成一个数组(step代表步长)
    init(count: Int, generator: @escaping ((Int)->Element)) {
        var list: [Element] = [];
        for i in 0..<count {
            list.append(generator(i))
        }
        self = list
    }
    
    ///同 subarrayWithRange:
    func subarray(_ range: NSRange) -> Array {
        return self.subarray(range.location, range.length)
    }
    ///同 subarrayWithRange:
    func subarray(_ loc: Int, _ len: Int) -> Array {
        assert((loc + len) <= self.count);
        return Array(self[loc...len]);
    }
}

public extension Array where Element == CGFloat{
    var sum: CGFloat {
        return self.reduce(0, +)
    }
    
    ///获取数组期望值
    var expectationValue: CGFloat {
        var dic = [CGFloat : Int]()
        let set = Set(self)
        
        for value in set {
            let filterArray = self.filter { $0 == value }
            dic[value] = filterArray.count
        }
//        DDLog(dic)
        
        let sum = dic.keys.map { $0 }.reduce(0, +)
//        DDLog(sum)
        
        var percentDic = [CGFloat: CGFloat]()
        set.forEach { (obj) in
            percentDic[obj] = CGFloat(obj/sum)
        }
//        DDLog(percentDic)
        
        var expectation: CGFloat = 0.0
        percentDic.forEach { (key: CGFloat, value: CGFloat) in
            expectation += key * value
        }
        DDLog("数组:\(self)\n各元素出现次数: \(dic)\n各元素出现概率: \(percentDic)\n总和: \(sum)\n期望值是: \(expectation)")
        return expectation
    }
    
}


public extension Array where Element : NSObject {
    ///嵌套数组扁平化
    func flatModels(_ childKey: String = "children") -> [Element] {
        ///内部函数
        func recursionModel(_ model: Element, list: inout [Element]) {
            guard let children = model.value(forKey: childKey) as? [Element] else { return }
            children.forEach { (child) in
                list.append(child)
                
                if let _ = child.value(forKey: childKey) as? [Element] {
                    recursionModel(child, list: &list)
                }
            }
        }
                        
        var list = [Element]()
        self.forEach { (model) in
            list.append(model)
            recursionModel(model, list: &list)
        }
        return list;
    }
}

public extension Array where Element : View{
    
    ///更新 NSButton 集合视图
    func updateItemsConstraint(_ rect: CGRect, numberOfRow: Int = 4, padding: CGFloat = kPadding, edge: EdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        if self.count == 0 || Swift.min(rect.width, rect.height) <= 0 {
            return;
        }
        
        let rowCount = self.count % numberOfRow == 0 ? self.count/numberOfRow : self.count/numberOfRow + 1;
        let itemWidth = (rect.width - edge.left - edge.right - CGFloat(numberOfRow - 1)*padding)/CGFloat(numberOfRow)
        let itemHeight = (rect.height - edge.top - edge.bottom - CGFloat(rowCount - 1)*padding)/CGFloat(rowCount)
        
        for e in self.enumerated() {
            let x = CGFloat(e.offset % numberOfRow) * (itemWidth + padding)
            let y = CGFloat(e.offset / numberOfRow) * (itemHeight + padding)
            let rect = CGRect(x: x, y: y, width: ceil(itemWidth), height: itemHeight)
            
            let sender = e.element;
            sender.frame = rect;
        }
    }
    
}


@objc public extension NSArray{

    /// ->Data
    var jsonData: Data? {
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: self, options: []);
        } catch {
            print(error)
        }
        return data;
    }
    
    /// ->NSString
    var jsonString: String {
        guard let jsonData = self.jsonData as Data?,
        let jsonString = String(data: jsonData, encoding: .utf8) as String?
        else { return "" }
        return jsonString
    }

    /// 快速生成一个数组
    static func generate(count: Int, generator: @escaping ((Int)->Element)) -> NSArray {
        return Array.init(count: count, generator: generator) as NSArray;
    }
    
    ///获取数组期望值
    var expectationValue: CGFloat {
        if self.count == 0 {
            return 0.0
        }
        
        if let list = self as? [NSNumber] {
            let array = list.map({ CGFloat($0.floatValue) })
            return array.expectationValue
        }
        
        if let list = self as? [NSString] {
            let array = list.map({ CGFloat($0.floatValue) })
            return array.expectationValue
        }
        return 0.0
    }
}