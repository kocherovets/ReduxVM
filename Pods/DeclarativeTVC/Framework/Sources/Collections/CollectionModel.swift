//
//  CollectionModel.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 03.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

public struct CollectionSection {

    public var items: [CellAnyModel]

    fileprivate var orderNumber: Int = 0
    
    init(items: [CellAnyModel]) {
        self.items = items
    }
}

extension CollectionSection: Differentiable {

    public var differenceIdentifier: String {
        return "Section \(orderNumber)"
    }

    public func isContentEqual(to source: CollectionSection) -> Bool {
        return differenceIdentifier == source.differenceIdentifier
    }
}

public struct CollectionModel: Equatable {

    public var sections: [CollectionSection]

    public static func == (lhs: CollectionModel, rhs: CollectionModel) -> Bool {

        if lhs.sections.count != rhs.sections.count {
            return false
        }

        for i in 0 ..< lhs.sections.count {

            if lhs.sections[i].items.count != rhs.sections[i].items.count {
                return false
            }

            for ii in 0 ..< lhs.sections[i].items.count {
                if lhs.sections[i].items[ii].innerHashValue() != rhs.sections[i].items[ii].innerHashValue() {
                    return false
                }
            }
        }

        return true
    }

    public init(sections: [CollectionSection]) {

        self.sections = sections

        for i in 0 ..< self.sections.count {
            self.sections[i].orderNumber = i
        }
    }

    public init(items: [CellAnyModel]) {

        self.sections = [CollectionSection(items: items)]
    }
}
