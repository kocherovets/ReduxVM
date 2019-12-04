//
//  TableHeaderModel.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit

public protocol TableHeaderAnyModel {
    
    static var headerAnyType: UIView.Type { get }
    
    func apply(to header: UIView)
    
    func innerHashValue() -> Int
}

public protocol TableHeaderModel: TableHeaderAnyModel, Hashable {
    
    associatedtype HeaderType: UIView
    
    func apply(to header: HeaderType)
}

public extension TableHeaderModel {
    
    static var headerAnyType: UIView.Type {
        return HeaderType.self
    }
    
    func apply(to header: UIView) {
        apply(to: header as! HeaderType)
    }
    
    func innerHashValue() -> Int {
        return hashValue
    }
}
