import Fluent
import Vapor


func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    let taskController = TodoController()
    try app.register(collection: taskController)
    let userController = UserController()
    try app.register(collection: userController)

}
