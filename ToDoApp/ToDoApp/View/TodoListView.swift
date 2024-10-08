//
//  TodoListView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct TodoListView: View {
    @State private var todos: [Todo] = []
    @State private var isShowingCreateTaskView = false  
    @State private var isShowingSettingsView = false

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
            .navigationBarItems(
                leading: Button(action: {
                    isShowingSettingsView = true
                }) {
                    Image(systemName: "gearshape")
                },
                trailing: Button(action: {
                    isShowingCreateTaskView = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isShowingCreateTaskView) {
                TodoCreateView(todos: $todos)
            }
            .sheet(isPresented: $isShowingSettingsView) {
                SettingsView(isAuthenticated: .constant(false))
            }
            .onAppear {
                Task {
                    do {
                        todos = try await NetworkingManager.shared.fetchTodos()
                    } catch {
                        print("Error fetching todos: \(error)")
                    }
                }
            }
        }
    }
}



#Preview {
    TodoListView()
}
