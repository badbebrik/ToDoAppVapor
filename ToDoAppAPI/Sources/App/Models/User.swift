//
//  File.swift
//  
//
//  Created by Виктория Серикова on 07.10.2024.
//

import Vapor
import Fluent

final class User: Model, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String

    @Children(for: \.$user)
    var todos: [Todo]
    
    init() { }

    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}
