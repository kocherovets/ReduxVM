//
//  Presenter.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DeclarativeTVC
import RedSwift

public protocol Properties {

}

public enum ReactionToState {
    case router(Command)
    case command(Command)
    case props
    case none
}

public protocol PresenterProtocol {

    func onInit()
    func onDeinit()
    func subscribe()
    func unsubscribe()
}

open class PresenterBase<State: RootStateType, Props: Properties, PR: PropsReceiver>: StoreSubscriber, PresenterProtocol, Trunk {

    public weak var propsReceiver: PR! {
        didSet {
            stateChanged(box: StateBox<State>(state: store.state,
                                              oldState: store.state,
                                              lastAction: store.lastAction))
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

    public final func subscribe() {

        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.subscribe(self)
        }
    }

    public final func unsubscribe() {

        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.unsubscribe(self)
        }
    }

    public final func stateChanged(box: StateBox<State>) {

        switch reaction(for: box) {
        case .router(let command):
            DispatchQueue.main.async {
                command.perform()
            }
        case .command(let command):
            command.perform()
        case .props:
            propsReceiver?.set(newProps: props(for: box, trunk: self))
        case .none:
            return
        }
    }

    open func reaction(for box: StateBox<State>) -> ReactionToState {

        return .props
    }

    open func props(for box: StateBox<State>, trunk: Trunk) -> Props? {

        return nil
    }
}
