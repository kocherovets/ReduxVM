//
//  TableFooterModel.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit

public protocol TableFooterAnyModel {
    
    static var footerAnyType: UIView.Type { get }
    
    func apply(to footer: UIView)
    
    func innerHashValue() -> Int
}

public protocol TableFooterModel: TableFooterAnyModel, Hashable {
    
    associatedtype FooterType: UIView
    
    func apply(to footer: FooterType)
}

extension TableFooterModel {
    
    static var footerAnyType: UIView.Type {
        return FooterType.self
    }
    
    func apply(to footer: UIView) {
        apply(to: footer as! FooterType)
    }
    
    func innerHashValue() -> Int {
        return hashValue
    }
}
