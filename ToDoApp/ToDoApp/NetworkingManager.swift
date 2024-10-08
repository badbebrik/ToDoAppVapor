//
//  NetworkingManager.swift
//  ToDoApp
//
//  Created by Виктория Серикова on 08.10.2024.
//

import Foundation
import KeychainAccess

class NetworkingManager {
    static let shared = NetworkingManager()
    private let baseURL = "http://localhost:8080"
    private let keychain = Keychain(service: "com.example.TodoApp")

    private init() {}

    // MARK: - Helper Methods
    func getToken() -> String? {
        return keychain["jwtToken"]
    }

    private func saveToken(_ token: String) {
        keychain["jwtToken"] = token
    }

    func deleteToken() {
        keychain["jwtToken"] = nil
    }

    private func makeRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        return request
    }

    // MARK: - Registration
    func register(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/users/register")!
        let body = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        let request = makeRequest(url: url, method: "POST", body: bodyData)
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/users/login")!
        let body = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: makeRequest(url: url, method: "POST", body: bodyData))
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.userAuthenticationRequired)
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: String], let token = json["token"] {
            saveToken(token)
        } else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Fetch Todos
    func fetchTodos() async throws -> [Todo] {
        let url = URL(string: "\(baseURL)/todos")!
        let (data, response) = try await URLSession.shared.data(for: makeRequest(url: url, method: "GET"))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Todo].self, from: data)
    }

    // MARK: - Create Todo
    func createTodo(title: String, isCompleted: Bool) async throws {
        let url = URL(string: "\(baseURL)/todos")!
        let body = ["title": title, "isCompleted": isCompleted] as [String : Any]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: makeRequest(url: url, method: "POST", body: bodyData))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Update Todo
    func updateTodo(id: UUID, title: String, isCompleted: Bool) async throws {
        let url = URL(string: "\(baseURL)/todos/\(id)")!
        let body = ["title": title, "isCompleted": isCompleted] as [String : Any]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: makeRequest(url: url, method: "PUT", body: bodyData))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Delete Todo
    func deleteTodo(id: UUID) async throws {
        let url = URL(string: "\(baseURL)/todos/\(id)")!
        let (_, response) = try await URLSession.shared.data(for: makeRequest(url: url, method: "DELETE"))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}

