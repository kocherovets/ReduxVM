//
//  TVC.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DeclarativeTVC
import RedSwift


public struct TableProps: TableProperties {

    public var tableModel: TableModel

    public init(tableModel: TableModel) {
        self.tableModel = tableModel
    }
}

public protocol TableProperties: Properties, Equatable {

    var tableModel: TableModel { get }
}

open class TVC<Props: TableProperties, PresenterType: PresenterProtocol>: DeclarativeTVC, PropsReceiver {

    private var presenter: PresenterType!
    private var _props: Props?
    public final var props: Props? {
        return _props
    }
    private var workItem: DispatchWorkItem?

    open var rowAnimation: UITableView.RowAnimation?

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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

    final public func set(propsWithDelay: PropsWithDelay?) {

        if props == nil {
            return
        }

        if let props = propsWithDelay?.props as? Props {
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

        workItem?.cancel()

        workItem = DispatchWorkItem {
            DispatchQueue.main.async { [weak self] in

                guard let self = self else { return }

                if let props = propsWithDelay?.props as? Props {
                    self._props = props
                } else {
                    self._props = nil
                }

                print("render \(type(of: self))")
                self.render()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (propsWithDelay?.delay ?? 0), execute: workItem!)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        presenter.onInit()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("subscribe presenter \(type(of: self))")
        presenter.subscribe()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("unsubscribe presenter \(type(of: self))")
        presenter.unsubscribe()
    }

    open func render() {

        if let props = props {
            set(model: props.tableModel)
        }
    }
}
