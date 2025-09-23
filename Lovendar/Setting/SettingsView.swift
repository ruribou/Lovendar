//
//  SettingsView.swift
//  Lovendar
//
//  Created by AI Assistant on 2025/09/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // アプリ情報セクション
                Section("アプリ情報") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
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
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                            .frame(width: 24, height: 24)
                        
                        Toggle("通知を許可", isOn: $viewModel.notificationsEnabled)
                    }
                    .padding(.vertical, 4)
                    
                    if viewModel.notificationsEnabled {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                                .frame(width: 24, height: 24)
                            
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
                
                // 表示設定セクション
                Section("表示設定") {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("週の始まり")
                            Text(viewModel.weekStart.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("週の始まり", selection: $viewModel.weekStart) {
                            ForEach(WeekStart.allCases, id: \.self) { weekStart in
                                Text(weekStart.displayName).tag(weekStart)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "textformat")
                            .foregroundColor(.green)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("時刻表示")
                            Text(viewModel.timeFormat.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("時刻表示", selection: $viewModel.timeFormat) {
                            ForEach(TimeFormat.allCases, id: \.self) { format in
                                Text(format.displayName).tag(format)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.vertical, 4)
                }
                
                // データ管理セクション
                Section("データ管理") {
                    Button(action: {
                        viewModel.showingExportAlert = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text("データをエクスポート")
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        viewModel.showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                            
                            Text("すべてのデータを削除")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // その他セクション
                Section("その他") {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                            
                            Text("プライバシーポリシー")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                            
                            Text("利用規約")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("データをエクスポート", isPresented: $viewModel.showingExportAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("エクスポート") {
                viewModel.exportData()
            }
        } message: {
            Text("カレンダーデータをエクスポートしますか？")
        }
        .alert("データを削除", isPresented: $viewModel.showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                viewModel.deleteAllData()
            }
        } message: {
            Text("すべてのカレンダーデータが削除されます。この操作は取り消せません。")
        }
    }
}

#Preview {
    SettingsView()
}