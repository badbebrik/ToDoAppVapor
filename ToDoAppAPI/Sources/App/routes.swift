import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    .openAPI(summary: "Приветствие", description: "Возвращает 'Hello, world!'", response: .type(String.self))
    
    app.get("swagger", "swagger.json") { req -> EventLoopFuture<Response> in
        let openAPISpec = app.routes.openAPI(info: .init(title: "My API", version: "1.0.0"))
        let jsonResponse = try! JSONEncoder().encode(openAPISpec)
        return req.eventLoop.future(
            Response(status: .ok, body: .init(data: jsonResponse))
        )
    }
    
    app.get("cucumber") { req in
        return req.view.render("cucumber")
    }
    
    let taskController = TodoController()
    try app.register(collection: taskController)
    let userController = UserController()
    try app.register(collection: userController)

}
