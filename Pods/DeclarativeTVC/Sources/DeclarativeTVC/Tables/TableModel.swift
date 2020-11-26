//
//  TableModel.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

public struct TableSection {

    public let header: TableHeaderAnyModel?
    public let footer: TableFooterAnyModel?
    public var rows: [CellAnyModel]

    fileprivate var orderNumber: Int = 0
    
    public init(header: TableHeaderAnyModel?, rows: [CellAnyModel], footer: TableFooterAnyModel?) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }
}

extension String: Differentiable { }

extension TableSection: Differentiable {

    public var differenceIdentifier: String {
        if let hash = header?.innerHashValue() {
            return String(hash)
        }
        return "Section \(orderNumber)"
    }

    public func isContentEqual(to source: TableSection) -> Bool {
        return differenceIdentifier == source.differenceIdentifier
    }
}

public struct TableModel: Equatable {

    public var sections: [TableSection]

    public static func == (lhs: TableModel, rhs: TableModel) -> Bool {

        if lhs.sections.count != rhs.sections.count {
            return false
        }

        for i in 0 ..< lhs.sections.count {

            if lhs.sections[i].rows.count != rhs.sections[i].rows.count {
                return false
            }

            for ii in 0 ..< lhs.sections[i].rows.count {
                if lhs.sections[i].rows[ii].innerHashValue() != rhs.sections[i].rows[ii].innerHashValue() {
                    return false
                }
            }
        }

        return true
    }

    public init(sections: [TableSection]) {

        self.sections = sections
        
        for i in 0 ..< self.sections.count {
            self.sections[i].orderNumber = i
        }
    }

    public init(rows: [CellAnyModel]) {

        self.sections = [TableSection(header: nil, rows: rows, footer: nil)]
    }
}
