//
//  CVC.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 25.04.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DeclarativeTVC

public struct CollectionProps: CollectionProperties, Equatable {

    public var collectionModel: CollectionModel
    public var animated: Bool

    public init(collectionModel: CollectionModel, animated: Bool = false) {
        self.collectionModel = collectionModel
        self.animated = animated
    }
}

public protocol CollectionProperties: Properties {

    var collectionModel: CollectionModel { get }
    var animated: Bool { get }
}

open class CVC: DeclarativeCVC {

    public var presenter: PresenterProtocol?
    private var _props: Properties?
    public final var generalProps: Properties? {
        return _props
    }
    private var workItem: DispatchWorkItem?

    public func applyProps(newProps: Properties?) {

        if let props = newProps {
            self._props = props
        } else {
            self._props = nil
        }

        if ReduxVMSettings.logRenderMessages {
            print("render \(type(of: self))")
        }
        self.render()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        presenter?.onInit()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ReduxVMSettings.logSubscribeMessages {
            print("subscribe presenter \(type(of: self))")
        }
//        presenter?.subscribe()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if ReduxVMSettings.logSubscribeMessages {
            print("unsubscribe presenter \(type(of: self))")
        }
//        presenter?.unsubscribe()
    }

    open func render() {

        if let props = generalProps as? CollectionProperties {
            set(model: props.collectionModel, animated: props.animated)
        }
    }
}
