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

public protocol PropsReceiver: class {

    func set(props: Properties?)
}

public enum ReactionToState {
    case router(Command)
    case command(Command)
    case props
    case none
}

public protocol PresenterProtocol {
    
    init(propsReceiver: PropsReceiver)
    func initCommand() -> Command?
    func deinitCommand() -> Command?
    func subscribe()
    func unsubscribe()
}

open class PresenterBase<Props: Properties, RootState: RootStateType, S: StateType>: StoreSubscriber, PresenterProtocol where S: Equatable {

    open var keyPath: KeyPath<RootState, S>? { return nil }

    private weak var propsReceiver: PropsReceiver?

    open func initCommand() -> Command? { return nil }
    open func deinitCommand() -> Command? { return nil }

    required public init(propsReceiver: PropsReceiver) {

        self.propsReceiver = propsReceiver

        guard let keyPath = keyPath else { fatalError() }

        stateChanged(box: StateBox<S>(state: StoreDS.store.getState(keyPath: keyPath),
                                      oldState: StoreDS.store.getState(keyPath: keyPath)))
    }

    deinit {
        deinitCommand()?.perform()
    }

    public final func subscribe() {

        StoreQueue.async { [weak self] in

            guard let self = self else { return }

            StoreDS.store.subscribe(self, keyPath: self.keyPath)
        }
    }

    public final func unsubscribe() {

        StoreQueue.async { [weak self] in

            guard let self = self else { return }

            StoreDS.store.unsubscribe(self)
        }
    }

    public final func stateChanged(box: StateBox<S>) {

        switch reaction(for: box) {
        case .router(let command):
            StoreQueue.async {
                DispatchQueue.main.async {
                    command.perform()
                }
            }
        case .command(let command):
            command.perform()
        case .props:
            propsReceiver?.set(props: props(for: box))
        case .none:
            return
        }
    }

    open func reaction(for box: StateBox<S>) -> ReactionToState {

        return .props
    }

    open func props(for box: StateBox<S>) -> Props? {

        return nil
    }
}
