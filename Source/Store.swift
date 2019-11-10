//
//  Store.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 10.11.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import RedSwift

open class StoreDS {
    
    public static var store: (StoreProvider & StateProvider)!
}
