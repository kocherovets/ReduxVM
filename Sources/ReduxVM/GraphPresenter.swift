//
//  File.swift
//
//
//  Created by Dmitry Kocherovets on 02.01.2021.
//

import DeclarativeTVC
import UIKit

public protocol TVCOwner {
    associatedtype TableViewController: TVC & PropsReceiver

    var tvc: TableViewController { get }
}

open class GraphPresenterBase<Graph, Props: Properties, PR: PropsReceiver>: GraphSubscriber, PresenterProtocol {
    public typealias GraphSubscriberGraphType = Graph

    public weak var propsReceiver: PR! {
        didSet {
            onInit()
            propsReceiver.presenter = self
            if ReduxVMSettings.logSubscribeMessages {
                print("subscribe presenter \(type(of: self))")
            }
            subscribe()
            if let graph = store.graph {
                graphChanged(graph: graph)
            }
        }
    }

    private var store: GraphStore

    public func onInit() {
        if let graph = store.graph as? Graph {
            onInit(graph: graph)
        }
    }

    public func onDeinit() {
        if let graph = store.graph as? Graph {
            onDeinit(graph: graph)
        }
    }

    public init(store: GraphStore) {
        self.store = store
//        onInit()
    }

    deinit {
        onDeinit()

        if ReduxVMSettings.logSubscribeMessages {
            print("unsubscribe presenter \(type(of: self))")
        }
        store.queue.sync {
            store.unsubscribe(self)
        }
    }

    open func onInit(graph: Graph) { }
    open func onDeinit(graph: Graph) { }

    private var firstPass = true

    private func subscribe() {
        store.queue.sync { [weak self] in
            guard let self = self else { return }
            store.graphSubscribe(self)
        }
    }

//    public final func unsubscribe() {
//        store.unsubscribe(self)
//    }

    public final func graphChanged(graph: Graph) {
        let block = { [weak self] in
            guard let self = self else { return }
            switch self.reaction(for: graph) {
            case .props:
                self.propsReceiver?.set(newProps: self.props(for: graph))
            case .none:
                return
            }
        }
        if Thread.current.threadName == store.queue.label {
            block()
        } else if firstPass {
            firstPass = false
            var props: Properties?
            store.queue.sync { [weak self] in
                guard let self = self else { return }
                props = self.props(for: graph)
            }
            propsReceiver?.set(newProps: props)
        } else {
            store.queue.async {
                block()
            }
        }
    }

    open func reaction(for graph: Graph) -> ReactionToState {
        return .props
    }

    open func props(for graph: Graph) -> Props? {
        return nil
    }
}
