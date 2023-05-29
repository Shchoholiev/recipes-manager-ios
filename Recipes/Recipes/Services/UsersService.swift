//
//  UsersService.swift
//  Recipes
//
//  Created by Vitalii Krasnorutskyi on 29.05.23.
//

import Foundation


class UsersService: ServiceBase {
    
    init() {
        super.init(url: "/users")
    }
    
    func getCurrentUserAsync() async -> User?{
        let request = GraphQlRequest(
            query: """
            query Query {
            currentUser {
              id
              name
              phone
              email
            }
          }
        """,
            variables: [:]
        )
        let response: GraphQlGenericResponse<User> = await HttpClient.shared.queryAsync(request, propertyName: "currentUser")
        
        return response.data
    }
    
    func getUserAsync(id: String) async -> User?{
        let request = GraphQlRequest(
            query: """
            query User($userId: String!) {
              user(id: $userId) {
                id
                name
                phone
                email
              }
            }
        """,
            variables: ["userId": id]
        )
        let response: GraphQlGenericResponse<User> = await HttpClient.shared.queryAsync(request, propertyName: "user")
        
        return response.data
    }
    
    func subscribeAsync(id: String) async -> Bool{
        let request = GraphQlRequest(
            query: """
              mutation AddSubscription($dto: SubscriptionCreateDtoInput!) {
                addSubscription(dto: $dto) {
                  id
                }
              }
            """,
            variables: [
                "dto": ["authorId" : id]
            ]
        )
        let response: GraphQlResponse = await HttpClient.shared.queryAsync(request)
        
        return response.errors == nil
    }
}
