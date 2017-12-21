//
//  ViewController.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/10.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let emotionView = ATEmotionView()
    let emotionViewManager = ATEmotionManager()
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        emotionViewManager.boundTextField = textField
        emotionViewManager.emotionView.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.size.width, height: 226)
        emotionViewManager.emotionView.backgroundColor = UIColor.red
        view.addSubview(emotionViewManager.emotionView)
        
        
        let eee = "1F604".ke.emoji
        print(eee)
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // 告诉 qqEmotionManager 输入框的光标位置发生变化，以保证表情插入在光标之后
        emotionViewManager.selectedRangeForBoundTextInput = textField.ke.selectedRange
        return true
    }
}

