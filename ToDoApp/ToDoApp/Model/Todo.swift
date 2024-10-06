//
//  Todo.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import Foundation

struct Todo: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}

