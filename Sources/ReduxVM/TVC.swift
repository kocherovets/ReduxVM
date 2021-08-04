//
//  TVC.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import DeclarativeTVC
import UIKit

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
    var animations: DeclarativeTVC.Animations? { get }
}

open class TVC: DeclarativeTVC {
    public var presenter: PresenterProtocol?
    private var _props: Properties?
    public final var generalProps: Properties? {
        return _props
    }

    private var workItem: DispatchWorkItem?

    open var rowAnimation: UITableView.RowAnimation?

    public func applyProps(newProps: Properties?) {
        if let props = newProps {
            _props = props
        } else {
            _props = nil
        }

        if ReduxVMSettings.logRenderMessages {
            print("render \(type(of: self))")
        }
        render()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

//        presenter?.onInit()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("subscribe presenter \(type(of: self))")
//        }
//        presenter?.subscribe()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("unsubscribe presenter \(type(of: self))")
//        }
//        presenter?.unsubscribe()
    }

    open func render() {
        if let props = generalProps as? TableProperties {
            set(model: props.tableModel, animations: props.animations)
        }
    }
}

public class PreviewCellTVC: TVC, PropsReceiver {
    public typealias PropsType = TableProps

    let contentInset: UIEdgeInsets?
    let backgroundColor: UIColor

    public init(model: CellAnyModel,
                separatorStyle: UITableViewCell.SeparatorStyle = .none,
                contentInset: UIEdgeInsets? = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0),
                backgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)) {
        self.contentInset = contentInset
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
        set(newProps: TableProps(tableModel: TableModel(rows: [model])))
        tableView.separatorStyle = separatorStyle
    }

    public init(tableModel: TableModel,
                separatorStyle: UITableViewCell.SeparatorStyle = .none,
                contentInset: UIEdgeInsets? = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0),
                backgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)) {
        self.contentInset = contentInset
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
        set(newProps: TableProps(tableModel: tableModel))
        tableView.separatorStyle = separatorStyle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let contentInset = contentInset {
            tableView.contentInset = contentInset
        }
        tableView.backgroundColor = backgroundColor
    }
}

public class PreviewCellCVC: CVC, PropsReceiver {
    public typealias PropsType = CollectionProps

    let contentInset: UIEdgeInsets?
    let backgroundColor: UIColor

    public init(model: CollectionCellAnyModel,
                contentInset: UIEdgeInsets? = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0),
                backgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)) {
        self.contentInset = contentInset
        self.backgroundColor = backgroundColor
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        set(newProps: CollectionProps(collectionModel: CollectionModel(items: [model])))
    }

    public init(collectionModel: CollectionModel,
                contentInset: UIEdgeInsets? = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0),
                backgroundColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)) {
        self.contentInset = contentInset
        self.backgroundColor = backgroundColor
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        set(newProps: CollectionProps(collectionModel: collectionModel))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let contentInset = contentInset {
            collectionView.contentInset = contentInset
        }
        collectionView.backgroundColor = backgroundColor
    }
}
