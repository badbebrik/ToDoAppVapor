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
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
