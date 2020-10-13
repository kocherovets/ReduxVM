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
    }

    class Presenter: SwiftUIPresenter<AppState, Props> {

        override func reaction(for box: StateBox<AppState>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> Props {
            Props(
                color: box.state.isWhite ? .white : .green,
                counterText: "\(box.state.counter.counter)"
            )
        }
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("TestView2 " + props.counterText)
                Spacer()
            }
            Spacer()
        }
            .background(props.color)
            .edgesIgnoringSafeArea(.all)
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
