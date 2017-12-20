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


extension Kinetic where Base: NSString {
    func removeCharacter(at index: Int) -> String {
        let rangeForRemove: NSRange = base.rangeOfComposedCharacterSequence(at: index)
        let resultString: String = base.replacingCharacters(in: rangeForRemove, with: "")
        return resultString
    }
    
    func removeCharacterlast() -> String {
        return removeCharacter(at: base.length - 1)
    }
    
}



