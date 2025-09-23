import SwiftUI

struct OshiSelectionView: View {
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @Binding var selectedOshi: Oshi?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // 選択なしオプション
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("選択なし")
                            .font(.headline)
                        Text("推しを指定しない")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedOshi == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedOshi = nil
                    dismiss()
                }
                
                // 推し一覧
                ForEach(oshiViewModel.oshiList) { oshi in
                    HStack {
                        Circle()
                            .fill(oshi.displayColor)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(oshi.name.prefix(1)))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(oshi.name)
                                .font(.headline)
                            
                            if !oshi.group.isEmpty {
                                Text(oshi.group)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if selectedOshi?.id == oshi.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOshi = oshi
                        dismiss()
                    }
                }
            }
            .navigationTitle("推し選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OshiSelectionView(selectedOshi: .constant(nil))
}
