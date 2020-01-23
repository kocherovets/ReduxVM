//
//  Service.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 15.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift


public protocol AnySideEffect {

    func condition(box: Any) -> Bool

    func execute(box: Any, trunk: Trunk, dependencies: Any)
}

public protocol SideEffect: AnySideEffect {

    associatedtype SStateType
    associatedtype Dependencies

    func condition(box: StateBox<SStateType>) -> Bool

    func execute(box: StateBox<SStateType>, trunk: Trunk, dependencies: Dependencies)
}

public extension SideEffect {

    func condition(box: Any) -> Bool {

        return condition(box: box as! StateBox<SStateType>)
    }

    func execute(box: Any, trunk: Trunk, dependencies: Any) {

        execute(box: box as! StateBox<SStateType>, trunk: trunk, dependencies: dependencies as! Dependencies)
    }
}

public struct EmptyDependencies {
    
    public init() {}
}

open class Service<State: RootStateType, Dependencies>: StoreSubscriber, Trunk {

    private var store: Store<State>
    public var storeTrunk: StoreTrunk { store }

    public let dependencies: Dependencies

    open var sideEffects: [AnySideEffect] { [] }

    public init(store: Store<State>, dependencies: Dependencies) {

        self.dependencies = dependencies

        self.store = store
        store.subscribe(self)
        
        onInit()
    }

    public func onInit() {
        
    }
    
    deinit {
        store.unsubscribe(self)
    }

    public func stateChanged(box: StateBox<State>) {

        for sideEffect in sideEffects {
            if sideEffect.condition(box: box) {
                sideEffect.execute(box: box, trunk: self, dependencies: dependencies)
            }
        }
    }
}
