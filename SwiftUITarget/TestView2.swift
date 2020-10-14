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

struct TestView2: View {

    struct Props: SwiftUIProperties {
        var color: Color = .green
        var counterText: String = "0"
        var options = ["1", "10", "100"]
        var optionCommands = [Command]()
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {
            Props(
                color: box.state.isWhite ? .white : .green,
                counterText: "\(box.state.counter.counter)",
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
                Text("Counter: " + props.counterText)
                Text("Add")
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
                                              onPropsChanged: { props in self.properties = props }) }
            .onDisappear { properties = nil; presenter = nil }
    }

    @State var presenter: Presenter?
    @State var properties: Props?
    var props: Props { properties ?? Props() }
}


struct TestView2_Previews: PreviewProvider {
    static var previews: some View {
        TestView2()
    }
}

struct TestView2_Previews2: PreviewProvider {
    static var previews: some View
    {
        TestView2(properties: TestView2.Props(color: .white,
                                              counterText: "10"
        ))
    }
}
