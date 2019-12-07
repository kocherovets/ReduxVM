//
//  Middleware.swift
//  ReSwift
//
//  Created by Benji Encz on 12/24/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

public typealias DispatchFunction = (Dispatchable) -> Void
public typealias DispatchMiddlewareFunction = (Dispatchable) -> Void
public typealias Middleware<State> = (@escaping DispatchMiddlewareFunction, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction
