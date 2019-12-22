//
//  Router.swift
//  ReduxVM
//
//  Created by Dmitry Kocherovets on 22.12.2019.
//  Copyright © 2019 Dmitry Kocherovets. All rights reserved.
//

fileprivate func createVC<T: UIViewController>(storyboardName: String, type: T.Type) -> T {

    UIStoryboard(name: storyboardName, bundle: nil)
        .instantiateViewController(withIdentifier: String(describing: T.self)) as! T
}

class Router {

    private static var topmostViewController: UIViewController {
        return UIApplication.shared.keyWindow!.topmostViewController!
    }

    private static var navigationController: UINavigationController? {
        return UIApplication.shared.keyWindow!.topmostViewController!.navigationController
    }

    static func showVC() {

        ui {
            let vc = createVC(storyboardName: "Main", type: TestVC.self)
            UIViewController.topNavigationController()?.pushViewController(vc, animated: true)
        }
    }

    static func showBaseWithPropsVC() {

        ui {
            let vc = createVC(storyboardName: "Main", type: BaseWithPropsVC.self)
            UIViewController.topNavigationController()?.pushViewController(vc, animated: true)
        }
    }

    static func showChildVC() {

        ui {
            let vc = createVC(storyboardName: "Main", type: ChildVC.self)
            UIViewController.topNavigationController()?.pushViewController(vc, animated: true)
        }
    }
}

extension UIViewController {

    static var topmostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.topmostViewController
    }

    @objc var topmostViewController: UIViewController? {
        return presentedViewController?.topmostViewController ?? self
    }

    static func topNavigationController(vc: UIViewController? = nil) -> UINavigationController? {

        let vc = vc ?? UIApplication.shared.keyWindow!.rootViewController
        if let nc = vc as? UINavigationController {
            return nc
        }
        if let tab = vc as? UITabBarController {
            return topNavigationController(vc: tab.selectedViewController)
        }
        if let parent = vc?.children.last {
            return topNavigationController(vc: parent)
        }
        return nil
    }
}

extension UINavigationController {

    @objc override var topmostViewController: UIViewController? {
        return visibleViewController?.topmostViewController
    }
}

extension UITabBarController {

    @objc override var topmostViewController: UIViewController? {
        return selectedViewController?.topmostViewController
    }
}

extension UIWindow {

    var topmostViewController: UIViewController? {
        return rootViewController?.topmostViewController
    }
}

func ui(closure: @escaping () -> ()) {
    let when = DispatchTime.now()
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
