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
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        override init(store: Store<AppState>, onPropsChanged: ((TestView2.Props) -> ())?) {
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
                    Command { trunk.dispatch(AddAction(value: 1)) },
                    Command { trunk.dispatch(AddAction(value: 10)) },
                    Command { trunk.dispatch(AddAction(value: 100)) }
                ]
            )
        }
    }

    @State fileprivate var selectorIndex = 0

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Spacer()
                Text(props.counterText)
                Text(props.pickerTitle)
                Picker("", selection: $selectorIndex) {
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

            .onChange(of: selectorIndex) { value in props.optionCommands[self.selectorIndex].perform() }

            .onAppear { presenter = Presenter(store: container.resolve() as Store<AppState>,
                                              onPropsChanged: { props in self.optionalProps = props }) }
            .onDisappear { optionalProps = nil; presenter?.unsubscribe(); presenter = nil }
    }

    @State var presenter: Presenter?
    @State var optionalProps: Props?
    var props: Props { optionalProps ?? Props() }
}


struct TestView2_Previews: PreviewProvider {
    static var previews: some View {
        TestView2()
    }
}

struct TestView2_Previews2: PreviewProvider {
    static var previews: some View
    {
        TestView2(optionalProps:
            TestView2.Props(color: .white,
                            counterText: "Counter: 10",
                            pickerTitle: "Add",
                            options: ["1", "10", "100"],
                            optionCommands: []
        ))
    }
}
