import Foundation
import SwiftUI
import Combine

// 認証管理
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    private var authToken: String?
    
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    private init() {
        loadAuthState()
    }
    
    // トークンを取得
    func getAuthToken() -> String? {
        return authToken
    }
    
    // ログイン処理
    func login(token: String, user: User) {
        self.authToken = token
        self.currentUser = user
        self.isAuthenticated = true
        
        // トークンを保存
        UserDefaults.standard.set(token, forKey: tokenKey)
        
        // ユーザー情報を保存
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    // ログアウト処理
    func logout() {
        self.authToken = nil
        self.currentUser = nil
        self.isAuthenticated = false
        
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    // 認証状態を読み込み
    private func loadAuthState() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.authToken = token
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
}

// ユーザーモデル
struct User: Codable, Identifiable {
    let id: Int?
    let name: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }
}

