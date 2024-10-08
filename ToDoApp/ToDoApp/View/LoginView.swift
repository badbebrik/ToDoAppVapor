//
//  LoginView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 06.10.2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegisterScreen = false
    @Binding var isAuthenticated: Bool
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Login")
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
                        try await NetworkingManager.shared.login(email: email, password: password)
                        isAuthenticated = true
                    } catch {
                        errorMessage = error.localizedDescription 
                    }
                }
            }) {
                Text("Sign In")
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

            Button(action: {
                showingRegisterScreen = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }
            .sheet(isPresented: $showingRegisterScreen) {
                RegisterView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}




#Preview {
    LoginView(isAuthenticated: .constant(false))
}
