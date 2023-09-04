//
//  LoadingScreen.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 9/3/23.
//

import UIKit

class LoadingScreenController: UIViewController {
    
    let healthService = HealthService()
    
    override func viewDidLoad() {
        Task {
            let result = await healthService.check()
            if let healthStatus = result, healthStatus == "Healthy" {
                if await HttpClient.shared.isUserLoggedInAsync() {
                    goToMainScreen()
                } else {
                    let sceneDelegate = UIApplication.shared.connectedScenes
                            .first!.delegate as! SceneDelegate
                    sceneDelegate.showLoginScreen(callback: goToMainScreen)
                }
            } else {
                showAlert(title: "Server Connection Error", message: "Sorry, could not connect to the server. Please restart the application.")
            }
        }
    }
    
    func goToMainScreen() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    sceneDelegate.window?.rootViewController = mainViewController
                    UIView.setAnimationsEnabled(oldState)
                }, completion: nil)
            }
        }
    }
}
