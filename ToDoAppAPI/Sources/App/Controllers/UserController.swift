//
//  File.swift
//  
//
//  Created by Виктория Серикова on 07.10.2024.
//

import Vapor
import Fluent
import JWT
import VaporToOpenAPI

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("register", use: register)
            .openAPI(
                summary: "Регистрация нового пользователя",
                description: "Создает нового пользователя с предоставленными email и паролем. Возвращает информацию о созданном пользователе.",
                body: .type(RegisterDTO.self),
                response: .type(UserDTO.self),
                responseDescription: "Успешная регистрация. Возвращается информация о пользователе.",
                statusCode: .created
            )

        users.post("login", use: login)
            .openAPI(
                summary: "Вход в систему",
                description: "Позволяет пользователю войти в систему с использованием email и пароля. Возвращает JWT-токен при успешной авторизации.",
                body: .type(LoginDTO.self),
                response: .type(UserTokenDTO.self),
                responseDescription: "Успешная авторизация. Возвращается JWT-токен.",
                statusCode: .ok
            )
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

struct AuthenticatedUserMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try req.jwt.verify(as: UserTokenPayload.self)
        guard let user = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.unauthorized)
        }
        req.auth.login(user)
        return try await next.respond(to: req)
    }
}
