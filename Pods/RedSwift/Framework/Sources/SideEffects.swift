//
//  SideEffects.swift
//  RedSwift
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation

public protocol StoreTrunk {

    func dispatch(_ action: Dispatchable,
                  file: String,
                  function: String,
                  line: Int)
}

public protocol Trunk {

    var storeTrunk: StoreTrunk { get }

    func dispatch(_ action: Dispatchable,
                  file: String,
                  function: String,
                  line: Int)
}

extension Trunk {

    public func dispatch(_ action: Dispatchable,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {

        storeTrunk.dispatch(action, file: file, function: function, line: line)
    }

}
