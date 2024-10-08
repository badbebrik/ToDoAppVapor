import Vapor
import Fluent

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos").grouped(AuthenticatedUserMiddleware())
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.put(use: update)
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [TodoDTO] {
        let user = try req.auth.require(User.self)
        
        let tasks = try await Task.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()
        
        return tasks.map { task in
            TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
        }
    }

    func create(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        let todoDTO = try req.content.decode(TodoDTO.self)
        
        let task = Task(title: todoDTO.title, isCompleted: todoDTO.isCompleted, userID: try user.requireID())
        try await task.save(on: req.db)
        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }
    
    func getById(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db),
              task.$user.id == user.id else {
            throw Abort(.notFound)
        }

        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }

    func update(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        let updatedTodoDTO = try req.content.decode(TodoDTO.self)
        
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db),
              task.$user.id == user.id else {
            throw Abort(.notFound)
        }
        
        task.title = updatedTodoDTO.title
        task.isCompleted = updatedTodoDTO.isCompleted
        try await task.update(on: req.db)
        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db),
              task.$user.id == user.id else {
            throw Abort(.notFound)
        }
        try await task.delete(on: req.db)
        return .noContent
    }
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

