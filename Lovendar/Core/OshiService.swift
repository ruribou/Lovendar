import Foundation
import Combine

// 推しAPI サービス
class OshiService {
    static let shared = OshiService()
    private let apiService = APIService.shared
    
    private init() {}
    
    // 推し一覧取得
    func fetchOshiList() async throws -> [OshiAPI] {
        let response: OshiListResponse = try await apiService.request(
            endpoint: "/me/oshis",
            method: .get,
            requiresAuth: true
        )
        return response.oshis
    }
    
    // 推し新規作成
    func createOshi(name: String, color: String, urls: [String]?, categories: [String]?) async throws -> OshiAPI {
        let request = CreateOshiRequest(name: name, color: color, urls: urls, categories: categories)
        let response: OshiResponse = try await apiService.request(
            endpoint: "/me/oshis/new",
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.oshi
    }
    
    // 推し更新
    func updateOshi(id: Int, name: String, color: String, urls: [String]?, categories: [String]?) async throws -> OshiAPI {
        let request = UpdateOshiRequest(name: name, color: color, urls: urls, categories: categories)
        let response: OshiResponse = try await apiService.request(
            endpoint: "/me/oshis/\(id)",
            method: .put,
            body: request,
            requiresAuth: true
        )
        return response.oshi
    }
}

