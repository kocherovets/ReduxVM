//
//  SubscriberWrapper.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

/// A box around subscriptions and subscribers.
///
/// Acts as a type-erasing wrapper around a subscription and its transformed subscription.
/// The transformed subscription has a type argument that matches the selected substate of the
/// subscriber; however that type cannot be exposed to the store.
///
/// The box subscribes either to the original subscription, or if available to the transformed
/// subscription and passes any values that come through this subscriptions to the subscriber.
class SubscriptionBox<State>: Hashable {

    private let originalSubscription: Subscription<State>
    weak var subscriber: AnyStoreSubscriber?
    private let objectIdentifier: ObjectIdentifier

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectIdentifier)
    }

    init(
        originalSubscription: Subscription<State>,
        subscriber: AnyStoreSubscriber
    ) {
        self.originalSubscription = originalSubscription
        self.subscriber = subscriber
        self.objectIdentifier = ObjectIdentifier(subscriber)

        originalSubscription.observer = { [unowned self] prevState, newState, lastAction in
            self.subscriber?.stateChanged(newState: newState as Any, prevState: prevState, lastAction: lastAction)
        }
    }

    func newValues(oldState: State, newState: State, lastAction: Dispatchable?) {
        // We pass all new values through the original subscription, which accepts
        // values of type `<State>`. If present, transformed subscriptions will
        // receive this update and transform it before passing it on to the subscriber.
        self.originalSubscription.newValues(oldState: oldState, newState: newState, lastAction: lastAction)
    }

    static func == (left: SubscriptionBox<State>, right: SubscriptionBox<State>) -> Bool {
        return left.objectIdentifier == right.objectIdentifier
    }
}

/// Represents a subscription of a subscriber to the store. The subscription determines which new
/// values from the store are forwarded to the subscriber, and how they are transformed.
/// The subscription acts as a very-light weight signal/observable that you might know from
/// reactive programming libraries.
public class Subscription<State> {

    private func _select<Substate>(_ selector: @escaping (State) -> Substate) -> Subscription<Substate>
    {
        return Subscription<Substate> { sink in
            self.observer = { oldState, newState, lastAction in
                sink(oldState.map(selector) ?? nil, selector(newState), lastAction)
            }
        }
    }

    // MARK: Public Interface

    /// Initializes a subscription with a sink closure. The closure provides a way to send
    /// new values over this subscription.
    public init(sink: @escaping (@escaping (State?, State, Dispatchable?) -> Void) -> Void) {
        // Provide the caller with a closure that will forward all values
        // to observers of this subscription.
        sink { old, new, lastAction in
            self.newValues(oldState: old, newState: new, lastAction: lastAction)
        }
    }

    /// Provides a subscription that selects a substate of the state of the original subscription.
    /// - parameter selector: A closure that maps a state to a selected substate
    public func select<Substate>(_ selector: @escaping (State) -> Substate) -> Subscription<Substate>
    {
        return self._select(selector)
    }



    private func _select<Substate>(_ keyPath: KeyPath<State, Substate>) -> Subscription<Substate>
    {
        return Subscription<Substate> { sink in
            self.observer = { oldState, newState, lastAction in
                sink(oldState?[keyPath: keyPath], newState[keyPath: keyPath], lastAction)
            }
        }
    }

    public func select<Substate>(keyPath: KeyPath<State, Substate>) -> Subscription<Substate>
    {
        return self._select(keyPath)
    }

    /// The closure called with changes from the store.
    /// This closure can be written to for use in extensions to Subscription similar to `skipRepeats`
    public var observer: ((State?, State, Dispatchable?) -> Void)?

    // MARK: Internals

    init() { }

    /// Sends new values over this subscription. Observers will be notified of these new values.
    func newValues(oldState: State?, newState: State, lastAction: Dispatchable?) {
        self.observer?(oldState, newState, lastAction)
    }
}
