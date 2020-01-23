//
//  ApiService.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 15.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation

struct ApiDependencies {
    
}

class ApiService: Service<State, ApiDependencies> {

    override var sideEffects: [AnySideEffect] {
        [
            DelaySE()
        ]
    }

}

extension ApiService {

    fileprivate struct DelaySE: SideEffect {

        func condition(box: StateBox<State>) -> Bool {

            return box.state.counter.delayedIncrement == .requested && box.isNew(keyPath: \.counter.delayedIncrement)
        }

        func execute(box: StateBox<State>, trunk: Trunk, dependencies: ApiDependencies) {

            delay(5) {
                trunk.dispatch(SetRequestedIncrementAction(value: 150))
            }
        }
    }
}
