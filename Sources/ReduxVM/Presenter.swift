//
//  Presenter.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import DeclarativeTVC
import UIKit

public protocol Properties {
}

public enum ReactionToState {
    case props
    case none
}

public protocol PresenterProtocol: AnyObject {
    func onInit()
    func onDeinit()
//    func subscribe()
//    func unsubscribe()
}

open class PresenterBase<State: StateType, Props: Properties, PR: PropsReceiver>: StateSubscriber, PresenterProtocol, Trunk {
    public weak var propsReceiver: PR! {
        didSet {
            propsReceiver.presenter = self
            stateChanged(box: store.box)
        }
    }

    private var store: Store<State>

    public var storeTrunk: StoreTrunk { store }

    public func onInit() {
        onInit(state: store.state, trunk: self)
    }

    public func onDeinit() {
        onDeinit(state: store.state, trunk: self)
    }

    public init(store: Store<State>) {
        self.store = store
    }

    deinit {
        onDeinit()
    }

    open func onInit(state: State, trunk: Trunk) { }
    open func onDeinit(state: State, trunk: Trunk) { }

    private var firstPass = true

    public final func subscribe() {
        firstPass = true

        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.stateSubscribe(self)
        }
    }

    public final func unsubscribe() {
        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.unsubscribe(self)
        }
    }

    public final func stateChanged(box: StateBox<State>) {
        if firstPass {
            firstPass = false
            propsReceiver?.set(newProps: props(for: box, trunk: self))
        } else {
            switch reaction(for: box) {
            case .props:
                propsReceiver?.set(newProps: props(for: box, trunk: self))
            case .none:
                return
            }
        }
    }

    open func reaction(for box: StateBox<State>) -> ReactionToState {
        return .props
    }

    open func props(for box: StateBox<State>, trunk: Trunk) -> Props? {
        return nil
    }
}
