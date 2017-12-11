//
//  ATEmotionSettings.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

final class ATEmotionSettings: ATEmotionViewSettings {
    
    /// 选中表情回掉
    var didSelectEmotion: (_ index: Int, _ emotion: ATEmotionType) -> Void = {
        (index, emotion) -> Void in
        
    }
    
    /// 删除按钮的点击事件回调
    var didSelectDelete: () -> Void = {
        
    }
    
    /// 每一页表情的上下左右padding，默认为{18, 18, 65, 18}
    var paddingInPage: UIEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 65, right: 18)
    
    /// 每一页表情允许的最大行数，默认为3
    var numberOfRowsPerPage: Int = 3
    
    /// 表情的图片大小，不管`QMUIEmotion.image.size`多大，都会被缩放到`emotionSize`里显示，默认为{30, 30}
    var emotionSize: CGSize = CGSize(width: 30, height: 30)
    
    /// 表情点击时的背景遮罩相对于`emotionSize`往外拓展的区域，负值表示遮罩比表情还大，正值表示遮罩比表情还小，默认为{-3, -3, -3, -3}
    var emotionSelectedBgInsets: UIEdgeInsets = UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3)
    
    /// 表情与表情之间的最小水平间距，默认为10
    var minimumEmotionHorizontalSpacing: CGFloat = 10
    
    /// 表情面板右下角的删除按钮的图片
    var deleteButtonImage: UIImage = UIImage(named: "xxx")!
}

final class ATEmotionCellSettings: ATEmotionPageCellSettings {
    /// 整个pageView内部的padding
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// 每个pageView能展示表情的行数
    var numberOfRows: Int = 3
    
    /// 每个表情的绘制区域大小，表情图片最终会以UIViewContentModeScaleAspectFit的方式撑满这个大小。表情计算布局时也是基于这个大小来算的。
    var emotionSize: CGSize = CGSize(width: 30, height: 30)
    
    /// 点击表情时出现的遮罩要在表情所在的矩形位置拓展多少空间，负值表示遮罩比emotionSize更大，正值表示遮罩比emotionSize更小。最终判断表情点击区域时也是以拓展后的区域来判定的
    var emotionSelectedBgInsets: UIEdgeInsets = UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3)
    
    /// 表情与表情之间的水平间距的最小值，实际值可能比这个要大一点（pageView会把剩余空间分配到表情的水平间距里）
    var minimumHorizontalSpacing: CGFloat = 10
}


