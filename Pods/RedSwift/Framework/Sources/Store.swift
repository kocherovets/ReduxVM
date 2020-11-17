//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

public struct AddSubscriberAction: Dispatchable { }

open class Store<State: RootStateType>: StoreTrunk {

    typealias SubscriptionType = SubscriptionBox<State>

    public var state: State { box.ref.val }

    private(set) public var box: StateBox<State>

    var subscriptions: Set<SubscriptionType> = []

    public let queue: DispatchQueue

    private var middleware: [Middleware] = []
    private var statedMiddleware: [StatedMiddleware<State>] = []

    private var throttleActions = [String: TimeInterval]()

    public required init(
        state: State,
        queue: DispatchQueue,
        middleware: [Middleware] = [],
        statedMiddleware: [StatedMiddleware<State>] = []
    ) {
        self.queue = queue
        self.middleware = middleware
        self.statedMiddleware = statedMiddleware
        self.box = StateBox(state)
    }

    public func subscribe<SelectedState, S: StoreSubscriber> (_ subscriber: S)
    where S.StoreSubscriberStateType == SelectedState
    {
        let originalSubscription = Subscription<State>()

        let subscriptionBox = SubscriptionBox(originalSubscription: originalSubscription,
                                              subscriber: subscriber)

        subscriptions.update(with: subscriptionBox)

        originalSubscription.newValues(box: box)
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
                
                action.updateState(box: self.box)
                
                self.box.lastAction = action
                
                self.subscriptions.forEach {
                    if $0.subscriber == nil {
                        self.subscriptions.remove($0)
                    } else {
                        $0.newValues(box: self.box)
                    }
                }
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

final class Ref<T> {
  var val : T
  init(_ v : T) {val = v}
}

public struct StateBox<T> {
    
    var ref : Ref<T>
    
    public init(_ x : T) {
        ref = Ref(x)
    }
    
    public var state: T { ref.val }
    
    fileprivate(set) public var lastAction: Dispatchable?
}

