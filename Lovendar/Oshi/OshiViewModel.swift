import Foundation
import SwiftUI
import Combine

@MainActor
class OshiViewModel: ObservableObject {
    @Published var oshiList: [Oshi] = []
    @Published var selectedOshi: Oshi?
    
    static let shared = OshiViewModel()
    
    init() {
        loadOshi()
    }
    
    func loadOshi() {
        oshiList = Oshi.sampleOshi
    }
    
    func addOshi(_ oshi: Oshi) {
        oshiList.append(oshi)
        saveOshi()
    }
    
    func deleteOshi(_ oshi: Oshi) {
        oshiList.removeAll { $0.id == oshi.id }
        saveOshi()
    }
    
    func updateOshi(_ oshi: Oshi) {
        if let index = oshiList.firstIndex(where: { $0.id == oshi.id }) {
            oshiList[index] = oshi
            saveOshi()
        }
    }
    
    private func saveOshi() {
        // TODO: データ保存処理
        print("推しデータを保存")
    }
}
