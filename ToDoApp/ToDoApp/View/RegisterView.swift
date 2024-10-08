//
//  RegisterView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isAuthenticated: Bool
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Button(action: {
                Task {
                    do {
                        try await NetworkingManager.shared.register(email: email, password: password)
                        try await NetworkingManager.shared.login(email: email, password: password)
                        isAuthenticated = true
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Sign Up")
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
    }
}


#Preview {
    RegisterView(isAuthenticated: .constant(false))
}
