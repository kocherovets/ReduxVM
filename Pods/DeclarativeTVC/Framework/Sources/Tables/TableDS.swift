//
//  TableDS.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 01.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

open class TableDS: NSObject, UITableViewDelegate, UITableViewDataSource {

    private var model: TableModel? = nil
    private var registeredCells = [String]()

    private var tableView: UITableView?

    open func set(tableView: UITableView?, rows: [CellAnyModel], animations: DeclarativeTVC.Animations? = nil) {

        set(tableView: tableView, model: TableModel(rows: rows), animations: animations)
    }

    open func set(tableView: UITableView?, model: TableModel, animations: DeclarativeTVC.Animations? = nil) {

        if self.tableView != tableView {
            self.tableView = tableView
            self.tableView?.dataSource = self
            self.tableView?.delegate = self
        }

        let newModel = model

        if let animations = animations, let model = self.model {

            let source: [ArraySection<String, Int>] = model.sections.map { section in
                ArraySection(model: section.differenceIdentifier,
                             elements: section.rows.map { $0.innerHashValue() })
            }
            let target: [ArraySection<String, Int>] = newModel.sections.map { section in
                ArraySection(model: section.differenceIdentifier,
                             elements: section.rows.map { $0.innerHashValue() })
            }

            let changeset = StagedChangeset(
                source: source,
                target: target
            )

            self.model = newModel

            tableView?.customReload(using: changeset, with: animations) { [weak self] in

                self?.model = newModel
            }
        } else {

            self.model = newModel
            tableView?.reloadData()
        }
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return model?.sections.count ?? 0
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.sections[section].rows.count ?? 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] else { return UITableViewCell() }

        let cell: UITableViewCell
        switch vm.cellType() {
        case .storyboard:
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: vm).cellAnyType))!
        case .xib:
            let cellTypeString = String(describing: type(of: vm).cellAnyType)
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                let nib = UINib.init(nibName: cellTypeString, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
            cell = tableView.dequeueReusableCell(withIdentifier: cellTypeString, for: indexPath)
        case .code:
            let cellTypeString = String(describing: type(of: vm).cellAnyType)
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                vm.register(tableView: tableView, identifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
            cell = tableView.dequeueReusableCell(withIdentifier: cellTypeString, for: indexPath)
        }

        vm.apply(to: cell)

        return cell
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let vm = model?.sections[section].header {
            let header = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: vm).headerAnyType))!
            vm.apply(to: header)
            return header.contentView
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if let _ = model?.sections[section].header {
            return UITableView.automaticDimension
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let height = model?.sections[indexPath.section].rows[indexPath.row].height {
            return height
        }
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] as? SelectableCellModel else { return }

        vm.selectCommand.perform()
    }
}
