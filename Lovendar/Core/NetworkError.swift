import Foundation

// ネットワークエラー
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case badRequest(String)
    case serverError
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .unauthorized:
            return "認証が必要です"
        case .forbidden:
            return "アクセス権限がありません"
        case .notFound:
            return "データが見つかりません"
        case .conflict:
            return "データが重複しています"
        case .badRequest(let message):
            return message
        case .serverError:
            return "サーバーエラーが発生しました"
        case .decodingError:
            return "データの解析に失敗しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}
