//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 This class is the default implementation of the `Store` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */

public struct AddSubscriberAction: Dispatchable { }

open class Store<AppState: RootStateType>: StoreTrunk {

    typealias SubscriptionType = SubscriptionBox<AppState>

    private var _state: AppState!
    public var state: AppState { _state! }

    private func set(state: AppState, lastAction: Dispatchable) {

        let oldValue = _state ?? state
        _state = state

        self.lastAction = lastAction

        subscriptions.forEach {
            if $0.subscriber == nil {
                subscriptions.remove($0)
            } else {
                $0.newValues(oldState: oldValue, newState: state, lastAction: lastAction)
            }
        }
    }

    var subscriptions: Set<SubscriptionType> = []

    public let queue: DispatchQueue
    public var lastAction: Dispatchable?

    private var middleware: [Middleware] = []
    private var statedMiddleware: [StatedMiddleware<AppState>] = []

    private var throttleActions = [String: TimeInterval]()

    public required init(
        state: AppState?,
        queue: DispatchQueue,
        middleware: [Middleware] = [],
        statedMiddleware: [StatedMiddleware<AppState>] = []
    ) {

        self.queue = queue
        self.middleware = middleware
        self.statedMiddleware = statedMiddleware
        self._state = state
    }

    public func subscribe<SelectedState, S: StoreSubscriber> (_ subscriber: S)
    where S.StoreSubscriberStateType == SelectedState
    {
        let originalSubscription = Subscription<AppState>()

        let subscriptionBox = SubscriptionBox(originalSubscription: originalSubscription,
                                              subscriber: subscriber)

        subscriptions.update(with: subscriptionBox)

        if let state = self._state {
            originalSubscription.newValues(oldState: nil, newState: state, lastAction: lastAction)
        }
    }

    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {

        if let index = subscriptions.firstIndex(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }

    public func dispatch(_ action: Dispatchable,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {

        if let throttleAction = action as? ThrottleAction
        {
            if
                let interval = throttleActions["\(action)"],
                Date().timeIntervalSince1970 - interval < throttleAction.interval
            {
                print("throttleAction \(action)")
                return
            }
            throttleActions["\(action)"] = Date().timeIntervalSince1970
        }

        queue.async { [weak self] in

            guard let self = self else { fatalError() }

            for middleware in self.middleware {
                middleware.on(action: action, file: file, function: function, line: line)
            }

            for middleware in self.statedMiddleware {
                middleware.on(action: action, state: self.state, file: file, function: function, line: line)
            }

            switch action {
            case let action as AnyAction:
                self.set(state: action.updatedState(currentState: self.state) as! AppState,
                         lastAction: action)
            default:
                break
            }
        }
    }
}

extension Thread {

    var threadName: String {
        if let currentOperationQueue = OperationQueue.current?.name {
            return "OperationQueue: \(currentOperationQueue)"
        } else if let underlyingDispatchQueue = OperationQueue.current?.underlyingQueue?.label {
            return "DispatchQueue: \(underlyingDispatchQueue)"
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }
}
