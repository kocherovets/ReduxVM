//
//  Service.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 15.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation

public protocol AnySideEffect {

    func condition(box: Any) -> Bool

    func execute(box: Any, trunk: Trunk, service: Any)
}

public protocol SideEffect: AnySideEffect {

    associatedtype SStateType
    associatedtype Service

    func condition(box: StateBox<SStateType>) -> Bool

    func execute(box: StateBox<SStateType>, trunk: Trunk, service: Service)
}

public extension SideEffect {

    func condition(box: Any) -> Bool {

        return condition(box: box as! StateBox<SStateType>)
    }

    func execute(box: Any, trunk: Trunk, service: Any) {

        execute(box: box as! StateBox<SStateType>, trunk: trunk, service: service as! Service)
    }
}

open class Service<State: RootStateType>: StoreSubscriber, Trunk {

    private var store: Store<State>
    public var storeTrunk: StoreTrunk { store }
    public var state: State { store.state }

    open var sideEffects: [AnySideEffect] { [] }

    public init(store: Store<State>) {

        self.store = store
        store.subscribe(self)
        
        onInit()
    }

    open func onInit() {
        
    }
    
    deinit {
        store.unsubscribe(self)
    }

    public func stateChanged(box: StateBox<State>) {

        for sideEffect in sideEffects {
            if sideEffect.condition(box: box) {
                sideEffect.execute(box: box, trunk: self, service: self)
            }
        }
    }
}
