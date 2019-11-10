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

protocol TableProperties: Properties, Equatable {

    var tableModel: TableModel { get }
}

class HVC<Props: TableProperties, PresenterType: PresenterProtocol>: DeclarativeTVC, PropsReceiver {

    private var presenter: PresenterType!
    private var _props: Props?
    final var props: Props? {
        return _props
    }

    var rowAnimation: UITableView.RowAnimation?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {

        presenter = PresenterType.init(propsReceiver: self)
    }

    final func set(props: Properties?) {

        if props == nil {
            return
        }

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

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            if let props = props as? Props {
                self._props = props
            } else {
                self._props = nil
            }

            print("render \(type(of: self))")
            self.render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.initCommand()?.perform()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("subscribe presenter \(type(of: self))")
        presenter.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("unsubscribe presenter \(type(of: self))")
        presenter.unsubscribe()
    }

    func render() {

        if let props = props {
            set(model: props.tableModel)
        }
    }
}
