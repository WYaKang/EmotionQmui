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
    return floatValue == CGFloat.leastNormalMagnitude ? 0 : floatValue
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
func flatSpecificScale(_ floatValue: CGFloat, scale: CGFloat) -> CGFloat {
    let floatValueNum = removeFloatMin(floatValue)
    let scaleNum = scale == 0 ? kScreenScale : scale
    let flattedValue = ceil(floatValueNum * scaleNum) / scale
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
    func horizontalValue() -> CGFloat {
        return self.left + self.right
    }
    
    func verticalValue() -> CGFloat {
        return self.top + self.bottom
    }
}


extension CGRect {
    mutating func insetEdge(_ edge: UIEdgeInsets) -> CGRect {
        self.origin.x += edge.left
        self.origin.y += edge.top
        self.size.width -= edge.horizontalValue()
        self.size.height -= edge.verticalValue()
        return self
    }
}




