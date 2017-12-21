//
//  String+Kinetic.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/20.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import Foundation

extension Kinetic where Base == String {
    
    var emoji: String {
        // 扫描器，可以扫描指定字符串中特定的文字
        let scanner = Scanner(string: base)
        // 扫描整数 Unsafe`Mutable`Pointer 可变的指针，要修改参数的内存地址的内容
        var result: UInt32 = 0
        scanner.scanHexInt32(&result)
        // 生成字符串：UNICODE 字符 -> 转换成字符串
        let emoji = "\(Character(UnicodeScalar(result)!))"
        return emoji
    }
    
}
