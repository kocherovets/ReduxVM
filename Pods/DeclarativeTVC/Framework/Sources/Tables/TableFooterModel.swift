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

    func cellType() -> CellKind
    
    func register(tableView: UITableView, identifier: String)
    
    var height: CGFloat? { get }
}

public protocol TableFooterModel: TableFooterAnyModel, Hashable {

    associatedtype FooterType: UIView

    func apply(to footer: FooterType)

    func cellType() -> CellKind
}

public extension TableFooterModel {

    static var footerAnyType: UIView.Type {
        return FooterType.self
    }

    func apply(to footer: UIView) {
        apply(to: footer as! FooterType)
    }

    func innerHashValue() -> Int {
        return hashValue
    }

    func cellType() -> CellKind {
        switch FooterType.self {
        case is XibTableViewCell.Type, is XibCollectionViewCell.Type:
            return .xib
        case is CodedTableViewCell.Type, is CodedCollectionViewCell.Type:
            return .code
        default:
            return .storyboard
        }
    }
    
    func register(tableView: UITableView, identifier: String) {
        
        tableView.register(FooterType.self, forCellReuseIdentifier: identifier)
    }
    
    var height: CGFloat? { nil }
}

public struct TitleWithoutViewTableFooterModel: TableFooterModel {
    
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}
