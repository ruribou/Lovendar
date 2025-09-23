import SwiftUI

struct OshiListView: View {
    @StateObject private var viewModel = OshiViewModel.shared
    @State private var showingAddView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.oshiList) { oshi in
                    OshiRowView(oshi: oshi)
                        .onTapGesture {
                            viewModel.selectedOshi = oshi
                        }
                }
                .onDelete(perform: deleteOshi)
            }
            .navigationTitle("推し一覧")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddOshiView()
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
    let oshi: Oshi
    
    var body: some View {
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
                
                if !oshi.description.isEmpty {
                    Text(oshi.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OshiListView()
}
