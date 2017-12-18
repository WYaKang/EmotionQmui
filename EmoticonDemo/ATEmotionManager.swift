//
//  ATEmotionManager.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/17.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

let kQQEmotionString = "0-[微笑];1-[撇嘴];2-[色];3-[发呆];4-[得意];5-[流泪];6-[害羞];7-[闭嘴];8-[睡];9-[大哭];10-[尴尬];11-[发怒];12-[调皮];13-[呲牙];14-[惊讶];15-[难过];16-[酷];17-[冷汗];18-[抓狂];19-[吐];20-[偷笑];21-[可爱];22-[白眼];23-[傲慢];24-[饥饿];25-[困];26-[惊恐];27-[流汗];28-[憨笑];29-[大兵];30-[奋斗];31-[咒骂];32-[疑问];33-[嘘];34-[晕];35-[折磨];36-[衰];37-[骷髅];38-[敲打];39-[再见];40-[擦汗];41-[抠鼻];42-[鼓掌];43-[糗大了];44-[坏笑];45-[左哼哼];46-[右哼哼];47-[哈欠];48-[鄙视];49-[委屈];50-[快哭了];51-[阴险];52-[亲亲];53-[吓];54-[可怜];55-[菜刀];56-[西瓜];57-[啤酒];58-[篮球];59-[乒乓];60-[咖啡];61-[饭];62-[猪头];63-[玫瑰];64-[凋谢];65-[示爱];66-[爱心];67-[心碎];68-[蛋糕];69-[闪电];70-[炸弹];71-[刀];72-[足球];73-[瓢虫];74-[便便];75-[月亮];76-[太阳];77-[礼物];78-[拥抱];79-[强];80-[弱];81-[握手];82-[胜利];83-[抱拳];84-[勾引];85-[拳头];86-[差劲];87-[爱你];88-[NO];89-[OK];90-[爱情];91-[飞吻];92-[跳跳];93-[发抖];94-[怄火];95-[转圈];96-[磕头];97-[回头];98-[跳绳];99-[挥手];100-[激动];101-[街舞];102-[献吻];103-[左太极];104-[右太极];105-[嘿哈];106-[捂脸];107-[奸笑];108-[机智];109-[皱眉];110-[耶];111-[红包];112-[鸡]"

var QQEmotionArray = [ATEmotion]()

protocol ATEmotionInputViewProtocol: UITextInput {
    var text: String { get set }
    var selectedRange: NSRange {get}
}

class ATEmotionManager {
    ///
    var boundTextField: UITextField?
    
    ///
    var boundTextView: UITextView?
    
    ///
    var selectedRangeForBoundTextInput: NSRange?
    
    lazy var emotionView: ATEmotionView = {
        return ATEmotionView()
    }()
    
    init() {
        self.emotionView.emotions = ATEmotionManager.emotionsForQQ()
        self.emotionView.didSelectEmotionBlock = {
            [weak self] (index: Int, emotion: ATEmotionType) in
            guard let strongSelf = self else { return }
            guard strongSelf.boundInputView() != nil else { return }
            
            var inputText = strongSelf.boundInputView()?.text // else { return }
            guard var selectedRange = strongSelf.selectedRangeForBoundTextInput else { return }
            
            if selectedRange.location <= inputText?.characters.count ?? 0 {
                // 在输入框文字的中间插入表情
                let mutableText: NSMutableString = (inputText ?? "") as! NSMutableString
                mutableText.insert(emotion.displayName, at: selectedRange.location)
                strongSelf.boundInputView()?.text = mutableText as String
                selectedRange = NSMakeRange(selectedRange.location + emotion.displayName.characters.count, 0)
                
            } else {
                // 在输入框文字的结尾插入表情
                inputText = inputText?.appending(emotion.displayName)
                strongSelf.boundInputView()?.text = inputText!
                selectedRange = NSMakeRange((strongSelf.boundInputView()?.text.characters.count)!, 0)
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
        
        return false
    }
    
    func shouldTakeOverControlDeleteKeyWithChangeText(in range: NSRange, replacementText text: String)
        -> Bool
    {
        
        return false
    }
    
    func boundInputView() -> (UIView & ATEmotionInputViewProtocol)? {
        if let textField = boundTextField as? (UIView & ATEmotionInputViewProtocol) {
            return textField
        } else if let textView = boundTextView as? (UIView & ATEmotionInputViewProtocol) {
            return textView
        } else {
            return nil
        }
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
                _ = e.image
            }
        }
    }
}

