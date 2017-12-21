//
//  NSString.swift
//  EmoticonDemo
//
//  Created by yakang wang on 2017/12/20.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import Foundation

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
