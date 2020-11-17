//
//  Action.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol Dispatchable { }

public protocol AnyAction: Dispatchable {

    func updateState(box: Any)
}

public protocol Action: AnyAction {

    associatedtype State: StateType

    func updateState(_ state: inout State)
}

public extension Action {

    func updateState(box: Any) {

        let typedBox = box as! StateBox<State>

        self.updateState(&typedBox.ref.val)
    }
}

public protocol ThrottleAction {
    
    var interval: TimeInterval { get }
}

public extension ThrottleAction {
    
    var interval: TimeInterval {
        0.3
    }
}
