//
//  CollectionDS.swift
//  DeclarativeTVC
//
//  Created by Dmitry Kocherovets on 03.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DifferenceKit

open class CollectionDS: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    private var model: CollectionModel? = nil
    private var registeredCells = [String]()

    private var collectionView: UICollectionView?

    open func set(collectionView: UICollectionView?, items: [CellAnyModel], animated: Bool) {

        set(collectionView: collectionView, model: CollectionModel(items: items), animated: animated)
    }

    open func set(collectionView: UICollectionView?, model: CollectionModel, animated: Bool) {

        if self.collectionView != collectionView {
            self.collectionView = collectionView
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
        }

        let newModel = model

        if animated, let model = self.model {

            let source: [ArraySection<String, Int>] = model.sections.map { section in
                ArraySection(model: section.differenceIdentifier,
                             elements: section.items.map { $0.innerHashValue() })
            }
            let target: [ArraySection<String, Int>] = newModel.sections.map { section in
                ArraySection(model: section.differenceIdentifier,
                             elements: section.items.map { $0.innerHashValue() })
            }

            let changeset = StagedChangeset(
                source: source,
                target: target
            )

            self.model = newModel

            collectionView?.reload(using: changeset, interrupt: { $0.changeCount > 100 }) { [weak self] _ in
                self?.model = newModel
            }
        } else {

            self.model = newModel
            self.collectionView?.reloadData()
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model?.sections.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.sections[section].items.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let vm = model?.sections[indexPath.section].items[indexPath.row] else { return UICollectionViewCell() }

        let cell: UICollectionViewCell
        switch vm.cellType() {
        case .storyboard:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type(of: vm).cellAnyType),
                                                      for: indexPath)
        case .xib:
            let cellTypeString = String(describing: type(of: vm).cellAnyType)
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                let nib = UINib.init(nibName: cellTypeString, bundle: nil)
                collectionView.register(nib, forCellWithReuseIdentifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeString, for: indexPath)
        case .code:
            let cellTypeString = String(describing: type(of: vm).cellAnyType)
            if registeredCells.firstIndex(where: { $0 == cellTypeString }) == nil {
                vm.register(collectionView: collectionView, identifier: cellTypeString)
                registeredCells.append(cellTypeString)
            }
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeString, for: indexPath)
        }

        vm.apply(to: cell)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let vm = model?.sections[indexPath.section].items[indexPath.row] as? SelectableCellModel else { return }

        vm.selectCommand.perform()
    }
}
