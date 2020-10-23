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

var qq = 0

struct TestView2: View {

    struct Props: SwiftUIProperties {
        var color: Color = .green
        var counterText = "Counter: 0"
        var pickerTitle = "Add"
        var options = ["1", "10", "100"]
        var optionCommands = [Command]()
        var actionIndex = 0
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        required init(store: Store<AppState>, onPropsChanged: ((TestView2.Props) -> ())?) {
            super.init(store: store, onPropsChanged: onPropsChanged)
            qq += 1
            print("qq = \(qq)")
        }

        deinit {
            print("deinit")
            qq -= 1
            print("qq = \(qq)")
        }

        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {
            Props(
                color: box.state.isWhite ? .white : .green,
                counterText: "Counter: \(box.state.counter.counter)",
                pickerTitle: "Add",
                options: ["1", "10", "100"],
                optionCommands: [
                    Command { trunk.dispatch(CounterState.AddAction(actionIndex: 0)) },
                    Command { trunk.dispatch(CounterState.AddAction(actionIndex: 1)) },
                    Command { trunk.dispatch(CounterState.AddAction(actionIndex: 2)) }
                ],
                actionIndex: box.state.counter.actionIndex
            )
        }
    }

    var body: some View {
        BaseView<ZStack, Presenter, Props> { props in
            ZStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Spacer()
                        Text(props.counterText)
                        Text(props.pickerTitle)
                        Picker("",
                               selection: Binding(get: { props.actionIndex },
                                                  set: { props.optionCommands[$0].perform() })
                        ) {
                            ForEach(0 ..< props.options.count, id: \.self) { index in
                                Text(props.options[index])
                            }
                        }
                            .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
                    Spacer()
                }
                    .background(props.color)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct TestView2_Previews: PreviewProvider {
    static var previews: some View {
        TestView2()
    }
}

//struct TestView2_Previews2: PreviewProvider {
//    static var previews: some View
//    {
//        let view = TestView2()
//        view.
//
//        TestView2(optionalProps:
//            TestView2.Props(color: .white,
//                            counterText: "Counter: 10",
//                            pickerTitle: "Add",
//                            options: ["1", "10", "100"],
//                            optionCommands: []
//        ))
//    }
//}

struct BaseView<Content, Presenter, Props>: View where Content: View, Presenter: SwiftUIPresenter<AppState, Props>, Props: SwiftUIProperties
{
    @State var presenter: Presenter?
    @State var optionalProps: Props?
    var props: Props { optionalProps ?? Props() }

    @State var viewBuilder: (Props) -> Content

    init(@ViewBuilder builder: @escaping (Props) -> Content) {
        self._viewBuilder = State<(Props) -> Content>(initialValue: builder)
    }

    var body: some View {

        viewBuilder(props)
            .onAppear { presenter = Presenter(store: container.resolve() as Store<AppState>,
                                              onPropsChanged: { props in self.optionalProps = props }) }
            .onDisappear { optionalProps = nil; presenter?.unsubscribe(); presenter = nil }
    }
}

