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
            
            Button(action: {
                
            }) {
                HStack {
                    Image("google_icon")
                        .resizable()
                        .frame(width: 40, height: 30)
                        .clipShape(Circle())
                    Text("Sign Up with Google")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding(20)
        }
    }
}


#Preview {
    RegisterView()
}
