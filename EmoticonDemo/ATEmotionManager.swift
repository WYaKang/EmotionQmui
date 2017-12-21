//
//  ATEmotionManager.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/17.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

//let kQQEmotionString = "0-[微笑];1-[撇嘴];2-[色];3-[发呆];4-[得意];5-[流泪];6-[害羞];7-[闭嘴];8-[睡];9-[大哭];10-[尴尬];11-[发怒];12-[调皮];13-[呲牙];14-[惊讶];15-[难过];16-[酷];17-[冷汗];18-[抓狂];19-[吐];20-[偷笑];21-[可爱];22-[白眼];23-[傲慢];24-[饥饿];25-[困];26-[惊恐];27-[流汗];28-[憨笑];29-[大兵];30-[奋斗];31-[咒骂];32-[疑问];33-[嘘];34-[晕];35-[折磨];36-[衰];37-[骷髅];38-[敲打];39-[再见];40-[擦汗];41-[抠鼻];42-[鼓掌];43-[糗大了];44-[坏笑];45-[左哼哼];46-[右哼哼];47-[哈欠];48-[鄙视];49-[委屈];50-[快哭了];51-[阴险];52-[亲亲];53-[吓];54-[可怜];55-[菜刀];56-[西瓜];57-[啤酒];58-[篮球];59-[乒乓];60-[咖啡];61-[饭];62-[猪头];63-[玫瑰];64-[凋谢];65-[示爱];66-[爱心];67-[心碎];68-[蛋糕];69-[闪电];70-[炸弹];71-[刀];72-[足球];73-[瓢虫];74-[便便];75-[月亮];76-[太阳];77-[礼物];78-[拥抱];79-[强];80-[弱];81-[握手];82-[胜利];83-[抱拳];84-[勾引];85-[拳头];86-[差劲];87-[爱你];88-[NO];89-[OK];90-[爱情];91-[飞吻];92-[跳跳];93-[发抖];94-[怄火];95-[转圈];96-[磕头];97-[回头];98-[跳绳];99-[挥手];100-[激动];101-[街舞];102-[献吻];103-[左太极];104-[右太极];emoji笑脸-1F604;emoji生病-1F637;emoji破涕为笑-1F602;emoji吐舌-1F61D;emoji脸红-1F633;emoji恐惧-1F631;emoji失望-1F614;emoji无语-1F612;105-[嘿哈];106-[捂脸];107-[奸笑];108-[机智];109-[皱眉];110-[耶];emoji鬼魂-1F47B;emoji合十-1F64F;emoji强壮-1F4AA;emoji庆祝-1F389;emoji礼物-1F381;111-[红包];112-[鸡]"

let kQQEmotionString = "0-[微笑];1-[撇嘴];2-[色]"

var QQEmotionArray = [ATEmotion]()
var WXEmotionBigArray = [ATEmotionBig]()

protocol ATEmotionInputViewProtocol: UITextInput {
    var itext: String { get set }
    var selectedRange: NSRange { get }
}

class ATEmotionManager {
    ///
    var boundTextField: UITextField?
    
    ///
    var boundTextView: UITextView?
    
    ///
    var selectedRangeForBoundTextInput: NSRange = NSRange(location: 0, length: 0)
    
    /// 管理大表情储存
    let storeEmotionManager = StoreEmotionManager.shared
    
    
    lazy var emotionView: ATEmotionView = {
        return ATEmotionView()
    }()
    
