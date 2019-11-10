//
//  CounterState.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import RedSwift

struct CounterState: StateType, Equatable {

    var counter: Int = 0
    var incrementRequested = false
}

struct IncrementAction: Action {

    func updateState(_ state: inout State) {
        state.counter.counter += 1
    }
}

struct AddAction: Action {

    let value: Int

    func updateState(_ state: inout State) {

        state.counter.counter += value
        state.counter.incrementRequested = false
    }
}

struct RequestIncrementAction: Action {

    func updateState(_ state: inout State) {

        state.counter.incrementRequested = true
    }
}

struct RequestIncrementSE: SideEffect {

    func sideEffect(state: State, trunk: Trunk, dependencies: DependencyContainer) {

        trunk.dispatch(RequestIncrementAction())

        dependencies.api.test { value in
            trunk.dispatch(AddAction(value: value))
        }
    }
}
