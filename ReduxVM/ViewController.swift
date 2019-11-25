//
//  ViewController.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import UIKit
import DeclarativeTVC
import RedSwift

struct Props: Properties, Equatable {
    let counterText: String
    let add1Command: Command
    let add150Command: Command
    let showActivityIndicator: Bool
}

class Presenter: PresenterBase<Props, State, CounterState> {

    override var keyPath: KeyPath<State, CounterState> {
        return \.counter
    }

    override func reaction(for box: StateBox<CounterState>) -> ReactionToState {
        return .props
    }

    override func props(for box: StateBox<CounterState>) -> Props? {

        return Props(
            counterText: "\(box.state.counter)",
            add1Command: Command {
                store.dispatch(IncrementAction())
            },
            add150Command: Command {
                store.dispatch(RequestIncrementSE())
            },
            showActivityIndicator: box.state.incrementRequested
        )
    }
}

class ViewController: VC<Props, Presenter> {

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
