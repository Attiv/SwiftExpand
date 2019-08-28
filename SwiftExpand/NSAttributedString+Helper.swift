//
//  NSAttributedString+Helper.swift
//  SwiftExpand
//
//  Created by Bin Shang on 2019/7/15.
//

import UIKit

public extension NSAttributedString{
    
    /// 富文本特殊部分设置
    @objc static func attrDict(_ font: CGFloat, textColor: UIColor) -> Dictionary<NSAttributedString.Key, Any> {
        let dic = [NSAttributedString.Key.font: UIFont.systemFont(ofSize:font),
                   NSAttributedString.Key.foregroundColor: textColor,
                   NSAttributedString.Key.backgroundColor: UIColor.clear,
                   ];
        return dic;
    }
    
    /// 富文本整体设置
    @objc static func paraDict(_ font: CGFloat, textColor: UIColor, alignment: NSTextAlignment) -> Dictionary<NSAttributedString.Key, Any> {
        let paraStyle = NSMutableParagraphStyle();
        paraStyle.lineBreakMode = .byCharWrapping;
        paraStyle.alignment = alignment;
        
        let mdic = NSMutableDictionary(dictionary: attrDict(font, textColor: textColor));
        mdic.setObject(paraStyle, forKey:kCTParagraphStyleAttributeName as! NSCopying);
        return mdic.copy() as! Dictionary<NSAttributedString.Key, Any>;
    }
    
    /// [源]富文本
    @objc static func attString(_ text: String!, textTaps: [String]!, font: CGFloat = 16.0, tapFont: CGFloat = 16.0, color: UIColor = .black, tapColor: UIColor, alignment: NSTextAlignment = .left) -> NSAttributedString {
        let paraDic = paraDict(font, textColor: color, alignment: alignment)
        let attString = NSMutableAttributedString(string: text, attributes: paraDic)
        textTaps.forEach { ( textTap: String) in
            let nsRange = (text as NSString).range(of: textTap)
            let attDic = attrDict(font, textColor: tapColor)
            attString.addAttributes(attDic, range: nsRange)
        }
        return attString
    }
    
    /// 特定范围子字符串差异华显示
    @objc static func attString(_ text: String!, offsetStart: Int, offsetEnd: Int) -> NSAttributedString! {
        let nsRange = NSRange(location: offsetStart, length: (text.count - offsetStart - offsetEnd))
        let attrString = attString(text, nsRange: nsRange)
        return attrString
    }
    
    /// 字符串差异华显示
    @objc static func attString(_ text: String!, textSub: String) -> NSAttributedString! {
        let range = text.range(of: textSub)
        let nsRange = text.nsRange(from: range!)
        let attrString = attString(text, nsRange: nsRange)
        return attrString
    }
    
    /// nsRange范围子字符串差异华显示
    @objc static func attString(_ text: String!, nsRange: NSRange) -> NSAttributedString! {
        assert(text.count > (nsRange.location + nsRange.length))
        
        let attrString = NSMutableAttributedString(string: text)
        
        let attDict = [NSAttributedString.Key.foregroundColor: UIColor.theme,
                       NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30),
        ]
        attrString.addAttributes(attDict, range: nsRange)
        return attrString
    }
    
}


