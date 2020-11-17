//
//  Interactor.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 15.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation

public protocol AnySideEffect {

    var queue: DispatchQueue? { get }
    var async: Bool { get }

    func condition(box: Any) -> Bool

    func execute(box: Any, trunk: Trunk, interactor: Any)
}

public protocol SideEffect: AnySideEffect {

    associatedtype SStateType
    associatedtype Interactor
    
    func condition(box: StateBox<SStateType>) -> Bool

    func execute(box: StateBox<SStateType>, trunk: Trunk, interactor: Interactor)
}

public extension SideEffect {

    var queue: DispatchQueue? { nil }
    var async: Bool { true }

    func condition(box: Any) -> Bool {

        return condition(box: box as! StateBox<SStateType>)
    }

    func execute(box: Any, trunk: Trunk, interactor: Any) {

        execute(box: box as! StateBox<SStateType>, trunk: trunk, interactor: interactor as! Interactor)
    }
}

public class InteractorLogger {

    static var consoleLogger = ConsoleLogger()

    public static var loggingExcludedSideEffects = [AnySideEffect.Type]()

    public static var logger: ((AnySideEffect) -> ())? = { sideEffect in

        if loggingExcludedSideEffects.first(where: { $0 == type(of: sideEffect) }) == nil
        {
            print("---SE---", to: &consoleLogger)
            dump(sideEffect, to: &consoleLogger, maxItems: 20)
            print(".", to: &consoleLogger)
            consoleLogger.flush()
        }
    }
}

class ConsoleLogger: TextOutputStream
{
    var buffer = ""

    func flush()
    {
        print(buffer)
        buffer = ""
    }

    func write(_ string: String)
    {
        buffer += string
    }
}

open class Interactor<State: RootStateType>: StoreSubscriber, Trunk {

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

        if condition(box: box) {
            for sideEffect in sideEffects {
                if sideEffect.condition(box: box) {
                    InteractorLogger.logger?(sideEffect)
                    
                    if sideEffect.queue == nil {
                        sideEffect.execute(box: box, trunk: self, interactor: self)
                    } else {
                        if sideEffect.async {
                            sideEffect.queue?.async {
                                sideEffect.execute(box: box, trunk: self, interactor: self)
                            }
                        } else {
                            sideEffect.queue?.sync {
                                sideEffect.execute(box: box, trunk: self, interactor: self)
                            }
                        }
                    }
                }
            }
        }
    }

    open func condition(box: Any) -> Bool {

        return true
    }
}
