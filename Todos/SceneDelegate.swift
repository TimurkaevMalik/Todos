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
        
        setupNavigationBarAppearance()
        
        let window = UIWindow(windowScene: windowScene)
        let navigationVC = UINavigationController(rootViewController: TasksModuleBuilder.build())
        
        self.window = window
        window.rootViewController = navigationVC
//        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBlack
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.appWhite
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.appWhite
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().tintColor = .appWhite
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .default
    }
}
