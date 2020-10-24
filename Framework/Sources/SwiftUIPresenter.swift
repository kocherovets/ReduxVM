//
//  Presenter.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import SwiftUI
import RedSwift
import Combine

public protocol SwiftUIProperties {

    init()
}

open class SwiftUIPresenter<State: RootStateType, Props: SwiftUIProperties>: StoreSubscriber, PresenterProtocol, Trunk, ObservableObject {
    
    @Published public var props: Props?

    private var store: Store<State>

    public var storeTrunk: StoreTrunk { store }

//    public var onPropsChanged: ((Props) -> ())?

    public func onInit() {
        onInit(state: store.state, trunk: self)
    }

    public func onDeinit() {
        onDeinit(state: store.state, trunk: self)
    }

    public required init(store: Store<State>) {

        self.store = store

        subscribe()

        stateChanged(box: StateBox<State>(state: store.state,
                                          oldState: store.state,
                                          lastAction: store.lastAction))
    }

    deinit {
        unsubscribe()
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

        props = nil
        
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
            let p = props(for: box, trunk: self)
            DispatchQueue.main.async { [weak self] in
//                self?.onPropsChanged?(p)
                self?.props = p
            }
        case .none:
            return
        }
    }

    open func reaction(for box: StateBox<State>) -> ReactionToState {

        return .props
    }

    open func props(for box: StateBox<State>, trunk: Trunk) -> Props {

        return Props()
    }
}
