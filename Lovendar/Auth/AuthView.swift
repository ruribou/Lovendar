import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // ロゴ・タイトル
                    VStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.pink)
                        
                        Text("Lovendar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isLoginMode ? "ログイン" : "新規登録")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // フォーム
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            TextField("名前", text: $viewModel.name)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .textContentType(.name)
                        }
                        
                        TextField("メールアドレス", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                        
                        SecureField("パスワード", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(isLoginMode ? .password : .newPassword)
                        
                        if !isLoginMode && !viewModel.password.isEmpty {
                            HStack {
                                Image(systemName: viewModel.isPasswordValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(viewModel.isPasswordValid ? .green : .red)
                                Text(viewModel.isPasswordValid ? "パスワードは有効です" : "8文字以上必要です")
                                    .font(.caption)
                                    .foregroundColor(viewModel.isPasswordValid ? .green : .red)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // エラーメッセージ
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // ボタン
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await viewModel.authenticate(isLoginMode: isLoginMode)
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isLoginMode ? "ログイン" : "登録")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isLoginMode ? Color.blue : Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading || (!isLoginMode && !viewModel.isPasswordValid))
                        
                        Button {
                            withAnimation {
                                isLoginMode.toggle()
                                viewModel.clearError()
                            }
                        } label: {
                            Text(isLoginMode ? "アカウントをお持ちでない方はこちら" : "既にアカウントをお持ちの方はこちら")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthView()
}

