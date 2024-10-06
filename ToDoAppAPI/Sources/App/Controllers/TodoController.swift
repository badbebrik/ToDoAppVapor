import Vapor
import Fluent

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.put(use: update)
            todo.delete(use: delete)
        }
    }

    // Получить все задачи
    func index(req: Request) async throws -> [TodoDTO] {
        let tasks = try await Task.query(on: req.db).all()
        return tasks.map { task in
            TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
        }
    }

    // Создать новую задачу
    func create(req: Request) async throws -> TodoDTO {
        let todoDTO = try req.content.decode(TodoDTO.self)
        let task = Task(title: todoDTO.title, isCompleted: todoDTO.isCompleted)
        try await task.save(on: req.db)
        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }
    
    // Задача по id
    func getById(req: Request) async throws -> TodoDTO {
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }

    // Обновить существующую задачу
    func update(req: Request) async throws -> TodoDTO {
        let updatedTodoDTO = try req.content.decode(TodoDTO.self)
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        task.title = updatedTodoDTO.title
        task.isCompleted = updatedTodoDTO.isCompleted
        try await task.update(on: req.db)
        return TodoDTO(id: task.id, title: task.title, isCompleted: task.isCompleted)
    }

    // Удалить задачу
    func delete(req: Request) async throws -> HTTPStatus {
        guard let task = try await Task.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await task.delete(on: req.db)
        return .noContent
    }

}
