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
        var add1Command: Command = Command { }
        var add150Command: Command = Command { }
        var detailViewCommand: Command = Command { }
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
                },
                detailViewCommand: Command {
                    trunk.dispatch(AppState.DetailViewAction())
                }
            )
        }
    }

    var body: some View {
        NavigationView {

            VStack(spacing: 10) {
                Text("Counter: " + props.counterText)
                Button("Add 1") {
                    props.add1Command.perform()
                }
                Button("Add 150") {
                    props.add150Command.perform()
                }
                NavigationLink(destination: TestView2())
                {
                    Text("Show Detail View")
                } .simultaneousGesture(TapGesture().onEnded {
                    props.detailViewCommand.perform()
                })
                    .navigationBarTitle("Demo")
                    .onAppear { presenter = Presenter(store: container.resolve() as Store<AppState>,
                                                      onPropsChanged: { props in self.properties = props }) }
                    .onDisappear { properties = nil; presenter = nil }
            }
        }
    }

    @State var presenter: Presenter?
    @State var properties: Props?
    var props: Props { properties ?? Props() }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestView_Previews2: PreviewProvider {
    static var previews: some View
    {
        TestView(properties: TestView.Props(counterText: "10",
                                               add1Command: Command { },
                                               add150Command: Command { },
                                               detailViewCommand: Command { }
        ))
    }
}
