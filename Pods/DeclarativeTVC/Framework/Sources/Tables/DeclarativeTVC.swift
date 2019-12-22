//
//  DeclarativeTVC.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

open class DeclarativeTVC: UITableViewController {

    private static let stubCell = UITableViewCell()

    private var model: TableModel? = nil
    private var registeredCells = [String]()

    open func set(rows: [CellAnyModel], animations: Animations? = nil) {

        set(model: TableModel(rows: rows), animations: animations)
    }

    open func set(model: TableModel, animations: Animations? = nil) {

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

            tableView.customReload(using: changeset, with: animations) { [weak self] in

                self?.model = newModel
            }
        } else {

            self.model = newModel
            tableView.reloadData()
        }
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return model?.sections.count ?? 0
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.sections[section].rows.count ?? 0
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
//        if let storyBoardCell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: vm).cellAnyType)) {
//            cell = storyBoardCell
//        } else {
//            let cellTypeString = String(describing: type(of: vm).cellAnyType)
//            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
//                let nib = UINib.init(nibName: cellTypeString, bundle: nil)
//                tableView.register(nib, forCellReuseIdentifier: cellTypeString)
//                registeredCells.append(cellTypeString)
//            }
//            cell = tableView.dequeueReusableCell(withIdentifier: cellTypeString, for: indexPath)
//        }

        vm.apply(to: cell)

        return cell
    }

    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let vm = model?.sections[section].header {
            let header = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: vm).headerAnyType))!
            vm.apply(to: header)
            return header.contentView
        }
        return nil
    }

    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if let _ = model?.sections[section].header {
            return UITableView.automaticDimension
        }
        return 0
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] as? SelectableCellModel else { return }

        vm.selectCommand.perform()
    }
}
