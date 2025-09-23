//
//  AddView.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import SwiftUI

struct AddView: View {
    @StateObject private var viewModel = AddViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section("基本情報") {
                    TextField("タイトル", text: $viewModel.title)
                    
                    TextField("説明（任意）", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // 日時セクション
                Section("日時") {
                    DatePicker("日付", selection: $viewModel.selectedDate, displayedComponents: .date)
                    
                    Toggle("終日", isOn: $viewModel.isAllDay)
                    
                    if !viewModel.isAllDay {
                        DatePicker("開始時刻", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                        
                        DatePicker("終了時刻", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                            .foregroundColor(viewModel.isEndTimeValid ? .primary : .red)
                    }
                }
                
                // リマインダーセクション
                Section("リマインダー") {
                    Toggle("リマインダーを設定", isOn: $viewModel.hasReminder)
                    
                    if viewModel.hasReminder {
                        Picker("通知タイミング", selection: $viewModel.reminderOption) {
                            ForEach(ReminderOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // カテゴリセクション
                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $viewModel.selectedCategory) {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // 保存ボタン
                Section {
                    Button(action: {
                        viewModel.saveEvent()
                        Router.shared.navigate(to: .calendar)
                    }) {
                        HStack {
                            Spacer()
                            Text("予定を保存")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                    
                    Button("フォームをクリア") {
                        viewModel.clearForm()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("新しい予定")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("エラー", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    AddView()
}