    init() {
        self.emotionView.emotions = ATEmotionManager.emotionsForQQ()
        self.emotionView.emotionsBig = ATEmotionManager.emotionsBigForWX()
        self.emotionView.didSelectEmotionBlock = {
            [weak self] (index: Int, emotion: ATEmotionType) in
            guard let strongSelf = self else { return }
            guard let boundInputView = strongSelf.boundInputView() else { return }
            let inputText = boundInputView.itext // else { return }
            
            var selectedRange = strongSelf.selectedRangeForBoundTextInput
            if selectedRange.location <= inputText.characters.count {
                // 在输入框文字的中间插入表情
                let mutableText = NSMutableString(string: inputText)
                mutableText.insert(emotion.displayName, at: selectedRange.location)
                boundInputView.itext = mutableText as String
                // UITextView setText:会触发textViewDidChangeSelection:，而如果在这个delegate里更新self.selectedRangeForBoundTextInput，就会导致计算错误
                selectedRange = NSMakeRange(selectedRange.location + emotion.displayName.characters.count, 0)
            } else {
                // 在输入框文字的结尾插入表情
                let emotionText = inputText.appending(emotion.displayName)
                boundInputView.itext = emotionText
                selectedRange = NSMakeRange(boundInputView.itext.characters.count, 0)
            }
            strongSelf.selectedRangeForBoundTextInput = selectedRange
        }
        
        self.emotionView.didSelectDeleteBlock = {
            [weak self] in
            _ = self?.deleteEmotionDisplayName(atCurrentSelectedRangeForce: true)
        }
        
    }
    
    func deleteEmotionDisplayName(atCurrentSelectedRangeForce forceDelete: Bool)
        -> Bool
    {
        guard let boundInputView = boundInputView() else { return false }
        let selectedRange = selectedRangeForBoundTextInput
        let text = boundInputView.itext as NSString
        
        // 没有文字或者光标位置前面没文字
        if (text.length <= 0) || (NSMaxRange(selectedRange) == 0) {
            return false
        }
        
        var hasDeleteEmotionDisplayNameSuccess = false
        // QQ表情里的最短displayName的长度
        let emotionDisplayNameMinimumLength: Int = 3
        let lengthForStringSelectedRange: Int = selectedRange.location
        let lastCharSelectedRange: String = text.substring(with: NSRange(location: selectedRange.location - 1, length: 1))
        
        if (lastCharSelectedRange == "]") && (lengthForStringSelectedRange >= emotionDisplayNameMinimumLength) {
            // 从"]"之前的第n个字符开始查找
            let beginIndex: Int = lengthForStringSelectedRange -  (emotionDisplayNameMinimumLength - 1)
            // 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有QQ表情的displayName长度长就行了
            let endIndex: Int = max(0, lengthForStringSelectedRange - 5)
            var i = beginIndex
            while i >= endIndex {
                let checkingChar = text.substring(with: NSMakeRange(i, 1))
                if checkingChar == "]" {
                    // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                    break
                }
                
                if checkingChar == "[" {
                    let deletingDisplayNameRange = NSMakeRange(i, lengthForStringSelectedRange - i)
                    boundInputView.itext = text.replacingCharacters(in: deletingDisplayNameRange, with: "")
                    selectedRangeForBoundTextInput = NSMakeRange(deletingDisplayNameRange.location, 0)
                    hasDeleteEmotionDisplayNameSuccess = true
                    break
                }
                
                i -= 1
            }
        }
        
        if hasDeleteEmotionDisplayNameSuccess {
            return true
        }
        
        if !forceDelete { return false }
        
        if NSMaxRange(selectedRange) <= text.length {
            if selectedRange.length > 0 {
                // 如果选中区域是一段文字，则删掉这段文字
                boundInputView.itext = text.replacingCharacters(in: selectedRange, with: "")
                selectedRangeForBoundTextInput = NSMakeRange(selectedRange.location, 0)
            } else if selectedRange.location > 0 {
                // 如果并没有选中一段文字，则删掉光标前一个字符
                let textAfterDelete = text.ke.removeCharacter(at: selectedRange.location - 1)
                boundInputView.itext = textAfterDelete
                selectedRangeForBoundTextInput = NSMakeRange(selectedRange.location - (text.length - textAfterDelete.characters.count), 0)
            }
        } else {
            // 选中区域超过文字长度了，非法数据，则直接删掉最后一个字符
            boundInputView.itext = text.ke.removeCharacterlast()
            selectedRangeForBoundTextInput = NSMakeRange(boundInputView.itext.characters.count, 0)
        }
        
        return true
    }
    
    
    /// 在 `UITextViewDelegate` 的 `textView:shouldChangeTextInRange:replacementText:`
    /// 或者 `QMUITextFieldDelegate` 的 `textField:shouldChangeTextInRange:replacementText:`
    /// 方法里调用，根据返回值来决定是否应该调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:`
    ///
    /// - Parameters:
    ///   - range: 要发生变化的文字所在的range
    ///   - text: 要被替换为的文字
    /// - Returns: 是否会接管键盘的删除按钮事件，`YES` 表示接管，
    /// 可调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:` 方法
    /// `NO` 表示不可接管，应该使用系统自身的删除事件响应。
    func shouldTakeOverControlDeleteKeyWithChangeText(in range: NSRange, replacementText text: String)
        -> Bool
    {
        guard let boundInputView = boundInputView() else {
            return false
        }
        let isDeleteKeyPressed = text.characters.count == 0 && boundInputView.itext.characters.count - 1 == range.location
        let hasmarkedText = boundInputView.markedTextRange
        
        if hasmarkedText == nil {
            if isDeleteKeyPressed { return true }
            return false
        }
        
        return false
    }
    
