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
    var actionIndex = 0
    
    enum DelayedIncrement {
        case requested
        case none
    }
    var delayedIncrement = DelayedIncrement.none
}

extension CounterState {

    struct AddAction: Action {

        let actionIndex: Int

        func updateState(_ state: inout AppState) {

            state.counter.actionIndex = actionIndex
            switch actionIndex {
            case 0:
                state.counter.counter += 1
            case 1:
                state.counter.counter += 10
            case 2:
                state.counter.counter += 100
            default:
                return
            }
        }
    }
}

struct IncrementAction: Action {

    func updateState(_ state: inout AppState) {
        state.counter.counter += 1
    }
}

struct AddAction: Action {

    let value: Int

    func updateState(_ state: inout AppState) {

        state.counter.counter += value
    }
}

struct RequestIncrementAction: Action {

    func updateState(_ state: inout AppState) {

        state.counter.delayedIncrement = .requested
    }
}

struct SetRequestedIncrementAction: Action {

    let value: Int

    func updateState(_ state: inout AppState) {

        state.counter.counter += value
        state.counter.delayedIncrement = .none
    }
}
