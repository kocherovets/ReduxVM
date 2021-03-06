//
//  TestStore.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import RedSwift
import Foundation

func delay(_ delay: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

struct TestState: StateType, Equatable {
    var companyName: String = "test"
}

struct AppState: RootStateType, Equatable {
    var test = TestState()
    var counter = CounterState()
    
    var isWhite = false
}

let storeQueue = DispatchQueue(label: "queueTitle", qos: .userInteractive)

class TestStore: Store<AppState> {

}


extension AppState
{
    struct DetailViewAction: Action {

        func updateState(_ state: inout AppState) {

            state.isWhite = true
        }
    }
}