    func boundInputView() -> ATEmotionInputViewProtocol? {
        if let textField = boundTextField {
            return textField
        }
        else if let textView = boundTextView {
            return textView
        }
        else {
            return nil
        }
    }

    class func emotionsBigForWX() -> [ATEmotionBig] {
        if WXEmotionBigArray.count != 0 {
            return WXEmotionBigArray
        }
        
        let kPackageId = "100001"
        
        let storeEmotionManager = StoreEmotionManager.shared
        let originURL = storeEmotionManager.getPackageURL(kPackageId)
        let thumURL = storeEmotionManager.getThumPackageURL(kPackageId)
        
//        if !storeEmotionManager.fileManager.fileExists(atPath: originURL.path) {
//            /// 创建文件夹
//            let isSusses1 = storeEmotionManager.createFielderOrigin(packageId: kPackageId)
//            assert(isSusses1 == true, "创建大表情原图片文件夹失败 kPackageId\(kPackageId), path \(originURL)")
//        }
        
        if !storeEmotionManager.fileManager.fileExists(atPath: thumURL.path) {
            let isSusses2 = storeEmotionManager.createFielderThum(packageId: kPackageId)
            assert(isSusses2 == true, "创建大表情缩略图片文件夹失败 kPackageId\(kPackageId), path \(thumURL)")
        }
        
        // 拷贝bundle文件到沙盒目录
        let isCopySuccess = storeEmotionManager.copyToStoreEmotionFilderBundle(name: "EmotionsStore")
        // 创建大表情缩略图
        let isCreate = storeEmotionManager.createEmotionThum(packageId: kPackageId)
        print("storeEmotionManager.createEmotionThum \(isCreate.description)")
        
        // 创建大表情模型
        if let emotions = storeEmotionManager.loadModel(packageId: kPackageId) {
            WXEmotionBigArray = emotions
        }
        return WXEmotionBigArray
        
    }
    
    
    
    
    
    class func emotionsForQQ() -> [ATEmotion] {
        if QQEmotionArray.count != 0 {
            return QQEmotionArray
        }
        
        var emotions = [ATEmotion]()
        let emotionStringArray = kQQEmotionString.components(separatedBy: ";")
        for emotionString in emotionStringArray {
            let emotionItem = emotionString.components(separatedBy: "-")
            let identifier = "smiley_\(emotionItem.first!)"
            let emotion = ATEmotion(identifier: identifier, displayName: emotionItem.last!)
            emotions.append(emotion)
        }
        
        QQEmotionArray = emotions
        asyncLoadImages(emotions: emotions)
        return QQEmotionArray
    }
    
    class func asyncLoadImages(emotions: [ATEmotion]) {
        DispatchQueue.global().async {
            for e in emotions {
                if let _ = e.emojiStr {
                } else {
                    _ = e.image
                }
            }
        }
    }
    
}

extension UITextView: ATEmotionInputViewProtocol {
    var itext: String {
        get {
            return self.text
        }
        set {
            self.text = newValue
        }
    }

}

extension UITextField: ATEmotionInputViewProtocol {
    var itext: String {
        get {
            return self.text ?? ""
        }
        set {
            self.text = newValue
        }
    }
    
    var selectedRange: NSRange {
        return NSMakeRange(0, 0)
    }
}

