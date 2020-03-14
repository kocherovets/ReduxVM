//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

public typealias DispatchFunction = (Dispatchable) -> Void

open class Middleware {

    public func on(action: Dispatchable,
                   file: String,
                   function: String,
                   line: Int
    ) {
        
    }
}

open class StatedMiddleware<State: RootStateType> {

    public func on(action: Dispatchable,
                   state: State,
                   file: String,
                   function: String,
                   line: Int
    ) {

    }
}


public class LoggingMiddleware: Middleware {

    private var loggingExcludedActions = [Dispatchable.Type]()

    public required init(loggingExcludedActions: [Dispatchable.Type]) {

        self.loggingExcludedActions = loggingExcludedActions
    }

    override public func on(action: Dispatchable,
                            file: String,
                            function: String,
                            line: Int) {

        if loggingExcludedActions.first(where: { $0 == type(of: action) }) == nil {

            let log =
                """
                 ---ACTION---
                 \(action)
                 file: \(file):\(line)
                 function: \(function)
                 .
                 """
            print(log)
        }

    }
}
