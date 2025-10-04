import SwiftUI

struct OnboardingView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var currentPage = 0
    @State private var notificationEnabled = false
    @Binding var isCompleted: Bool
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: themeManager.currentTheme.backgroundGradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ページインジケーター
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? themeManager.currentTheme.primaryColor : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // ページコンテンツ
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)
                    
                    notificationPage
                        .tag(1)
                    
                    readyPage
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // ボタン
                VStack(spacing: 16) {
                    if currentPage < 2 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text(currentPage == 0 ? "次へ" : "続ける")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.currentTheme.gradient)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                        
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Text("戻る")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    } else {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("始める")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.currentTheme.gradient)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // ウェルカムページ
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF69B4")?.opacity(0.3) ?? .pink.opacity(0.3),
                                Color(hex: "#FF1493")?.opacity(0.3) ?? .pink.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
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
            }
            
            VStack(spacing: 16) {
                Text("Lovendarへようこそ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("推しのスケジュールを\n一つにまとめて管理")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // 通知設定ページ
    private var notificationPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FFA07A")?.opacity(0.3) ?? .orange.opacity(0.3),
                                Color(hex: "#FF6347")?.opacity(0.3) ?? .orange.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
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
            }
            
            VStack(spacing: 16) {
                Text("通知を設定")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("イベントの開始前に\n通知でお知らせします")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#90EE90") ?? .green)
                        Text("15分前通知")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#90EE90") ?? .green)
                        Text("大切なイベントを見逃さない")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#90EE90") ?? .green)
                        Text("後から設定で変更可能")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }
            
            // 通知許可トグル
            VStack(spacing: 16) {
                HStack {
                    Toggle("通知を許可する", isOn: $notificationEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: themeManager.currentTheme.primaryColor))
                        .foregroundColor(.white)
                        .font(.headline)
                        .onChange(of: notificationEnabled) { oldValue, newValue in
                            if newValue {
                                Task {
                                    let granted = await notificationManager.requestAuthorization()
                                    if !granted {
                                        notificationEnabled = false
                                    }
                                }
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                )
                .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // 準備完了ページ
    private var readyPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#87CEEB")?.opacity(0.3) ?? .blue.opacity(0.3),
                                Color(hex: "#00BFFF")?.opacity(0.3) ?? .blue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
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
            }
            
            VStack(spacing: 16) {
                Text("準備完了！")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("推しのイベントを登録して\n素敵な思い出を作りましょう")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private func completeOnboarding() {
        // 通知の設定を保存
        UserDefaults.standard.set(notificationEnabled, forKey: "notificationsEnabled")
        // オンボーディング完了フラグを保存
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        withAnimation {
            isCompleted = true
        }
    }
}

#Preview {
    OnboardingView(isCompleted: .constant(false))
}

