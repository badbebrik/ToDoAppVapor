//
//  TodoCreateView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct TodoCreateView: View {
    @Binding var todos: [Todo]
    @State private var title = ""
    @State private var isCompleted = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Task title", text: $title)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Toggle(isOn: $isCompleted) {
                Text("Completed")
            }
            .padding()

            Button(action: {
                Task {
                    do {
                       
                        try await NetworkingManager.shared.createTodo(title: title, isCompleted: isCompleted)
                        
                
                        let newTodo = Todo(id: UUID(), title: title, isCompleted: isCompleted)
                        todos.append(newTodo)
                        
                
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Create Task")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Create Task")
    }
}



#Preview {
    TodoCreateView(todos: .constant([Todo(id: UUID(), title: "Buy potato", isCompleted: true)]))
}
