//
//  File.swift
//  
//
//  Created by Виктория Серикова on 07.10.2024.
//

import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("register", use: register)
        users.post("login", use: login)
    }

    func login(req: Request) async throws -> UserTokenDTO {
        let loginData = try req.content.decode(LoginDTO.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }
        
        if try Bcrypt.verify(loginData.password, created: user.passwordHash) {
            let payload = try generateToken(for: user, req: req)
            
            let token = try req.jwt.sign(payload)
            
            return UserTokenDTO(token: token)
        } else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }
    }

    
    func generateToken(for user: User, req: Request) throws -> UserTokenPayload {
        let expirationTime = Date().addingTimeInterval(3600)
        return UserTokenPayload(
            userID: try user.requireID(),
            exp: ExpirationClaim(value: expirationTime)
        )
    }


    func register(req: Request) async throws -> UserDTO {
        let registerData = try req.content.decode(RegisterDTO.self)
        
        guard try await User.query(on: req.db).filter(\.$email == registerData.email).first() == nil else {
            throw Abort(.badRequest, reason: "User with this email already exists.")
        }
        
        let passwordHash = try Bcrypt.hash(registerData.password)
        
        let user = User(email: registerData.email, passwordHash: passwordHash)
        try await user.save(on: req.db)
        
        return UserDTO(id: user.id, email: user.email)
    }
}



struct UserTokenPayload: JWTPayload {
    var userID: UUID
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}


struct RegisterDTO: Content {
    let email: String
    let password: String
}

struct LoginDTO: Content {
    let email: String
    let password: String
}

struct UserTokenDTO: Content {
    let token: String
}

struct UserDTO: Content {
    let id: UUID?
    let email: String
}

