//
//  SceneDelegate.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootViewController = ViewController()
        //let rootViewController = ObjcViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
