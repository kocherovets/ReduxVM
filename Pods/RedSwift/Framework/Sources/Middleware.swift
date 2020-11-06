//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

public typealias DispatchFunction = (Dispatchable) -> Void

open class Middleware {

    public init() { }

    open func on(action: Dispatchable,
                 file: String,
                 function: String,
                 line: Int
    ) {

    }
}

open class StatedMiddleware<State: RootStateType> {

    public init() { }

    open func on(action: Dispatchable,
                 state: State,
                 file: String,
                 function: String,
                 line: Int
    ) {

    }
}


public class LoggingMiddleware: Middleware {

    var consoleLogger = ConsoleLogger()

    var loggingExcludedActions = [Dispatchable.Type]()

    var firstPart: String?
    var startIndex: String.Index?

    public init(loggingExcludedActions: [Dispatchable.Type], firstPart: String? = nil) {

        super.init()
        self.loggingExcludedActions = loggingExcludedActions
        self.firstPart = firstPart
    }

    public override func on(action: Dispatchable,
                            file: String,
                            function: String,
                            line: Int) {

        if loggingExcludedActions.first(where: { $0 == type(of: action) }) == nil {

            let printFile: String
            if startIndex == nil,
                let firstPart = firstPart
            {
                let components = file.components(separatedBy: firstPart + "/")
                if let component = components.last
                    {
                    startIndex = file.index(file.endIndex, offsetBy: -component.count - (firstPart + "/").count)
                }
            }
            if let startIndex = startIndex
            {
                let substring = file[startIndex..<file.endIndex]
                printFile = String(substring)
            }
            else
            {
                printFile = file
            }

            print("---ACTION---", to: &consoleLogger)
            dump(action, to: &consoleLogger)
            print("file: \(printFile):\(line)", to: &consoleLogger)
            print("function: \(function)", to: &consoleLogger)
            print(".", to: &consoleLogger)
            consoleLogger.flush()
        }
    }
}
