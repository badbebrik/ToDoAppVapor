//
//  TodoEditView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct TodoEditView: View {
    @Binding var todo: Todo
    
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
        }
        .navigationTitle("Edit Task")
    }
}


#Preview {
    TodoEditView(todo: .constant(Todo(id: UUID(), title: "Buy book", isCompleted: false)))
}
