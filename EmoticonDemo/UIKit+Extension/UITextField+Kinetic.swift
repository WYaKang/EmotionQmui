//
//  UITextField+Kinetic.swift
//  Xieyiyizhi
//
//  Created by yakang wang on 2017/12/19.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit

extension Kinetic where Base: UITextField {
    
    var selectedRange: NSRange {
        guard let selectedRange = base.selectedTextRange else {
            return NSRange(location: 0, length: 0)
        }
        let location = base.offset(from: base.beginningOfDocument, to: selectedRange.start)
        let length = base.offset(from: base.beginningOfDocument, to: selectedRange.end)
        return NSRange(location: location, length: length)
    }
    
}
