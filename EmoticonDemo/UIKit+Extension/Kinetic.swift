//
//  Kinetic.swift
//  Xieyiyizhi
//
//  Created by yakang wang on 2017/12/19.
//  Copyright © 2017年 yakang wang. All rights reserved.
//

import UIKit


public final class Kinetic<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol KineticCompatiable {
    associatedtype CompatiableType
    var ke: CompatiableType { get }
}

public extension KineticCompatiable {
    public var ke: Kinetic<Self> {
        get { return Kinetic(self) }
    }
}

extension UITextField: KineticCompatiable {}




