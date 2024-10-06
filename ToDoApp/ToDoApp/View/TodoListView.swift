//
//  TodoListView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct TodoListView: View {
    @State private var todos = [
        Todo(id: UUID(), title: "Buy potato", isCompleted: false),
        Todo(id: UUID(), title: "Do homework", isCompleted: true)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(todos) { todo in
                    NavigationLink(destination: TodoEditView(todo: $todos[todos.firstIndex(where: { $0.id == todo.id })!])) {
                        HStack {
                            Text(todo.title)
                            Spacer()
                            if todo.isCompleted {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: Button(action: {
            
            }) {
                Image(systemName: "plus")
            })
        }
    }
}

#Preview {
    TodoListView()
}
