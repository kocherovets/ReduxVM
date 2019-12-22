//
//  MenuTVC.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 22.12.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

enum MenuTVCModule {

    typealias ViewConroller = MenuTVC

    class DI: DIPart {
        static func load(container: DIContainer) {

            container.register(ViewConroller.self)
                .injection(\ViewConroller.presenter) { $0 as Presenter }
                .lifetime(.objectGraph)

            container.register (Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .lifetime(.objectGraph)
        }
    }

    class Presenter: PresenterBase<State, TableProps, ViewConroller> {

        override func reaction(for box: StateBox<State>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<State>, trunk: Trunk) -> TableProps? {

            let rows: [CellAnyModel] = [
                SimpleCodeCellVM(titleText: "View Controller",
                                 selectCommand: Command { Router.showVC() }),
            SimpleCodeCellVM(titleText: "Base With Props View Controller",
                             selectCommand: Command { Router.showBaseWithPropsVC() }),
            SimpleCodeCellVM(titleText: "Child View Controller",
                             selectCommand: Command { Router.showChildVC() }),
            ]

            return TableProps(tableModel: TableModel(rows: rows))
        }
    }
}

class SimpleCodeCell: CodeTableViewCell {

}

struct SimpleCodeCellVM: CellModel, SelectableCellModel {

    let titleText: String?
    var selectCommand: Command

    func apply(to cell: SimpleCodeCell) {

        cell.textLabel?.text = titleText
    }
}


class MenuTVC: TVC, PropsReceiver {

    typealias Props = TableProps

}
