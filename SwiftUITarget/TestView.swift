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
        var navBarText = "Demo"
        var counterText = "Counter: 0"
        var add1Text = "Add 1"
        var add150Text = "Add 150"
        var showDetailViewText = "Show Detail View"
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
                navBarText: "Demo",
                counterText: "Counter: \(box.state.counter.counter)",
                add1Text: "Add 1",
                add150Text: "Add 150",
                showDetailViewText: "Show Detail View",
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
                Text(props.counterText)
                Button(props.add1Text) {
                    props.add1Command.perform()
                }
                Button(props.add150Text) {
                    props.add150Command.perform()
                }
                NavigationLink(destination: TestView2())
                {
                    Text(props.showDetailViewText)
                } .simultaneousGesture(TapGesture().onEnded {
                    props.detailViewCommand.perform()
                })
                    .navigationBarTitle(props.navBarText)

                    .onAppear { presenter = Presenter(store: container.resolve() as Store<AppState>,
                                                      onPropsChanged: { props in self.optionalProps = props }) }
                    .onDisappear { optionalProps = nil; presenter = nil }
            }
        }
    }

    @State var presenter: Presenter?
    @State var optionalProps: Props?
    var props: Props { optionalProps ?? Props() }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestView_Previews2: PreviewProvider {
    static var previews: some View
    {
        TestView(optionalProps:
            TestView.Props(navBarText: "Demo",
                           counterText: "Counter: 10",
                           add1Text: "Add 1",
                           add150Text: "Add 150",
                           showDetailViewText: "Show Detail View",
                           add1Command: Command { },
                           add150Command: Command { },
                           detailViewCommand: Command { })
        )
    }
}
