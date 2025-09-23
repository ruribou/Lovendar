import SwiftUI

struct AddOshiView: View {
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var group = ""
    @State private var selectedColor = "#FF69B4"
    @State private var customColorCode = "#FF69B4"
    @State private var isCustomColor = false
    @State private var showColorCodeError = false
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
                basicInfoSection
                colorSection
                dateSection
                actionSection
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
    
    private func validateAndUpdateColor() {
        // カスタムカラーコードの検証
        if customColorCode.hasPrefix("#") {
            let hexString = String(customColorCode.dropFirst())
            // 6桁のHEXカラーコードかどうかを確認
            let isValid = hexString.count == 6
            showColorCodeError = !isValid
            
            if isValid {
                selectedColor = customColorCode
            }
        } else {
            showColorCodeError = true
        }
    }
    
    private func saveOshi() {
        // カスタムカラーの場合、最終検証
        if isCustomColor {
            validateAndUpdateColor()
            if showColorCodeError {
                return // 無効なカラーコードの場合は保存しない
            }
        }
        
        // 使用するカラーコード
        let finalColor = isCustomColor ? customColorCode : selectedColor
        
        let newOshi = Oshi(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            group: group.trimmingCharacters(in: .whitespacesAndNewlines),
            color: finalColor,
            birthday: hasBirthday ? birthday : nil,
            debutDate: hasDebutDate ? debutDate : nil,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        oshiViewModel.addOshi(newOshi)
        dismiss()
    }
    
    private var basicInfoSection: some View {
        Section("基本情報") {
            TextField("推しの名前", text: $name)
            TextField("グループ・所属（任意）", text: $group)
            TextField("説明・メモ（任意）", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    private var colorSection: some View {
        Section("カラー設定") {
            presetColorToggle
            presetColorGrid
            customColorToggle
            customColorInputs
        }
    }
    
    private var presetColorToggle: some View {
        HStack {
            Text("プリセットカラー")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { !isCustomColor },
                set: { newValue in
                    isCustomColor = !newValue
                    if !isCustomColor {
                        customColorCode = selectedColor
                    }
                }
            ))
            .labelsHidden()
        }
    }
    
    private var presetColorGrid: some View {
        Group {
            if !isCustomColor {
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
        }
    }
    
    private var customColorToggle: some View {
        HStack {
            Text("カスタムカラー")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Toggle("", isOn: $isCustomColor)
                .labelsHidden()
        }
    }
    
    private var customColorInputs: some View {
        Group {
            if isCustomColor {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("#")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        TextField("カラーコード (例: FF69B4)", text: $customColorCode)
                            .onChange(of: customColorCode) { newValue in
                                if !newValue.hasPrefix("#") {
                                    customColorCode = "#" + newValue
                                }
                                let cleanValue = newValue.filter { "0123456789ABCDEFabcdef#".contains($0) }
                                if cleanValue != newValue {
                                    customColorCode = cleanValue
                                }
                                validateAndUpdateColor()
                            }
                            .font(.body)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Circle()
                            .fill(Color(hex: customColorCode) ?? Color.gray)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    if showColorCodeError {
                        Text("有効な6桁のHEXカラーコードを入力してください")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var dateSection: some View {
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
    }
    
    private var actionSection: some View {
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
}

#Preview {
    AddOshiView()
}
