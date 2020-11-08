//
//  Presenter.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import RedSwift
import SwiftUI
import Combine

public protocol SwiftUIProperties {

    init()
}

@available(iOS 13, *)
open class SwiftUIPresenter<State: RootStateType, Props: SwiftUIProperties>: StoreSubscriber, PresenterProtocol, Trunk, ObservableObject {

    @Published public var props: Props = Props()

    private var store: Store<State>

    public var storeTrunk: StoreTrunk { store }

    private var firstPass = true

    private var subscribed = false
    public var freezed = false {
        didSet {
            if !freezed {
                firstPass = true
                stateChanged(box: StateBox<State>(state: store.state,
                                                  oldState: store.state,
                                                  lastAction: store.lastAction)) }
        }
    }

    public func onInit() {
        onInit(state: store.state, trunk: self)
    }

    public func onDeinit() {
        onDeinit(state: store.state, trunk: self)
    }

    public required init(store: Store<State>) {

        self.store = store
        
        onInit()

//        subscribe()
//
//        stateChanged(box: StateBox<State>(state: store.state,
//                                          oldState: store.state,
//                                          lastAction: store.lastAction))
    }

    deinit {
        unsubscribe()
        onDeinit()
    }

    open func onInit(state: State, trunk: Trunk) { }
    open func onDeinit(state: State, trunk: Trunk) { }

    public final func subscribe() {

        if subscribed {
            return
        }

        firstPass = true
        subscribed = true

        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.subscribe(self)
        }
    }

    public final func unsubscribe() {

        if !subscribed {
            return
        }
        
        props = Props()

        firstPass = true
        subscribed = false

        store.queue.async { [weak self] in

            guard let self = self else { return }

            self.store.unsubscribe(self)
        }
    }

    public final func stateChanged(box: StateBox<State>) {

        if freezed {
            return
        }
        
        if firstPass {
            firstPass = false
            let p = props(for: box, trunk: self)
            DispatchQueue.main.async { [weak self] in
                self?.props = p
            }
        }
        else {
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
                    self?.props = p
                }
            case .none:
                return
            }
        }
    }

    open func reaction(for box: StateBox<State>) -> ReactionToState {

        return .props
    }

    open func props(for box: StateBox<State>, trunk: Trunk) -> Props {

        return Props()
    }
}
