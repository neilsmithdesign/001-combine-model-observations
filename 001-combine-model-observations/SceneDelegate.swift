//
//  SceneDelegate.swift
//  001-combine-model-observations
//
//  Created by Neil Smith on 29/03/2020.
//  Copyright © 2020 Neil Smith Design LTD. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController(model: Model()))
        self.window?.makeKeyAndVisible()
    }
    
}

