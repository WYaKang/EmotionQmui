//
//  ATEmotionView.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

/// 代表一个表情的数据对象
class ATEmotion: ATEmotionType, Equatable {
    
    /// 当前表情的标识符，可用于区分不同表情
    var identifier: String = ""
    /// 当前表情展示出来的名字，可用于输入框里的占位文字，例如“[委屈]”
    var displayName: String = ""
    /// 有可能是字符串
    var emojiStr: String?
    /// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
    lazy var image: UIImage? = {
        let path = Bundle.main.path(forResource: "\(self.identifier)@2x", ofType: ".png", inDirectory: "QMUI_QQEmotion.bundle/Contents/Resources")
        return UIImage(named: path!)
    }()
    
    
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
    
    static func ==(left: ATEmotion, right: ATEmotion) -> Bool {
        return left.identifier == right.identifier
    }
    
}

extension ATEmotion: CustomStringConvertible {
    var description: String {
        return "ATEmotion: \(identifier) \(displayName)"
    }
}



///////////////////////////////////////////////////
//                ATEmotionView                  //
///////////////////////////////////////////////////
class ATEmotionView: UIView {
    
    /// 要展示的所有表情
    var emotions: [ATEmotion] = [] {
        didSet {
            setupPageEmotions()
        }
    }
    
    /// 页面设置
    var pageSettings = ATEmotionCellSettings()
    
    /// 选中表情回掉
    var didSelectEmotionBlock: ((_ index: Int, _ emotion: ATEmotionType) -> Void)? = nil
    
    /// 删除按钮的点击事件回调
    var didSelectDeleteBlock: (() -> Void)? = nil
    
    /// 分成页面 一个页面 一个数组
    fileprivate var pageEmotions: [[ATEmotion]] = []
    
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
        
        super.init(frame: frame)
        self.addSubview(self.collectionView)
        
        collectionView.register(ATEmotionPageViewCell.self, forCellWithReuseIdentifier: "at_emotion_page")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let collectionViewSizeChanged = !(bounds.size == collectionView.bounds.size)
        collectionView.frame = bounds
        collectionViewLayout.itemSize = collectionView.bounds.size
        if collectionViewSizeChanged {
            setupPageEmotions()
        }
    }
    
    func setupPageEmotions() {
        pageEmotions.removeAll()
        
        if !collectionView.bounds.isEmpty && emotions.count > 0 && !pageSettings.emotionSize.isEmpty {
            let contentWidthInPage = collectionView.bounds.width - pageSettings.padding.horizontalValue
            let maxPerRowInPage: Int = Int((contentWidthInPage + pageSettings.minimumHorizontalSpacing) / (pageSettings.emotionSize.width + pageSettings.minimumHorizontalSpacing))
            let maxPerPage: Int = maxPerRowInPage * pageSettings.numberOfRows - 1
            let pageCount: Int = Int(ceil(Double(CGFloat(emotions.count) / CGFloat(maxPerPage))))
            
            for i in 0 ..< pageCount {
                var emotionRangeForPage = NSMakeRange(maxPerPage * i, maxPerPage)
                if NSMaxRange(emotionRangeForPage) > emotions.count {
                    // 最后一页可能不满一整页，所以取剩余的所有表情即可
                    emotionRangeForPage.length = emotions.count - emotionRangeForPage.location
                }
                
                let emotionForPage: [ATEmotion] = Array(emotions[emotionRangeForPage.location ..< NSMaxRange(emotionRangeForPage)])
                pageEmotions.append(emotionForPage)
            }
        }
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

///////////////////////////////////////////////////
//          UICollectionViewDelegate             //
///////////////////////////////////////////////////
extension ATEmotionView: UICollectionViewDelegate {
    
}

///////////////////////////////////////////////////
//          UICollectionViewDataSource           //
///////////////////////////////////////////////////
extension ATEmotionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageEmotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pageView = collectionView.dequeueReusableCell(withReuseIdentifier: "at_emotion_page", for: indexPath) as! ATEmotionPageViewCell
        pageView.delegate = self
        pageView.emotions = pageEmotions[indexPath.item]
        pageView.settings = pageSettings
        pageView.deleteButton.setImage(pageSettings.deleteButtonImage, for: .normal)
        pageView.setNeedsDisplay()
        return pageView
    }
}

///////////////////////////////////////////////////
//          ATEmotionPageViewDelegate            //
///////////////////////////////////////////////////
extension ATEmotionView: ATEmotionPageViewDelegate {
    func emotionPageView(_ emotionPageView: ATEmotionPageViewCell, didSelect emotion: ATEmotion, at index: Int) {
        guard let didSelectEmotion = didSelectEmotionBlock else {
            return
        }
        if let index = emotions.index(where: { $0 == emotion }) {
            didSelectEmotion(index, emotion)
        }
    }
    
    func didSelectDeleteButton(in emotionPageView: ATEmotionPageViewCell) {
        didSelectDeleteBlock?()
    }
}


