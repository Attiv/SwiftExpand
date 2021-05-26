//
//  CALayer+Helper.swift
//  SwiftTemplet
//
//  Created by Bin Shang on 2019/1/15.
//  Copyright © 2019 BN. All rights reserved.
//

import Cocoa

@objc public extension CALayer{
    /// [源]创建 CALayer
    static func create(_ rect: CGRect = .zero, contents: Any?) -> Self {
        let layer = self.init()
        layer.frame = rect
        layer.contents = contents
//        layer.contentsScale = NSScreen.main.scale
//        layer.rasterizationScale = NSScreen.main.scale
        layer.shouldRasterize = true
        return layer
    }
    /// 线条位置
    func rectWithLine(type: Int = 0, width: CGFloat = 0.8, paddingScale: CGFloat = 0) -> CGRect {
        var rect = CGRect.zero;
        switch type {
        case 1://左边框
            let paddingY = bounds.height*paddingScale;
            rect = CGRectMake(0, paddingY, bounds.width, bounds.height - paddingY*2)
            
        case 2://下边框
            let paddingX = bounds.width*paddingScale;
            rect = CGRectMake(paddingX, bounds.height - width, bounds.width - paddingX*2, width)
            
        case 3://右边框
            let paddingY = bounds.height*paddingScale;
            rect = CGRectMake(bounds.width - width, paddingY, bounds.width, bounds.height - paddingY*2)
            
        default: //上边框
            let paddingX = bounds.width*paddingScale;
            rect = CGRectMake(paddingX, 0, bounds.width - paddingX*2, width)
        }
        return rect;
    }
    /// 创建CALayer 线条
    func createLayer(type: Int = 0, color: NSColor = NSColor.line, width: CGFloat = 0.8, paddingScale: CGFloat = 0) -> CALayer {
        let linView = CALayer()
        linView.backgroundColor = color.cgColor;
        linView.frame = self.rectWithLine(type: type, width: width, paddingScale: paddingScale);
        return linView;
    }
    /// 控制器切换渐变动画
    func addAnimationFade(_ duration: CFTimeInterval = 0.15, functionName: CAMediaTimingFunctionName = .easeIn) {
        
        let anim = CATransition()
        anim.duration = duration;
        anim.timingFunction = CAMediaTimingFunction(name: functionName);
        anim.type = .fade
        anim.isRemovedOnCompletion = true;
        self.add(anim, forKey: "changeViewController")
    }
}


@objc public extension CAGradientLayer{
        
    private struct AssociateKeys {
        static var defaultColors   = "CAGradientLayer" + "defaultColors"
    }
    
    static func layerRect(_ rect: CGRect = .zero, colors: [Any], start: CGPoint, end: CGPoint) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = rect
        layer.colors = colors
        layer.startPoint = start
        layer.endPoint = end
        
        return layer
    }
    
    static func gradientColor(_ from: NSColor, to: NSColor) -> [Any] {
       return [from.cgColor, to.cgColor]
    }
    
    /// 十六进制字符串
    static func gradientColorHex(_ from: String, fromAlpha: CGFloat, to: String, toAlpha: CGFloat = 1.0) -> [Any] {
        return [NSColor.hex(from, a: fromAlpha).cgColor, NSColor.hex(to, a: toAlpha).cgColor]
    }
    
    /// 0x开头的十六进制数字
    static func gradientColorHexValue(_ from: Int, fromAlpha: CGFloat, to: Int, toAlpha: CGFloat = 1.0) -> [Any] {
        return [NSColor.hexValue(from, a: fromAlpha).cgColor, NSColor.hexValue(to, a: toAlpha).cgColor]
    }
    
    static var defaultColors: [Any] {
        get {
            if let obj = objc_getAssociatedObject(self,  &AssociateKeys.defaultColors) as? [Any] {
                return obj;
            }
            
            let list = [NSColor.hexValue(0x6cda53, a: 0.9).cgColor, NSColor.hexValue(0x1a965a, a: 0.9).cgColor]
                objc_setAssociatedObject(self,  &AssociateKeys.defaultColors, list, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return list
        }
        set {
            objc_setAssociatedObject(self,  &AssociateKeys.defaultColors, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}
