//
//  ATEmotionView.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

/// 代表一个表情的数据对象
class ATEmotion: ATEmotionType {
    
    /// 当前表情的标识符，可用于区分不同表情
    var identifier: String = ""
    /// 当前表情展示出来的名字，可用于输入框里的占位文字，例如“[委屈]”
    var displayName: String = ""
    /// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
    var image: UIImage?
    /// 有可能是字符串
    var emojiStr: String?
    
    /// 快速生成一个`QMUIEmotion`对象，并且以`identifier`为图片名在当前项目里查找，
    /// 作为表情的图片
    ///
    /// - Parameters:
    ///   - identifier: 表情的标识符，也会被当成图片的名字
    ///   - displayName: 表情展示出来的名字
    init(identifier: String, displayName: String) {
        self.identifier = identifier
        self.displayName = displayName
    }
    
}

class ATEmotionView: UIView {

    /// 要展示的所有表情
    var emotions: [ATEmotion] = []
    
    /// 用于展示表情面板的横向滚动collectionView，布局撑满整个控件
    fileprivate let collectionView: UICollectionView
    /// 用于横向按页滚动的collectionViewLayout
    fileprivate let collectionViewLayout: UICollectionViewFlowLayout
    
    override init(frame: CGRect) {
        
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionViewLayout.scrollDirection = .horizontal
        self.collectionViewLayout.minimumLineSpacing = 0
        self.collectionViewLayout.minimumInteritemSpacing = 0
        self.collectionViewLayout.sectionInset = UIEdgeInsets.zero
        
        self.collectionView = UICollectionView(frame: CGRect.zero,
                                collectionViewLayout: self.collectionViewLayout)
        self.collectionView.scrollsToTop = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
        
        super.init(frame: frame)
        self.addSubview(self.collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ATEmotionPageViewCell: UICollectionViewCell {
    
    var settings: ATEmotionPageCellSettings = ATEmotionCellSettings()
    
    var emotions: [ATEmotion] = []
    var emotionHittingRects: [CGRect] = []
    
    let emotionSelectBgView: UIView
    let deleteButton: UIButton
    let tapGestureRecognizer: UITapGestureRecognizer
    
    override init(frame: CGRect) {
        self.emotionSelectBgView = UIView()
        self.emotionSelectBgView.isUserInteractionEnabled = false
        self.emotionSelectBgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16)
        self.emotionSelectBgView.layer.cornerRadius = 3
        self.emotionSelectBgView.alpha = 0
        
        self.deleteButton = UIButton(type: .custom)
        
        self.tapGestureRecognizer = UITapGestureRecognizer()
        super.init(frame: frame)
        self.deleteButton.addTarget(self, action: #selector(handleEvent(deleteButton:)), for: .touchUpInside)
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.emotionSelectBgView)
        self.addSubview(self.deleteButton)
        self.tapGestureRecognizer.addTarget(self, action: #selector(handleRecognizer(tapGesture:)))
        
    }
    
    @objc func handleRecognizer(tapGesture: UITapGestureRecognizer) {
        print("tapGesture -> \(tapGesture)")
    }
    
    @objc func handleEvent(deleteButton: UIButton) {
        print("deleteButton -> \(deleteButton)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        emotionHittingRects.removeAll()
        
        let contentSize = bounds.insetEdge(settings.padding).size
        let emotionCountPerRow: Int = Int(contentSize.width + settings.minimumHorizontalSpacing) / Int(settings.emotionSize.width + settings.minimumHorizontalSpacing)
        let emotionHorizonSpacing = flat((contentSize.width - CGFloat(emotionCountPerRow) * settings.emotionSize.width) / CGFloat(emotionCountPerRow - 1))
        let emotionVerticalSpacing = flat((contentSize.height - CGFloat(settings.numberOfRows) * settings.emotionSize.height) / CGFloat(settings.numberOfRows - 1))
        
        var emotionOrigin = CGPoint.zero
        let emotionCount = emotions.count
        for i in 0 ..< emotionCount {
            let row = i / emotionCountPerRow
            emotionOrigin.x = settings.padding.left + (settings.emotionSize.width + emotionHorizonSpacing) * CGFloat(i % emotionCountPerRow)
            emotionOrigin.y = settings.padding.top + (settings.emotionSize.height + emotionVerticalSpacing) * CGFloat(row)
            var emotionRect = CGRect(x: emotionOrigin.x, y: emotionOrigin.y, width: settings.emotionSize.width, height: settings.emotionSize.height)
            let emotionHittingRect = emotionRect.insetEdge(settings.emotionSelectedBgInsets)
            emotionHittingRects.append(emotionHittingRect)
            let emotion = emotions[i]
            
        }
    }
    
    func drawImage(_ image: UIImage, inRect contextRect: CGRect) {
        let imageSize = image.size
        let horizontalRatio =
    }
}






