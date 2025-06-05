//
//  SceneDelegate.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationVC = UINavigationController(rootViewController: TasksModuleBuilder.build())
        
        self.window = window
        window.rootViewController = navigationVC
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
    }
}
