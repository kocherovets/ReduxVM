//
//  SwiftUITargetApp.swift
//  SwiftUITarget
//
//  Created by Dmitry Kocherovets on 03.10.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import SwiftUI
import CoreData
import RedSwift
import DITranquillity
import RedSwift

public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {

        container.register {
            Store<AppState>(state: AppState(),
                            queue: storeQueue,
                            middleware: [
                                         LoggingMiddleware(loggingExcludedActions: [])
                            ])
        }
            .lifetime(.single)

        container.register (ApiInteractor.init) .lifetime(.single)
        
//        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            container.append(part: TestView.DI.self)
            container.append(part: TestView2.DI.self)
//        }
    }
}

let container = DIContainer()

class AppDelegate: UIResponder, UIApplicationDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        container.append(framework: AppFramework.self)

        #if DEBUG
            if !container.makeGraph().checkIsValid(checkGraphCycles: true) {
                fatalError("invalid graph")
            }
        #endif

        container.initializeSingletonObjects()

        return true
    }
}

@main
struct SwiftUITargetApp: App
{
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            TestView()
        }
    }
}

struct SwiftUITargetApp_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
