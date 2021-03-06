//
//  ViewController.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

enum ModuleVC {

    typealias ViewController = TestVC

    class DI: DIPart {
        static func load(container: DIContainer) {

            container.register(ViewController.self)
                .injection(\ViewController.presenter) { $0 as Presenter }
                .lifetime(.objectGraph)

            container.register (Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .injection(\Presenter.api)
                .lifetime(.objectGraph)
        }
    }

    struct Props: Properties, Equatable {
        let counterText: String
        let add1Command: Command
        let add150Command: Command
        let showActivityIndicator: Bool
    }

    class Presenter: PresenterBase<State, Props, ViewController> {
        
        var api: ApiInteractor!

        override func onInit(state: State, trunk: Trunk) {
            trunk.dispatch(AddAction(value: 10))
        }

        override func reaction(for box: StateBox<State>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<State>, trunk: Trunk) -> Props? {

            return Props(
                counterText: "\(box.state.counter.counter)",
                add1Command: Command {
                    trunk.dispatch(IncrementAction())
                },
                add150Command: Command {
                    trunk.dispatch(RequestIncrementAction())
                },
                showActivityIndicator: box.state.counter.delayedIncrement == .requested
            )
        }
    }
}

class TestVC: VC, PropsReceiver {

    typealias Props = ModuleVC.Props

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var add1Button: UIButton!
    @IBOutlet weak var add150Button: UIButton!
    @IBOutlet weak var activityIndicatorV: UIActivityIndicatorView!

    override func render() {

        guard let props = props else { return }

        companyNameLabel.text = props.counterText

        if props.showActivityIndicator {
            activityIndicatorV.startAnimating()
            add1Button.isHidden = true
            add150Button.isHidden = true
        } else {
            activityIndicatorV.stopAnimating()
            add1Button.isHidden = false
            add150Button.isHidden = false
        }
    }

    @IBAction func addAction1() {
        props?.add1Command.perform()
    }

    @IBAction func addAction150() {
        props?.add150Command.perform()
    }
}
