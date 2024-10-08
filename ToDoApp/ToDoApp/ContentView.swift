//
//  ContentView.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 25.09.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            TodoListView()
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
                .onAppear {
                    if NetworkingManager.shared.getToken() != nil {
                        isAuthenticated = true
                    }
                }
        }
        
    }
}



#Preview {
    ContentView()
}
