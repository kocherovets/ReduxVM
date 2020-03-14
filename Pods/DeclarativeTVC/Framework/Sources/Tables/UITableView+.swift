//
//  UITableView+.swift
//  Framework
//
//  Created by Dmitry Kocherovets on 09.02.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import UIKit

protocol Table: class {

    var model: TableModel? { get }
    var registeredCells: [String] { get set }
    var tableView: UITableView! { get }
}

extension Table {

    func cell(for indexPath: IndexPath) -> UITableViewCell {

        guard let vm = model?.sections[indexPath.section].rows[indexPath.row] else { return UITableViewCell() }

        let cellTypeString = String(describing: type(of: vm).cellAnyType)

        switch vm.cellType() {
        case .storyboard:
            break
        case .xib:
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                let nib = UINib.init(nibName: cellTypeString, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
        case .code:
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                vm.register(tableView: tableView, identifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellTypeString, for: indexPath)

        vm.apply(to: cell)

        return cell
    }

    func header(for section: Int) -> UIView? {

        if let vm = model?.sections[section].header {

            let typeString = String(describing: type(of: vm).headerAnyType)

            switch vm.cellType() {
            case .storyboard:
                break
            case .xib:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    let nib = UINib.init(nibName: typeString, bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: typeString)
                    registeredCells.append(typeString)
                }
            case .code:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    vm.register(tableView: tableView, identifier: typeString)
                    registeredCells.append(typeString)
                }
            }
            let header = tableView.dequeueReusableCell(withIdentifier: typeString)!
            vm.apply(to: header)
            return header.contentView
        }
        return nil
    }

    func footer(for section: Int) -> UIView? {

        if let vm = model?.sections[section].footer {

            let typeString = String(describing: type(of: vm).footerAnyType)

            switch vm.cellType() {
            case .storyboard:
                break
            case .xib:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    let nib = UINib.init(nibName: typeString, bundle: nil)
                    tableView.register(nib, forCellReuseIdentifier: typeString)
                    registeredCells.append(typeString)
                }
            case .code:
                if registeredCells.firstIndex(where: { $0 == typeString }) == nil {
                    vm.register(tableView: tableView, identifier: typeString)
                    registeredCells.append(typeString)
                }
            }
            
            let footer = tableView.dequeueReusableCell(withIdentifier: typeString)!
            vm.apply(to: footer)
            return footer.contentView
        }
        return nil
    }
    
    func heightForCell(at indexPath: IndexPath) -> CGFloat {

        if let height = model?.sections[indexPath.section].rows[indexPath.row].height {
            return height
        }
        return UITableView.automaticDimension
    }

    func heightForHeader(inSection section: Int) -> CGFloat {

        if let height = model?.sections[section].header?.height {
            return height
        }
        return UITableView.automaticDimension
    }

    func heightForFooter(inSection section: Int) -> CGFloat {

        if let height = model?.sections[section].footer?.height {
            return height
        }
        return UITableView.automaticDimension
    }
}
