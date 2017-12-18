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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        emotionView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 226)
//        view.addSubview(emotionView)
        
        
        emotionViewManager.emotionView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 226)
        emotionViewManager.emotionView.backgroundColor = UIColor.red
        view.addSubview(emotionViewManager.emotionView)
        
        
    }

}

