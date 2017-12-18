//
//  Rect+Extension.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

let kScreenScale = UIScreen.main.scale


/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 *  issue: https://github.com/QMUI/QMUI_iOS/issues/203
 */
func removeFloatMin(_ floatValue: CGFloat) -> CGFloat {
    return (floatValue == CGFloat.leastNormalMagnitude) ? 0 : floatValue
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
func flatSpecificScale(_ floatValue: CGFloat, scale: CGFloat) -> CGFloat {
    let floatValueNum = removeFloatMin(floatValue)
    let scaleNum = (scale == 0) ? kScreenScale : scale
    let flattedValue = ceil(floatValueNum * scaleNum) / scaleNum
    return flattedValue
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
func flat(_ floatValue: CGFloat) -> CGFloat {
    return flatSpecificScale(floatValue, scale: 0)
}


extension UIEdgeInsets {
    
    var horizontalValue: CGFloat {
        return self.left + self.right
    }
    
    var verticalValue: CGFloat {
        return self.top + self.bottom
    }
}


extension CGRect {
    
    
    func insetEdge(_ insets: UIEdgeInsets) -> CGRect {
        var _rect = self
        _rect.origin.x += insets.left
        _rect.origin.y += insets.top
        _rect.size.width -= insets.horizontalValue
        _rect.size.height -= insets.verticalValue
        return _rect
    }
    
    /// 计算view的水平居中，传入父view和子view的frame，返回子view在水平居中时的x值
    mutating func minXHorizontallyCenter(inParentRect: CGRect, childRect: CGRect) -> CGFloat {
        let w = (inParentRect.width - childRect.width) / 2.0
        return flat(w)
    }
    
    /// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持水平居中时，layoutingRect的originX
    mutating func minXHorizontallyCenter(_ layoutingRect: CGRect) -> CGFloat {
        let minX = self.minX
        let minXHorizon = minXHorizontallyCenter(inParentRect: self, childRect: layoutingRect)
        return minX + minXHorizon
    }
    
    /// 计算view的垂直居中，传入父view和子view的frame，返回子view在垂直居中时的y值
    mutating func minYVerticallyCenter(inParentRect: CGRect, childRect: CGRect) -> CGFloat {
        let h = (inParentRect.width - childRect.width) / 2.0
        return flat(h)
    }
    
    /// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持水平居中时，layoutingRect的originX
    mutating func minYVerticallyCenter(_ layoutingRect: CGRect) -> CGFloat {
        let minY = self.minY
        let minYHorizon = minYVerticallyCenter(inParentRect: self, childRect: layoutingRect)
        return minY + minYHorizon
    }
    
    func setXY(x: CGFloat, y: CGFloat) -> CGRect {
        var _rect = self
        _rect.origin.x = flat(x)
        _rect.origin.y = flat(y)
        return _rect
    }
    
    
    
}


extension CGSize {
    var isEmpty: Bool {
        return self.width <= 0 || self.height <= 0
    }
    
}



