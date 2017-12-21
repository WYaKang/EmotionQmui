//
//  UIImage+Kinetic.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/20.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit


extension Kinetic where Base: UIImage {
    
    func flatSpecificScale(size: CGSize, scale: Float) -> CGSize {
        return CGSize(width: EmoticonDemo.flatSpecificScale(size.width , scale: CGFloat(scale)), height: EmoticonDemo.flatSpecificScale(size.height, scale: CGFloat(scale)))
    }
    /// 不透明
    var opaque: Bool {
        if let cgimage = base.cgImage {
            let alphaInfo = cgimage.alphaInfo
            let opaqueBool = alphaInfo == .noneSkipLast ||
                             alphaInfo == .noneSkipFirst ||
                             alphaInfo == .none
            return opaqueBool
        } else {
            return true
        }
    }
    
    /// 将原图按指定的 UIViewContentMode 缩放到指定的大小，返回处理完的图片
    ///
    /// - Parameters:
    ///   - size: 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同
    ///   - contentMode: 希望使用的缩放模式，目前仅支持 scaleToFill、scaleAspectFill、scaleAspectFit（默认）
    ///   - scale: 处理后返回的图片的 scale
    /// - Returns: 处理完的图片
    func scaleTo(size: CGSize,
                 contentMode: UIViewContentMode = .scaleAspectFit,
                 scale: CGFloat = 0)
        -> UIImage?
    {
        let scale = scale == 0 ? base.scale : scale
        let size = flatSpecificScale(size: size, scale: Float(scale))
        
        let imageSize = base.size
        var drawingRect = CGRect.zero
        
        if contentMode == .scaleToFill {
            drawingRect = size.makeRect
        } else {
            let horizontalRatio = size.width / imageSize.width
            let verticalRatio = size.height / imageSize.height
            var ratio: CGFloat = 0.0
            if contentMode == .scaleAspectFill {
                ratio = fmax(horizontalRatio, verticalRatio)
            } else {
                // 默认按 scaleAspectFit
                ratio = fmin(horizontalRatio, verticalRatio)
            }
            drawingRect.size.width = EmoticonDemo.flatSpecificScale(imageSize.width * ratio, scale: scale)
            drawingRect.size.height = EmoticonDemo.flatSpecificScale(imageSize.height * ratio, scale: scale)
        }
        
        UIGraphicsBeginImageContextWithOptions(drawingRect.size, opaque, scale)
        guard let _ = UIGraphicsGetCurrentContext() else {
            assert(false, "AT_Extension Image error 非法的context")
            return nil
        }
        
        base.draw(in: drawingRect)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
        
    }
    
}
