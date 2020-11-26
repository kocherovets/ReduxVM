//
//  BaseWithProps.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 22.12.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

enum ModuleBaseWithPropsVC {

    typealias ViewController = BaseWithPropsVC

    class DI: DIPart {
        static func load(container: DIContainer) {

            container.register(ViewController.self)
                .injection(\ViewController.presenter) { $0 as Presenter }
                .lifetime(.objectGraph)

            container.register (Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .lifetime(.objectGraph)
        }
    }


    struct Props: Properties, Equatable {
        let color: String
    }

    class Presenter: PresenterBase<State, Props, ViewController> {

        override func props(for box: StateBox<State>, trunk: Trunk) -> Props? {

            return Props(
                color: "#FF0000"
            )
        }
    }
}

class BaseWithPropsVC: BaseVC, PropsReceiver {

    typealias Props = ModuleBaseWithPropsVC.Props

    override func render() {

        guard let props = props else { return }

        self.view.backgroundColor = UIColor(hex: props.color)
      
    }
}
