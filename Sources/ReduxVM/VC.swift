//
//  VC.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import UIKit

public protocol PropsReceiver: UIViewController {
    associatedtype PropsType: Properties, Equatable

    var skipEqualProps: Bool { get }

    var generalProps: Properties? { get }
    var props: PropsType? { get }

    func set(newProps: Properties?)

    func applyProps(newProps: Properties?)
    func render()

    var presenter: PresenterProtocol? { get set }
}

public protocol TablePropsReceiver: PropsReceiver where PropsType: TableProperties {
}

extension PropsReceiver {
    public var props: PropsType? { generalProps as? PropsType }

    public var skipEqualProps: Bool { false }

    public func set(newProps: Properties?) {
        if let newProps = newProps as? PropsType {
            if skipEqualProps, let currentProps = props, currentProps == newProps {
                if ReduxVMSettings.logSkipRenderMessages {
                    print("skip render \(type(of: self))")
                }
                return
            }
        } else {
            if props == nil {
                if ReduxVMSettings.logSkipRenderMessages {
                    print("skip render \(type(of: self))")
                }
                return
            }
        }

        if Thread.isMainThread {
            applyProps(newProps: newProps)
        } else {
            DispatchQueue.main.async {
                self.applyProps(newProps: newProps)
            }
        }
    }
}

open class VC: UIViewController {
    public var presenter: PresenterProtocol?

    private var _props: Properties?
    public final var generalProps: Properties? {
        return _props
    }

    private var renderOnViewWillAppear = true
    private var uiIsReady = false
    private var workItem: DispatchWorkItem?

    public func applyProps(newProps: Properties?) {
        renderOnViewWillAppear = true

        if let props = newProps {
            _props = props
        } else {
            _props = nil
        }

        if uiIsReady {
            if ReduxVMSettings.logRenderMessages {
                print("render \(type(of: self))")
            }
            render()
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        uiIsReady = true

//        presenter?.onInit()

        render()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("subscribe presenter \(type(of: self))")
//        }
//        presenter?.subscribe()

//        if renderOnViewWillAppear {
//            render()
//        }
//        renderOnViewWillAppear = false
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("unsubscribe presenter \(type(of: self))")
//        }
//        presenter?.unsubscribe()
    }

    open func render() {
    }
}
