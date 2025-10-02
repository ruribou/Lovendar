import Foundation
import Combine

// API通信サービス
class APIService {
    static let shared = APIService()
    
    private let config = APIConfig.shared
    private let authManager = AuthManager.shared
    
    private init() {}
    
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
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 API Response (\(url.lastPathComponent)): \(responseString)")
        }
        if let authHeader = request.value(forHTTPHeaderField: "Authorization") {
            print("🔐 Authorization Header: \(authHeader)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // ステータスコードに応じてエラーハンドリング
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.badRequest(errorResponse.error)
            }
            throw NetworkError.badRequest("リクエストが無効です")
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 409:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.conflict
            }
            throw NetworkError.conflict
        case 500...599:
            throw NetworkError.serverError
        default:
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

