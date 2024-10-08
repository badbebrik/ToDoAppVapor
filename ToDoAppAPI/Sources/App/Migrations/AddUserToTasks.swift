//
//  File.swift
//  
//
//  Created by Виктория Серикова on 07.10.2024.
//

import Fluent

struct AddUserToTasks: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks")
            .field("user_id", .uuid, .required, .references("users", "id"))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tasks")
            .deleteField("user_id")
            .update()
    }
}

