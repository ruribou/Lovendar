import SwiftUI

struct OshiListView: View {
    @StateObject private var viewModel = OshiViewModel.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAddView = false
    @State private var selectedOshiForEdit: Oshi?
    
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
                ForEach(viewModel.oshiList) { oshi in
                    OshiRowView(oshi: oshi)
                        .onTapGesture {
                            selectedOshiForEdit = oshi
                        }
                }
                .onDelete(perform: deleteOshi)
            }
            .scrollContentBackground(.hidden)
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("推し一覧")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showingAddView = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeManager.currentTheme.gradient)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddOshiView()
            }
            .sheet(item: $selectedOshiForEdit) { oshi in
                EditOshiView(oshi: oshi)
            }
            }
        }
    }
    
    private func deleteOshi(at offsets: IndexSet) {
        for index in offsets {
            let oshi = viewModel.oshiList[index]
            viewModel.deleteOshi(oshi)
        }
    }
}

struct OshiRowView: View {
    @StateObject private var themeManager = ThemeManager.shared
    let oshi: Oshi
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                oshi.displayColor,
                                oshi.displayColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: oshi.displayColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text(String(oshi.name.prefix(1)))
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(oshi.name)
                    .font(.headline)
                
                if !oshi.group.isEmpty {
                    Text(oshi.group)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !oshi.description.isEmpty {
                    Text(oshi.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .foregroundStyle(themeManager.currentTheme.gradient)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    OshiListView()
}
