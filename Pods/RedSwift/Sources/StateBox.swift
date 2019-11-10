//
//  StateBox.swift
//  RedSwift
//
//  Created by Dmitry Kocherovets on 25/06/2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

public struct StateBox<T> {
    
    public let state: T
    private let oldState: T?
    
    public init(state: T, oldState: T?) {
        self.state = state
        self.oldState = oldState
    }
    
    public func isNew<E: Equatable>(keyPath: KeyPath<T, E>) -> Bool {
        guard let oldState = oldState else { return true }
        return state[keyPath: keyPath] != oldState[keyPath: keyPath]
    }
    
    public func unsafeGetOldState() -> T? {
        return oldState
    }
}
