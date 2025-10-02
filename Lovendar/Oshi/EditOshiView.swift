import SwiftUI

struct EditOshiView: View {
    @StateObject private var oshiViewModel = OshiViewModel.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let oshi: Oshi
    
    @State private var name: String
    @State private var group: String
    @State private var selectedColor: String
    @State private var customColorCode: String
    @State private var isCustomColor = false
    @State private var showColorCodeError = false
    @State private var description: String
    @State private var urls: [String]
    @State private var selectedCategories: Set<String>
    @State private var availableCategories: [Category] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let predefinedColors = [
        "#FF69B4", "#87CEEB", "#98FB98", "#FFB6C1",
        "#DDA0DD", "#F0E68C", "#FFA07A", "#20B2AA",
        "#FF6347", "#9370DB", "#32CD32", "#FF1493"
    ]
    
    init(oshi: Oshi) {
        self.oshi = oshi
        self._name = State(initialValue: oshi.name)
        self._group = State(initialValue: oshi.group)
        self._selectedColor = State(initialValue: oshi.color)
        self._customColorCode = State(initialValue: oshi.color)
        self._description = State(initialValue: oshi.description)
        self._urls = State(initialValue: oshi.urls.isEmpty ? [""] : oshi.urls)
        self._selectedCategories = State(initialValue: Set(oshi.categories))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // ポップな背景（テーマに応じて変化）
                LinearGradient(
                    gradient: Gradient(colors: themeManager.currentTheme.backgroundGradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    basicInfoSection
                    urlSection
                    categorySection
                    colorSection
                    actionSection
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("推しを編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") {
                            dismiss()
                        }
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .onAppear {
                    loadCategories()
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
        guard let oshiId = oshi.serverId else {
            errorMessage = "推しIDが見つかりません"
            return
        }
        
        // カスタムカラーの場合、最終検証
        if isCustomColor {
            validateAndUpdateColor()
            if showColorCodeError {
                return // 無効なカラーコードの場合は保存しない
            }
        }
        
        // 使用するカラーコード
        let finalColor = isCustomColor ? customColorCode : selectedColor
        
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                let validUrls = urls.compactMap { url in
                    url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : url.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                try await oshiViewModel.updateOshi(
                    id: oshiId,
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    color: finalColor,
                    urls: validUrls.isEmpty ? nil : validUrls,
                    categories: selectedCategories.isEmpty ? nil : Array(selectedCategories)
                )
                dismiss()
            } catch {
                errorMessage = "推しの更新に失敗しました: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func loadCategories() {
        Task {
            do {
                let commonService = CommonService.shared
                availableCategories = try await commonService.fetchCommonInfo()
            } catch {
                print("カテゴリーの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section("基本情報") {
            TextField("推しの名前", text: $name)
            TextField("グループ・所属（任意）", text: $group)
            TextField("説明・メモ（任意）", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    private var urlSection: some View {
        Section("関連URL（任意）") {
            ForEach(urls.indices, id: \.self) { index in
                HStack {
                    TextField("https://example.com", text: $urls[index])
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    if urls.count > 1 {
                        Button(action: {
                            urls.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Button(action: {
                urls.append("")
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("URLを追加")
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private var categorySection: some View {
        Section("カテゴリー（任意）") {
            if availableCategories.isEmpty {
                Text("カテゴリーを読み込み中...")
                    .foregroundColor(.secondary)
            } else {
                ForEach(availableCategories) { category in
                    HStack {
                        Button(action: {
                            if selectedCategories.contains(category.slug) {
                                selectedCategories.remove(category.slug)
                            } else {
                                selectedCategories.insert(category.slug)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedCategories.contains(category.slug) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedCategories.contains(category.slug) ? .blue : .gray)
                                
                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .foregroundColor(.primary)
                                    if let description = category.description {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
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
                        ColorCircleView(
                            colorHex: color,
                            isSelected: selectedColor == color
                        ) {
                            withAnimation {
                                selectedColor = color
                            }
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
                            .autocorrectionDisabled(true)
                        Circle()
                            .fill(Color.init(hex: customColorCode) ?? Color.gray)
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
    
    private var actionSection: some View {
        Section {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: saveOshi) {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("更新")
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .foregroundStyle(themeManager.currentTheme.gradient)
                .padding(.vertical, 4)
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
    }
}

#Preview {
    EditOshiView(oshi: Oshi(name: "テスト推し", color: "#FF69B4"))
}
