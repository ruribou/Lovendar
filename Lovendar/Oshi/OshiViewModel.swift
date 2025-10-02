import Foundation
import SwiftUI
import Combine

@MainActor
class OshiViewModel: ObservableObject {
    @Published var oshiList: [Oshi] = []
    @Published var selectedOshi: Oshi?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let oshiService = OshiService.shared
    private let authManager = AuthManager.shared
    
    static let shared = OshiViewModel()
    
    init() {
        Task {
            await loadOshi()
        }
    }
    
    // 推しデータを読み込み（APIから取得）
    func loadOshi() async {
        guard authManager.isAuthenticated else {
            // 認証されていない場合は空リストを表示
            oshiList = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let apiOshis = try await oshiService.fetchOshiList()
            oshiList = apiOshis.map { apiOshi in
                Oshi(
                    id: apiOshi.id,
                    name: apiOshi.name,
                    color: apiOshi.color,
                    urls: apiOshi.urls ?? [],
                    categories: apiOshi.categories ?? []
                )
            }
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            // エラー時は空リストを表示
            oshiList = []
        } catch {
            errorMessage = "エラーが発生しました"
            oshiList = []
        }
        
        isLoading = false
    }
    
    // 推しを追加
    func addOshi(name: String, color: String, urls: [String]?, categories: [String]?) async throws {
        isLoading = true
        errorMessage = nil
        
        if authManager.isAuthenticated {
            // 認証済み: APIに送信
            do {
                let apiOshi = try await oshiService.createOshi(
                    name: name,
                    color: color,
                    urls: urls,
                    categories: categories
                )
                let newOshi = Oshi(
                    id: apiOshi.id,
                    name: apiOshi.name,
                    color: apiOshi.color,
                    urls: apiOshi.urls ?? [],
                    categories: apiOshi.categories ?? []
                )
                oshiList.append(newOshi)
            } catch {
                isLoading = false
                throw error
            }
        } else {
            // 未認証: ローカルに追加
            let newOshi = Oshi(
                name: name,
                color: color,
                urls: urls ?? [],
                categories: categories ?? []
            )
            oshiList.append(newOshi)
        }
        
        isLoading = false
    }
    
    // 推しを更新
    func updateOshi(id: Int, name: String, color: String, urls: [String]?, categories: [String]?) async throws {
        guard authManager.isAuthenticated else {
            throw NetworkError.unauthorized
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let apiOshi = try await oshiService.updateOshi(
                id: id,
                name: name,
                color: color,
                urls: urls,
                categories: categories
            )
            if let index = oshiList.firstIndex(where: { $0.serverId == id }) {
                oshiList[index] = Oshi(
                    id: apiOshi.id,
                    name: apiOshi.name,
                    color: apiOshi.color,
                    urls: apiOshi.urls ?? [],
                    categories: apiOshi.categories ?? []
                )
            }
        } catch {
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    // 推しを削除
    func deleteOshi(_ oshi: Oshi) {
        oshiList.removeAll { $0.id == oshi.id }
    }
    
    // データをリフレッシュ
    func refresh() async {
        await loadOshi()
    }
}
