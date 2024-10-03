import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks")
            .id()
            .field("title", .string, .required)
            .field("isCompleted", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks").delete()
    }
}


