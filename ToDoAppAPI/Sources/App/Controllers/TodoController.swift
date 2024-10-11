import Vapor
import Fluent
import VaporToOpenAPI

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos").grouped(AuthenticatedUserMiddleware())
        todos.get(use: index)
            .openAPI(
                    summary: "Получить список задач",
                    description: "Возвращает список всех задач для текущего аутентифицированного пользователя.",
                    response: .type([TodoDTO].self),
                    statusCode: .ok,
                    auth: .bearer()
                )
        todos.post(use: create)
            .openAPI(
                    summary: "Создать задачу",
                    description: "Создает новую задачу для текущего пользователя.",
                    body: .type(TodoDTO.self),
                    response: .type(TodoDTO.self),
                    statusCode: .created,
                    auth: .bearer()
                )
        todos.group(":todoID") { todo in
            
            todo.get(use: getById)
                .openAPI(
                    summary: "Получить задачу по ID",
                    description: "Возвращает данные задачи для текущего аутентифицированного пользователя по ID.",
                    path: OpenAPIParameters.schema(.object(properties: [
                        "todoID": .string(description: "ID задачи")
                    ])),
                    response: .type(TodoDTO.self),
                    auth: .bearer()
                )
            
            
            todo.put(use: update)
                .openAPI(
                        summary: "Обновить задачу",
                        description: "Обновляет данные существующей задачи по указанному ID для текущего пользователя.",
                        path: OpenAPIParameters.schema(.object(properties: [
                            "todoID": .string(description: "ID задачи")
                        ])),
                        body: .type(TodoDTO.self),
                        response: .type(TodoDTO.self),
                        responseDescription: "Успешное обновление задачи",
                        statusCode: .ok,
                        auth: .bearer()
                    )
            todo.delete(use: delete)
                .openAPI(
                    summary: "Удалить задачу",
                    description: "Удаляет задачу по указанному ID для текущего пользователя.",
                    path: OpenAPIParameters.schema(.object(properties: [
                        "todoID": .string(description: "ID задачи")
                    ])),
                    responseDescription: "Задача успешно удалена",
                    statusCode: .noContent,
                    auth: .bearer()
                )

        }
    }

    func index(req: Request) async throws -> [TodoDTO] {
        let user = try req.auth.require(User.self)
        
        let todos = try await Todo.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()
        
        return todos.map { todo in
            TodoDTO(id: todo.id, title: todo.title, isCompleted: todo.isCompleted)
        }
    }

    func create(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        let todoDTO = try req.content.decode(TodoDTO.self)
        
        let todo = Todo(title: todoDTO.title, isCompleted: todoDTO.isCompleted, userID: try user.requireID())
        try await todo.save(on: req.db)
        return TodoDTO(id: todo.id, title: todo.title, isCompleted: todo.isCompleted)
    }
    
    func getById(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db),
              todo.$user.id == user.id else {
            throw Abort(.notFound)
        }

        return TodoDTO(id: todo.id, title: todo.title, isCompleted: todo.isCompleted)
    }

    func update(req: Request) async throws -> TodoDTO {
        let user = try req.auth.require(User.self)
        let updatedTodoDTO = try req.content.decode(TodoDTO.self)
        
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db),
              todo.$user.id == user.id else {
            throw Abort(.notFound)
        }
        
        todo.title = updatedTodoDTO.title
        todo.isCompleted = updatedTodoDTO.isCompleted
        try await todo.update(on: req.db)
        return TodoDTO(id: todo.id, title: todo.title, isCompleted: todo.isCompleted)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db),
              todo.$user.id == user.id else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }
}

