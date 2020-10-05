//
//  ContentView.swift
//  SwiftUITarget
//
//  Created by Dmitry Kocherovets on 03.10.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import SwiftUI
import DITranquillity
import Framework
import RedSwift
import Combine
import DeclarativeTVC

struct TestView: View {

    struct Props: SwiftUIProperties {
        var counterText: String = "0"
        var add1Command: Command?
        var add150Command: Command?
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {

            Props(
                counterText: "\(box.state.counter.counter)",
                add1Command: Command {
                    trunk.dispatch(IncrementAction())
                },
                add150Command: Command {
                    trunk.dispatch(RequestIncrementAction())
                }
            )
        }
    }

    @ObservedObject var presenter: Presenter
    var props: Props { presenter.props }
        
    var body: some View {
        VStack(spacing: 10) {
            Text(props.counterText)
            Button("Add 1") {
                props.add1Command?.perform()
            }
            Button("Add 150") {
                props.add150Command?.perform()
            }
        }
    }
    
    class DI: DIPart
    {
        static func load(container: DIContainer)
        {
            container.register(Props.init).lifetime(.prototype)
            container.register{ Presenter(store: $0, props: $1) }.lifetime(.prototype)
            container.register{ TestView(presenter: $0) }.lifetime(.prototype)
        }
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        container.resolve() as TestView
    }
}

struct Test2View_Previews: PreviewProvider {
    static var previews: some View
    {
        let view = container.resolve() as TestView
        
        view.presenter.props = TestView.Props(
            counterText: "10",
            add1Command: nil,
            add150Command: nil
        )
        
        return view
    }
}
