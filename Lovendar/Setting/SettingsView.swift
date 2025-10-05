import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var apiConfig = APIConfig.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
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
                
            List {
                // ユーザー情報セクション
                if authManager.isAuthenticated {
                    Section("ユーザー情報") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF69B4") ?? .pink,
                                            Color(hex: "#FF1493") ?? .pink
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .font(.title2)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading) {
                                if let user = authManager.currentUser {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("ユーザー情報")
                                        .font(.headline)
                                    Text("読み込み中...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        Button(action: {
                            viewModel.showingLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.red,
                                                Color.red.opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .font(.title2)
                                    .frame(width: 32, height: 32)
                                
                                Text("ログアウト")
                                    .foregroundColor(.red)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Section("APIエンドポイント") {
                    HStack {
                        Text("エンドポイント")
                        Spacer()
                        Text(apiConfig.baseURL)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                // アプリ情報セクション
                Section("アプリ情報") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#87CEEB") ?? .blue,
                                        Color(hex: "#00BFFF") ?? .blue
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.title2)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading) {
                            Text("Lovendar")
                                .font(.headline)
                            Text("バージョン 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // 通知設定セクション
                Section("通知") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FFA07A") ?? .orange,
                                        Color(hex: "#FF6347") ?? .orange
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.title2)
                            .frame(width: 32, height: 32)
                        
                        Toggle("通知を許可", isOn: $viewModel.notificationsEnabled)
                            .disabled(notificationManager.authorizationStatus == .denied)
                    }
                    .padding(.vertical, 4)
                    
                    // 通知許可の状態表示
                    if notificationManager.authorizationStatus == .denied {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("通知が無効になっています")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("設定を開く")
                                }
                                .font(.caption)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if viewModel.notificationsEnabled && notificationManager.authorizationStatus == .authorized {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#DDA0DD") ?? .purple,
                                            Color(hex: "#9370DB") ?? .purple
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .font(.title2)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading) {
                                Text("リマインダー時間")
                                Text("\(viewModel.reminderMinutes)分前")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Stepper("", value: $viewModel.reminderMinutes, in: 1...60, step: 5)
                                .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // テーマ設定セクション
                Section("テーマ") {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .foregroundStyle(
                                themeManager.currentTheme.gradient
                            )
                            .font(.title2)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading) {
                            Text("カラーテーマ")
                            Text(themeManager.currentTheme.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    // テーマ選択グリッド
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            ThemeCardView(
                                theme: theme,
                                isSelected: themeManager.currentTheme == theme
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    themeManager.setTheme(theme)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            }
        }
        .alert("ログアウト", isPresented: $viewModel.showingLogoutAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("ログアウト", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("ログアウトしますか？\nログイン画面に戻ります。")
        }
    }
    private var lastCheckFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
}

// テーマカード表示用のビュー
struct ThemeCardView: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // テーマアイコン
                ZStack {
                    Circle()
                        .fill(theme.gradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: theme.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                // テーマ名
                Text(theme.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // 選択インジケーター
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(theme.gradient)
                        Text("選択中")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text(" ")
                        .font(.caption)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(
                        color: isSelected ? theme.primaryColor.opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? theme.gradient : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: isSelected ? 3 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}