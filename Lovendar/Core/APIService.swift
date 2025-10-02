import Foundation
import Combine

// API通信サービス
class APIService {
    static let shared = APIService()
    
    private let config = APIConfig.shared
    private let authManager = AuthManager.shared
    
    private init() {}
    
    // MARK: - ユーザー情報関連
    
    // ユーザー情報取得
    func getUserInfo() async throws -> UserInfoResponse {
        return try await request<UserInfoResponse>(
            endpoint: "/me",
            method: .get,
            requiresAuth: true
        )
    }
    
    // 汎用リクエストメソッド
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: "\(config.baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 認証が必要な場合はトークンを追加
        if requiresAuth {
            let token = await MainActor.run {
                authManager.getAuthToken()
            }
            guard let token = token else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // リクエストボディを設定
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // デバッグ用ログ
        print("🌐 API Request: \(method.rawValue) \(url.absoluteString)")
        if let authHeader = request.value(forHTTPHeaderField: "Authorization") {
            print("🔐 Authorization Header: \(authHeader)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
        }
        
        print("📦 Response Data Size: \(data.count) bytes")
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 Raw API Response (\(url.lastPathComponent)):")
            print("--- JSON START ---")
            print(responseString)
            print("--- JSON END ---")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // ステータスコードに応じてエラーハンドリング
        switch httpResponse.statusCode {
        case 200...299:
            do {
                print("✅ HTTP Success - デコード開始")
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                print("✅ デコード成功")
                return decodedData
            } catch {
                print("❌ Decoding Error Details:")
                print("   Error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: \(type)")
                        print("   Context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type)")
                        print("   Context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("   Key not found: \(key)")
                        print("   Context: \(context)")
                    case .dataCorrupted(let context):
                        print("   Data corrupted")
                        print("   Context: \(context)")
                    @unknown default:
                        print("   Unknown decoding error")
                    }
                }
                print("   Expected Type: \(T.self)")
                throw NetworkError.decodingError
            }
        case 400:
            print("❌ HTTP 400 Bad Request")
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print("   Error Message: \(errorResponse.error)")
                throw NetworkError.badRequest(errorResponse.error)
            }
            throw NetworkError.badRequest("リクエストが無効です")
        case 401:
            print("❌ HTTP 401 Unauthorized")
            throw NetworkError.unauthorized
        case 403:
            print("❌ HTTP 403 Forbidden")
            throw NetworkError.forbidden
        case 404:
            print("❌ HTTP 404 Not Found")
            throw NetworkError.notFound
        case 409:
            print("❌ HTTP 409 Conflict")
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print("   Error Message: \(errorResponse.error)")
                throw NetworkError.conflict
            }
            throw NetworkError.conflict
        case 500...599:
            print("❌ HTTP \(httpResponse.statusCode) Server Error")
            throw NetworkError.serverError
        default:
            print("❌ HTTP \(httpResponse.statusCode) Unknown Error")
            throw NetworkError.unknown
        }
    }
}

// HTTPメソッド
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// エラーレスポンス
struct ErrorResponse: Codable {
    let error: String
}

