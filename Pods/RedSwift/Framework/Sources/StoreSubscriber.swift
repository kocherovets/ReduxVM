//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

public protocol AnyStoreSubscriber: class {
    // swiftlint:disable:next identifier_name
    func stateChanged(box: Any)
}

public protocol StoreSubscriber: AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func stateChanged(box: StateBox<StoreSubscriberStateType>)
}

extension StoreSubscriber {
    // swiftlint:disable:next identifier_name
    public func stateChanged(box: Any)
    {
        if let typedBox = box as? StateBox<StoreSubscriberStateType> {
            
            stateChanged(box: typedBox)
        }
    }
}
