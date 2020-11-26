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

open class StoryboardTableViewCell: UITableViewCell {
    
}

open class XibTableViewCell: UITableViewCell {
    
}

open class CodedTableViewCell: UITableViewCell {
    
}

open class StoryboardCollectionViewCell: UICollectionViewCell {
    
}

open class XibCollectionViewCell: UICollectionViewCell {
    
}

open class CodedCollectionViewCell: UICollectionViewCell {
    
}

public enum CellKind {
    case storyboard
    case xib
    case code
}

public protocol CellAnyModel {
    
    static var cellAnyType: UIView.Type { get }
    
    func apply(to cell: UIView)
    
    func innerHashValue() -> Int

    func cellType() -> CellKind
    
    func register(tableView: UITableView, identifier: String)
    
    func register(collectionView: UICollectionView, identifier: String)
    
    var height: CGFloat? { get }
}

public protocol CellModel: CellAnyModel, Hashable, Differentiable {
    
    associatedtype CellType: UIView

    func apply(to cell: CellType)
    
    func cellType() -> CellKind
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
    
    func cellType() -> CellKind {
        switch CellType.self {
        case is XibTableViewCell.Type, is XibCollectionViewCell.Type:
            return .xib
        case is CodedTableViewCell.Type, is CodedCollectionViewCell.Type:
            return .code
        default:
            return .storyboard
        }
    }

    func register(tableView: UITableView, identifier: String) {
        
        tableView.register(CellType.self, forCellReuseIdentifier: identifier)
    }

    func register(collectionView: UICollectionView, identifier: String) {
        
        collectionView.register(CellType.self, forCellWithReuseIdentifier: identifier)
    }
    
    var height: CGFloat? { nil }
}
