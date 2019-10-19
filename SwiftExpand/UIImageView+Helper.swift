//
//  UIImageView+Helper.swift
//  SwiftExpand
//
//  Created by Bin Shang on 2018/12/27.
//

import UIKit

@objc public extension UIImageView{

    ///MARK:默认渲染AlwaysTemplate方式
    func renderTintColor(_ tintColor: UIColor = .theme, mode: UIImage.RenderingMode = .alwaysTemplate) {
        self.tintColor = tintColor
        self.image = self.image!.withRenderingMode(mode)
    }
    
}



