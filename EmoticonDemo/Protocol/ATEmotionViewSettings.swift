//
//  ATEmotionViewSettings.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

public protocol ATEmotionType {
    
    /// 当前表情的标识符，可用于区分不同表情
    var identifier: String { get set }
    
    /// 当前表情展示出来的名字，可用于输入框里的占位文字，例如“[委屈]”
    var displayName: String { get set }
    
    /// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
    var image: UIImage? { get set }
    
    /// 有可能是字符串
    var emojiStr: String? { get set }
}

public protocol ATEmotionViewSettings {
    
//    ///
//    var paddingInPage: UIEdgeInsets { get set }
    
//    /// 每一页表情允许的最大行数，默认为3
//    var numberOfRowsPerPage: Int { get set }
//    
//    /// 表情的图片大小，不管`QMUIEmotion.image.size`多大，都会被缩放到`emotionSize`里显示，默认为{30, 30}
//    var emotionSize: CGSize { get set }
//    
//    /// 表情点击时的背景遮罩相对于`emotionSize`往外拓展的区域，负值表示遮罩比表情还大，正值表示遮罩比表情还小，默认为{-3, -3, -3, -3}
//    var emotionSelectedBgInsets: UIEdgeInsets { get set }
//    
//    /// 表情与表情之间的最小水平间距，默认为10
//    var minimumEmotionHorizontalSpacing: CGFloat { get set }
    
    

}

public protocol ATEmotionPageCellSettings {
    
    /// 表情面板右下角的删除按钮的图片
    var deleteButtonImage: UIImage { get set }
    
    /// 每一页表情的上下左右padding，默认为{18, 18, 65, 18}
    var padding: UIEdgeInsets { get set }
    
    /// 每个pageView能展示表情的行数
    var numberOfRows: Int { get set }
    
    /// 每个表情的绘制区域大小，表情图片最终会以UIViewContentModeScaleAspectFit的方式撑满这个大小。表情计算布局时也是基于这个大小来算的。
    var emotionSize: CGSize { get set }
    
    /// 点击表情时出现的遮罩要在表情所在的矩形位置拓展多少空间，负值表示遮罩比emotionSize更大，正值表示遮罩比emotionSize更小。最终判断表情点击区域时也是以拓展后的区域来判定的
    var emotionSelectedBgInsets: UIEdgeInsets { get set }
    
    /// 表情与表情之间的水平间距的最小值，实际值可能比这个要大一点（pageView会把剩余空间分配到表情的水平间距里）
    var minimumHorizontalSpacing: CGFloat { get set }
}
