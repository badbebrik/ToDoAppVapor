//
//  TodoEditView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct TodoEditView: View {
    @Binding var todo: Todo
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Task title", text: $todo.title)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Toggle(isOn: $todo.isCompleted) {
                Text("Completed")
            }
            .padding()

            Button(action: {
                Task {
                    do {
                    
                        try await NetworkingManager.shared.updateTodo(id: todo.id, title: todo.title, isCompleted: todo.isCompleted)
                        
                    
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Save Changes")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
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
        .navigationTitle("Edit Task")
    }
}


#Preview {
    TodoEditView(todo: .constant(Todo(id: UUID(), title: "Buy book", isCompleted: false)))
}
