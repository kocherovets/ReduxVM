//
//  DeclarativeTVC.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 02.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

open class DeclarativeTVC: UITableViewController, Table {

    var model: TableModel? = nil
    var registeredCells = [String]()

    open func set(rows: [CellAnyModel], animations: Animations? = nil, completion: (() -> Void)? = nil) {

        set(model: TableModel(rows: rows), animations: animations, completion: completion)
    }

    open func set(model: TableModel, animations: Animations? = nil, completion: (() -> Void)? = nil) {

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

            tableView.customReload(
                using: changeset,
                with: animations,
                setData: { [weak self] in

                    self?.model = newModel
                },
                completion: {
                    completion?()
                }
            )
        } else {

            self.model = newModel
            tableView.reloadData()
            completion?()
        }
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        model?.sections.count ?? 0
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model?.sections[section].rows.count ?? 0
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell(for: indexPath)
    }

    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        header(for: section)
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        headerTitle(for: section)
    }

    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footer(for: section)
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        footerTitle(for: section)
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForCell(at: indexPath)
    }

    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heightForHeader(inSection: section)
    }

    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heightForFooter(inSection: section)
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] as? SelectableCellModel else { return }

        vm.selectCommand.perform()
    }
}
