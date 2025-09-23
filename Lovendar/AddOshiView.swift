import SwiftUI

struct AddOshiView: View {
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var group = ""
    @State private var selectedColor = "#FF69B4"
    @State private var description = ""
    @State private var birthday: Date = Date()
    @State private var hasBirthday = false
    @State private var debutDate: Date = Date()
    @State private var hasDebutDate = false
    
    private let predefinedColors = [
        "#FF69B4", "#87CEEB", "#98FB98", "#FFB6C1",
        "#DDA0DD", "#F0E68C", "#FFA07A", "#20B2AA",
        "#FF6347", "#9370DB", "#32CD32", "#FF1493"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("推しの名前", text: $name)
                    
                    TextField("グループ・所属（任意）", text: $group)
                    
                    TextField("説明・メモ（任意）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("カラー設定") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(predefinedColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("日付情報") {
                    Toggle("誕生日を設定", isOn: $hasBirthday)
                    
                    if hasBirthday {
                        DatePicker("誕生日", selection: $birthday, displayedComponents: .date)
                    }
                    
                    Toggle("デビュー日を設定", isOn: $hasDebutDate)
                    
                    if hasDebutDate {
                        DatePicker("デビュー日", selection: $debutDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button(action: saveOshi) {
                        HStack {
                            Spacer()
                            Text("推しを追加")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("新しい推し")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveOshi() {
        let newOshi = Oshi(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            group: group.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor,
            birthday: hasBirthday ? birthday : nil,
            debutDate: hasDebutDate ? debutDate : nil,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        oshiViewModel.addOshi(newOshi)
        dismiss()
    }
}

#Preview {
    AddOshiView()
}
