//
//  SideEffects.swift
//  RedSwift
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation

public protocol StoreTrunk {

    func dispatch(_ action: Dispatchable,
                  file: String,
                  function: String,
                  line: Int)
}

public protocol Trunk {

    var storeTrunk: StoreTrunk { get }

    func dispatch(_ action: Dispatchable,
                  file: String,
                  function: String,
                  line: Int)
}

extension Trunk {

    public func dispatch(_ action: Dispatchable,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {

        storeTrunk.dispatch(action, file: file, function: function, line: line)
    }

}

public struct SideEffectTrunk: Trunk {
    
    public var storeTrunk: StoreTrunk
}

public protocol SideEffectDependencyContainer: class { }

public protocol AnySideEffect: Dispatchable {

    func sideEffect<R: RootStateType>(state: R,
                                      trunk: Trunk,
                                      dependencies: SideEffectDependencyContainer)

}

public protocol SideEffect: AnySideEffect {

    associatedtype State: RootStateType

    associatedtype DependencyContainer: SideEffectDependencyContainer

    func sideEffect(state: State,
                    trunk: Trunk,
                    dependencies: DependencyContainer)
}

public extension SideEffect {

    func sideEffect<R: RootStateType>(state: R,
                                      trunk: Trunk,
                                      dependencies: SideEffectDependencyContainer) {

        guard let typedState = state as? State else {
            fatalError("Side effect body invoked with the wrong state type")
        }

        guard let typedDependencyContainer = dependencies as? DependencyContainer else {
            fatalError("Side effect body invoked with the wrong dependecy container type")
        }

        self.sideEffect(state: typedState,
                        trunk: trunk,
                        dependencies: typedDependencyContainer)
    }
}

