import Foundation
import Combine

// API環境設定
enum APIEnvironment: String, CaseIterable {
    case local = "local"
    case production = "production"
    
    var baseURL: String {
        switch self {
        case .local:
            return "http://localhost:8080/api"
        case .production:
            return "https://lovender-backend-969255446449.us-central1.run.app/api"
        }
    }
    
    var displayName: String {
        switch self {
        case .local:
            return "ローカル環境"
        case .production:
            return "本番環境"
        }
    }
    
    var description: String {
        switch self {
        case .local:
            return "開発・テスト用のローカルサーバー"
        case .production:
            return "本番運用中のクラウドサーバー"
        }
    }
    
    var statusColor: String {
        switch self {
        case .local:
            return "#FFA500" // オレンジ
        case .production:
            return "#32CD32" // グリーン
        }
    }
}

// API設定管理
class APIConfig: ObservableObject {
    static let shared = APIConfig()
    
    @Published var currentEnvironment: APIEnvironment = .local
    @Published var isConnected: Bool = false
    @Published var lastConnectionCheck: Date?
    
    private let environmentKey = "api_environment"
    private let userDefaults = UserDefaults.standard
    
    var baseURL: String {
        currentEnvironment.baseURL
    }
    
    private init() {
        loadSavedEnvironment()
    }
    
    // 環境を切り替え
    func switchEnvironment(to environment: APIEnvironment) {
        currentEnvironment = environment
        saveEnvironment()
        
        // 環境切り替え時に接続テストを実行
        Task {
            await testConnection()
        }
    }
    
    // 設定を保存
    private func saveEnvironment() {
        userDefaults.set(currentEnvironment.rawValue, forKey: environmentKey)
    }
    
    // 保存された設定を読み込み
    private func loadSavedEnvironment() {
        if let savedEnvironment = userDefaults.string(forKey: environmentKey),
           let environment = APIEnvironment(rawValue: savedEnvironment) {
            currentEnvironment = environment
        }
    }
    
    // 接続テスト
    @MainActor
    func testConnection() async {
        do {
            let url = URL(string: "\(baseURL)/common")!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                isConnected = (200...299).contains(httpResponse.statusCode)
            } else {
                isConnected = false
            }
        } catch {
            isConnected = false
        }
        
        lastConnectionCheck = Date()
    }
}

