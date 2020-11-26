//
//  ApiService.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 15.01.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift

class ApiInteractor: Interactor<AppState> {

    override var sideEffects: [AnySideEffect] {
        [
            DelaySE()
        ]
    }

}

extension ApiInteractor {

    fileprivate struct DelaySE: SideEffect {

        func condition(box: StateBox<AppState>) -> Bool {

            return box.state.counter.delayedIncrement == .requested &&
                (box.lastAction is RequestIncrementAction || box.lastAction is SetRequestedIncrementAction)
        }

        func execute(box: StateBox<AppState>, trunk: Trunk, interactor: ApiInteractor) {

            delay(5) {
                trunk.dispatch(SetRequestedIncrementAction(value: 150))
            }
        }
    }
}
