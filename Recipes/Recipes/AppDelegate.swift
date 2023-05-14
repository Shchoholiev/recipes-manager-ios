//
//  AppDelegate.swift
//  Recipes
//
//  Created by Serhii Shchoholiev on 12/6/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let healthService = HealthService()
    
    let httpClient = HttpClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Task {
            await healthService.check()
            // remove - it's just an test/example
            let request = GraphQlRequest(
                query: """
                   query RecipeSearchResult($recipeSearchType: RecipesSearchTypes!, $pageNumber: Int!, $pageSize: Int!, $categoriesIds: [String!], $searchString: String!, $authorId: String!) {
                     searchRecipes(recipeSearchType: $recipeSearchType, pageNumber: $pageNumber, pageSize: $pageSize, categoriesIds: $categoriesIds, searchString: $searchString, authorId: $authorId) {
                       items {
                         name
                         createdById
                         categories {
                           id
                         }
                         ingredientsText
                         ingredients {
                           name
                           units
                         }
                         createdBy {
                           name
                           id
                         }
                       },
                       totalItems
                     }
                   }
                """,
                variables: [
                    "recipeSearchType": "PUBLIC",
                    "pageNumber": 1,
                    "pageSize": 10,
                    "categoriesIds": [],
                    "searchString": "",
                    "authorId": ""
                ]
            )
            let res = await httpClient.queryAsync(request)
            print(res)
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

