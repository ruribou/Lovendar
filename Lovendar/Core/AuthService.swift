import Foundation
import Combine

// 認証サービス
class AuthService {
    static let shared = AuthService()
    private let apiService = APIService.shared
    
    private init() {}
    
    // ログイン
    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await apiService.request(
            endpoint: "/auth/login",
            method: .post,
            body: request,
            requiresAuth: false
        )
        return response
    }
    
    // 新規登録
    func register(name: String, email: String, password: String) async throws -> RegisterResponse {
        let request = RegisterRequest(name: name, email: email, password: password)
        let response: RegisterResponse = try await apiService.request(
            endpoint: "/auth/register",
            method: .post,
            body: request,
            requiresAuth: false
        )
        return response
    }
}

// ログインリクエスト
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

// ログインレスポンス
struct LoginResponse: Decodable {
    let token: String
}

// 登録リクエスト
struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

// 登録レスポンス
struct RegisterResponse: Decodable {
    let name: String
    let email: String
    let token: String
}