///////////////////////////////////////////////////
//            ATEmotionPageViewCell              //
///////////////////////////////////////////////////
protocol ATEmotionPageViewDelegate: class {
    func emotionPageView(_ emotionPageView: ATEmotionPageViewCell, didSelect emotion: ATEmotion, at index: Int)
    func didSelectDeleteButton(in emotionPageView: ATEmotionPageViewCell)
}

/// 表情面板每一页的cell，在drawRect里将所有表情绘制上去，同时自带一个末尾的删除按钮
class ATEmotionPageViewCell: UICollectionViewCell {
    
    var delegate: ATEmotionPageViewDelegate?
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
        
        self.deleteButton.addTarget(self, action: #selector(handleDeleteEvent(deleteButton:)), for: .touchUpInside)
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.emotionSelectBgView)
        self.addSubview(self.deleteButton)
        self.tapGestureRecognizer.addTarget(self, action: #selector(handleTapRecognizer(tapGesture:)))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    @objc func handleTapRecognizer(tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: self)
        for i in 0 ..< emotionHittingRects.count {
            let rect = emotionHittingRects[i]
            if rect.contains(location) {
                let emotion = emotions[i]
                emotionSelectBgView.frame = rect
                UIView.animate(withDuration: 0.08, animations: {
                    self.emotionSelectBgView.alpha = 1
                }, completion: { (finish) in
                    UIView.animate(withDuration: 0.08, animations: {
                        self.emotionSelectBgView.alpha = 0
                    }, completion: nil)
                })
                delegate?.emotionPageView(self, didSelect: emotion, at: i)
                do {
                    print("最终确定了点击的是当前页里的第 \(i) 个表情，\(emotion.description)")
                }
                return
            }
        }
    }
    
    @objc func handleDeleteEvent(deleteButton: UIButton) {
        delegate?.didSelectDeleteButton(in: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        deleteButton.sizeToFit()
        deleteButton.frame = deleteButton.frame.setXY(x:
            flat((bounds.width - settings.padding.right - deleteButton.frame.width) - (settings.emotionSize.width - deleteButton.frame.width) / 2.0),
                                                      y:
            flat((bounds.height - settings.padding.bottom - deleteButton.frame.height) - (settings.emotionSize.height - deleteButton.frame.height) / 2.0))
    }
    
    override func draw(_ rect: CGRect) {
        emotionHittingRects.removeAll()
        
        let contentSize = bounds.insetEdge(settings.padding).size
        let emotionCountPerRow: Int = Int(contentSize.width + settings.minimumHorizontalSpacing) / Int(settings.emotionSize.width + settings.minimumHorizontalSpacing)
        let emotionHorizonSpacing: CGFloat = flat((contentSize.width - CGFloat(emotionCountPerRow) * settings.emotionSize.width) / CGFloat(emotionCountPerRow - 1))
        let emotionVerticalSpacing: CGFloat = flat((contentSize.height - CGFloat(settings.numberOfRows) * settings.emotionSize.height) / CGFloat(settings.numberOfRows - 1))
        
        var emotionOrigin = CGPoint.zero
        var i = 0, l = emotions.count
        while i < l {
            let row = i / emotionCountPerRow
            emotionOrigin.x = settings.padding.left + (settings.emotionSize.width + emotionHorizonSpacing) * CGFloat(i % emotionCountPerRow)
            emotionOrigin.y = settings.padding.top + (settings.emotionSize.height + emotionVerticalSpacing) * CGFloat(row)
            let emotionRect = CGRect(x: emotionOrigin.x, y: emotionOrigin.y, width: settings.emotionSize.width, height: settings.emotionSize.height)
            let emotionHittingRect = emotionRect.insetEdge(settings.emotionSelectedBgInsets)
            emotionHittingRects.append(emotionHittingRect)
            let emotion = emotions[i]
            if let image = emotion.image {
                drawImage(image, inRect: emotionRect)
            }
            i += 1
        }
    }
    
    func drawImage(_ image: UIImage, inRect contextRect: CGRect) {
        var contextRect = contextRect
        let imageSize = image.size
        let horizontalRatio = contextRect.width / imageSize.width
        let verticalRatio = contextRect.height / imageSize.height
        
        let ratio = fmin(horizontalRatio, verticalRatio)
        var drawingRect = CGRect.zero
        drawingRect.size.width = imageSize.width * ratio
        drawingRect.size.height = imageSize.height * ratio
        drawingRect = drawingRect.setXY(x: contextRect.minXHorizontallyCenter(drawingRect), y: contextRect.minYVerticallyCenter(drawingRect))
        
        do {
            let PixeOne = 1/UIScreen.main.scale
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(PixeOne)
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.stroke(contextRect.insetBy(dx: PixeOne / 2.0, dy: PixeOne / 2.0))
        }
        
        image.draw(in: drawingRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






