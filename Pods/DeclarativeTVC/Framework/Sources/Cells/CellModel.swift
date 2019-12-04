//
//  CellModel.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

extension Int: Differentiable {}

public protocol CellAnyModel {
    
    static var cellAnyType: UIView.Type { get }
    
    func apply(to cell: UIView)
    
    func innerHashValue() -> Int
}

public protocol CellModel: CellAnyModel, Hashable, Differentiable {
    
    associatedtype CellType: UIView

    func apply(to cell: CellType)
}

public extension CellModel {
    
    static var cellAnyType: UIView.Type {
        return CellType.self
    }
    
    func apply(to cell: UIView) {
         apply(to: cell as! CellType)
    }
    
    func innerHashValue() -> Int {
        return hashValue
    }
}
