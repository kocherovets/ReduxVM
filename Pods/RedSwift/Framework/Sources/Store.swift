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

public struct AddSubscriberAction: Dispatchable {}

open class Store<State: RootStateType>: StoreTrunk {

    typealias SubscriptionType = SubscriptionBox<State>

//    private(set) public var state: State! {
    private var _state: State!
    public var state: State { _state! }

    private func set(state: State, lastAction: Dispatchable) {

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
    var loggingExcludedActions = [Dispatchable.Type]()

    private var isDispatching = false
    public let queue: DispatchQueue
    public var lastAction: Dispatchable?
    
    public var dispatchFunction: DispatchFunction!

/// Initializes the store with a reducer, an initial state and a list of middleware.
///
/// Middleware is applied in the order in which it is passed into this constructor.
///
/// - parameter reducer: Main reducer that processes incoming actions.
/// - parameter state: Initial state, if any. Can be `nil` and will be
///   provided by the reducer in that case.
/// - parameter middleware: Ordered list of action pre-processors, acting
///   before the root reducer.
/// - parameter automaticallySkipsRepeats: If `true`, the store will attempt
///   to skip idempotent state updates when a subscriber's state type
///   implements `Equatable`. Defaults to `true`.
    public required init(
        state: State?,
        queue: DispatchQueue,
        loggingExcludedActions: [Dispatchable.Type],
        middleware: [Middleware<State>] = []
    ) {

        self.queue = queue
        self.loggingExcludedActions = loggingExcludedActions

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce(
                { [unowned self] action in
                    self._defaultDispatch(action: action) },
                { dispatchFunction, middleware in
                    // If the store get's deinitialized before the middleware is complete; drop
                    // the action without dispatching.
                    let dispatch: (Dispatchable) -> Void = { [weak self] in self?.dispatch($0) }
                    let getState = { [weak self] in self?.state }
                    return middleware(dispatch, getState)(dispatchFunction)
                })


        self._state = state
    }

    public func subscribe<SelectedState, S: StoreSubscriber> (_ subscriber: S)
    where S.StoreSubscriberStateType == SelectedState
    {
        let originalSubscription = Subscription<State>()

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

// swiftlint:disable:next identifier_name
    private func _defaultDispatch(action: Dispatchable) {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:ConcurrentMutationError- Action has been dispatched while" +
                    " a previous action is action is being processed. A reducer" +
                    " is dispatching an action, or ReSwift is used in a concurrent context" +
                    " (e.g. from multiple threads)."
            )
        }

        isDispatching = true

        let f = { [weak self] in

            guard let self = self else { fatalError() }

            switch action {
            case let action as AnyAction:
                self.set(state: action.updatedState(currentState: self.state) as! State,
                         lastAction: action)
            default:
                break
            }
        }

        if Thread.current.threadName == queue.label {
            f()
        } else {
            queue.async { f() }
        }

        isDispatching = false
    }

    public func dispatch(_ action: Dispatchable,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {

        if loggingExcludedActions.first(where: { $0 == type(of: action) }) == nil {

            var type: String
            switch action {
            case _ as AnyAction:
                type = "---ACTION---"
            default:
                type = "---MIDDLEWARE---"
            }
            let log =
                """
            \(type)
            \(action)
            file: \(file):\(line)
            function: \(function)
            .
            """
            print(log)
        }

        dispatchFunction(action)
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
