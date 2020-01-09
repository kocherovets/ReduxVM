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


public struct TableProps: TableProperties, Equatable {

    public var tableModel: TableModel
    public var animations: DeclarativeTVC.Animations?

    public init(tableModel: TableModel, animations: DeclarativeTVC.Animations? = nil) {
        self.tableModel = tableModel
        self.animations = animations
    }
}

public protocol TableProperties: Properties {

    var tableModel: TableModel { get }
}

open class TVC: DeclarativeTVC {

    public var presenter: PresenterProtocol?
    private var _props: Properties?
    public final var generalProps: Properties? {
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

//        presenter = PresenterType.init(propsReceiver: self)
    }

    public func applyProps(newProps: Properties?) {

        if let props = newProps  {
            self._props = props
        } else {
            self._props = nil
        }

        print("render \(type(of: self))")
        self.render()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        presenter?.onInit()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("subscribe presenter \(type(of: self))")
        presenter?.subscribe()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("unsubscribe presenter \(type(of: self))")
        presenter?.unsubscribe()
    }

    open func render() {

        if let props = generalProps as? TableProperties {
            set(model: props.tableModel)
        }
    }
}
