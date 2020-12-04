//
//  NSAttributedString+Helper.swift
//  SwiftExpand
//
//  Created by Bin Shang on 2019/7/15.
//

import UIKit

@objc public extension NSAttributedString{
    
    /// 富文本配置字典
    static func AttributeDict(_ type: Int) -> [NSAttributedString.Key: Any]{
        var dic: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.theme,
                                                  NSAttributedString.Key.backgroundColor: UIColor.white,]
        
        switch type {
        case 1:
            dic[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue;
            dic[NSAttributedString.Key.underlineColor] = UIColor.theme;
            
        case 2:
            dic[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue;
            dic[NSAttributedString.Key.strikethroughColor] = UIColor.red;
            dic[NSAttributedString.Key.baselineOffset] = 0;

        case 3:
            dic[NSAttributedString.Key.obliqueness] = 0.8;
            
        case 4:
            dic[NSAttributedString.Key.expansion] = 0.3;
            
        case 5:
            dic[NSAttributedString.Key.writingDirection] = 3;
            
        default:
            break
        }
        return dic;
    }
    
    /// 富文本特殊部分配置字典
    static func attrDict(_ font: CGFloat = 15, textColor: UIColor = .theme) -> [NSAttributedString.Key: Any] {
        let dic = [NSAttributedString.Key.font: UIFont.systemFont(ofSize:font),
                   NSAttributedString.Key.foregroundColor: textColor,
                   NSAttributedString.Key.backgroundColor: UIColor.clear,
                   ];
        return dic;
    }
    
    /// 富文本整体设置
    static func paraDict(_ font: CGFloat = 15,
                         textColor: UIColor = .theme,
                         alignment: NSTextAlignment = .left,
                         lineSpacing: CGFloat = 0,
                         lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> [NSAttributedString.Key: Any] {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineBreakMode = lineBreakMode
        paraStyle.lineSpacing = lineSpacing
        paraStyle.alignment = alignment

        var dic = attrDict(font, textColor: textColor)
        dic[NSAttributedString.Key.paragraphStyle] = paraStyle
        return dic
    }
    
    /// [源]富文本
    static func attString(_ text: String,
                          textTaps: [String],
                          font: CGFloat = 15,
                          tapFont: CGFloat = 15,
                          color: UIColor = .black,
                          tapColor: UIColor = .theme,
                          alignment: NSTextAlignment = .left,
                          lineSpacing: CGFloat = 0,
                          lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                          rangeOptions mask: NSString.CompareOptions = []) -> NSAttributedString {
        let paraDic = paraDict(font, textColor: color, alignment: alignment, lineSpacing: lineSpacing, lineBreakMode: lineBreakMode)
        let attString = NSMutableAttributedString(string: text, attributes: paraDic)
        textTaps.forEach { ( textTap: String) in
            let nsRange = (text as NSString).range(of: textTap, options: mask)
            let attDic = attrDict(tapFont, textColor: tapColor)
            attString.addAttributes(attDic, range: nsRange)
        }
        return attString
    }
    
    /// [源]富文本二
    static func createAttString(_ text: String,
                                textTaps: [String],
                                font: UIFont = UIFont.systemFont(ofSize: 15),
                                tapFont: UIFont = UIFont.systemFont(ofSize: 15),
                                color: UIColor = .black,
                                tapColor: UIColor = .theme,
                                alignment: NSTextAlignment = .left,
                                lineSpacing: CGFloat = 0,
                                lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                                rangeOptions mask: NSString.CompareOptions = []) -> NSAttributedString {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = lineSpacing
        paraStyle.lineBreakMode = lineBreakMode
        paraStyle.alignment = alignment

        let attDic = [NSAttributedString.Key.font: font,
                      NSAttributedString.Key.foregroundColor: color,
                      NSAttributedString.Key.backgroundColor: UIColor.clear,
                      NSAttributedString.Key.paragraphStyle: paraStyle,
                    ];
        
        let attString = NSMutableAttributedString(string: text, attributes: attDic)
        textTaps.forEach { ( textTap: String) in
            let nsRange = (text as NSString).range(of: textTap, options: mask)

            let attDic = [NSAttributedString.Key.font: tapFont,
                       NSAttributedString.Key.foregroundColor: tapColor,
                       NSAttributedString.Key.backgroundColor: UIColor.clear,
                       ];
            attString.addAttributes(attDic, range: nsRange)
        }
        return attString
    }
        
    /// 特定范围子字符串差异华显示
    static func attString(_ text: String, offsetStart: Int, offsetEnd: Int) -> NSAttributedString {
        let nsRange = NSRange(location: offsetStart, length: (text.count - offsetStart - offsetEnd))
        let attrString = attString(text, nsRange: nsRange)
        return attrString
    }
    
    /// 字符串差异华显示
    static func attString(_ text: String, textSub: String) -> NSAttributedString {
        let range = text.range(of: textSub)
        let nsRange = text.nsRange(from: range!)
        let attrString = attString(text, nsRange: nsRange)
        return attrString
    }
    
    /// nsRange范围子字符串差异华显示
    static func attString(_ text: String, nsRange: NSRange, font: CGFloat = 15, textColor: UIColor = UIColor.theme) -> NSAttributedString {
        assert((nsRange.location + nsRange.length) <= text.count)
        
        let attrString = NSMutableAttributedString(string: text)
        
        let attDict = [NSAttributedString.Key.foregroundColor: textColor,
                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: font),
        ]
        attrString.addAttributes(attDict, range: nsRange)
        return attrString
    }
    
    ///  富文本只有同字体大小才能计算高度
    func size(_ width: CGFloat) -> CGSize {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
         
        var size = self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: options, context: nil).size;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        return size;
    }
    
}

public extension NSAttributedString{
    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        try self.init(data: data,
                      options: [.documentType: documentType,
                                .characterEncoding: encoding.rawValue],
                      documentAttributes: nil)
    }
    convenience init(html data: Data) throws {
        try self.init(data: data, documentType: .html)
    }
    convenience init(txt data: Data) throws {
        try self.init(data: data, documentType: .plain)
    }
    convenience init(rtf data: Data) throws {
        try self.init(data: data, documentType: .rtf)
    }
    convenience init(rtfd data: Data) throws {
        try self.init(data: data, documentType: .rtfd)
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return string
    }
}


public extension NSMutableAttributedString{
    ///添加
    func append(_ string: String, attributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSMutableAttributedString{
        self.append(NSAttributedString(string: string, attributes: attrs))
        return self
    }
}
