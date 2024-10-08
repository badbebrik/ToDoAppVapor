//
//  SettingsView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 08.10.2024.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            Button(action: {
                NetworkingManager.shared.deleteToken()
                isAuthenticated = false
            }) {
                Text("Logout")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    SettingsView(isAuthenticated: .constant(true))
}
