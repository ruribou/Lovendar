import Foundation
import Combine

// 共通情報API サービス
class CommonService {
    static let shared = CommonService()
    private let apiService = APIService.shared
    
    private init() {}
    
    // 共通情報取得（カテゴリ一覧）
    func fetchCommonInfo() async throws -> [Category] {
        let response: CommonResponse = try await apiService.request(
            endpoint: "/common",
            method: .get,
            requiresAuth: false
        )
        return response.categories
    }
}

