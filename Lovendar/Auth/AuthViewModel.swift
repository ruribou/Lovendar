import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private let authManager = AuthManager.shared
    
    var isPasswordValid: Bool {
        password.count >= 8
    }
    
    // 認証処理
    func authenticate(isLoginMode: Bool) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isLoginMode {
                // ログイン
                let response = try await authService.login(email: email, password: password)
                let user = User(id: nil, name: "", email: email)
                await authManager.login(token: response.token, user: user)
            } else {
                // 新規登録
                guard isPasswordValid else {
                    errorMessage = "パスワードは8文字以上必要です"
                    isLoading = false
                    return
                }
                
                let response = try await authService.register(name: name, email: email, password: password)
                let user = User(id: nil, name: response.name, email: response.email)
                await authManager.login(token: response.token, user: user)
            }
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "エラーが発生しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

