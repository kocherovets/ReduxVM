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
    
    enum DelayedIncrement {
        case requested
        case none
    }
    var delayedIncrement = DelayedIncrement.none
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
    }
}

struct RequestIncrementAction: Action {

    func updateState(_ state: inout State) {

        state.counter.delayedIncrement = .requested
    }
}

struct SetRequestedIncrementAction: Action {

    let value: Int

    func updateState(_ state: inout State) {

        state.counter.counter += value
        state.counter.delayedIncrement = .none
    }
}
