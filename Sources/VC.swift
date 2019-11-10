//
//  VC.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift

open class VC<Props: Properties, PresenterType: PresenterProtocol>: UIViewController, PropsReceiver where Props: Equatable {

    private var presenter: PresenterType!
    private var _props: Props?
    final var props: Props? {
        return _props
    }
    private var renderOnViewWillAppear = true
    private var uiIsReady = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {

        presenter = PresenterType.init(propsReceiver: self)
    }

    final public func set(props: Properties?) {

        if let props = props as? Props {
            if let currentProps = self._props, currentProps == props {
                print("skip render \(type(of: self))")
                return
            }
        } else {
            if self._props == nil {
                print("skip render \(type(of: self))")
                return
            }
        }

        let applyProps = { [weak self] in

            guard let self = self else { return }

            self.renderOnViewWillAppear = true

            if let props = props as? Props {
                self._props = props
            } else {
                self._props = nil
            }

            if self.uiIsReady {
                print("render \(type(of: self))")
                self.render()
            }
        }

        if Thread.isMainThread {
            applyProps()
        } else {
            DispatchQueue.main.async {
                applyProps()
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        uiIsReady = true

        presenter.initCommand()?.perform()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("subscribe presenter \(type(of: self))")
        presenter.subscribe()

        if renderOnViewWillAppear {
            render()
        }
        renderOnViewWillAppear = false
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("unsubscribe presenter \(type(of: self))")
        presenter.unsubscribe()
    }

    open func render() {

    }
}

