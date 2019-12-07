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

    func updatedState(currentState: StateType) -> StateType
}

public protocol Action: AnyAction {

    associatedtype State: StateType

    func updateState(_ state: inout State)
}

public extension Action {

    func updatedState(currentState: StateType) -> StateType {

        guard var typedState = currentState as? State else {
            fatalError("[Katana] updateState invoked with the wrong state type")
        }

        self.updateState(&typedState)

        return typedState
    }
}
