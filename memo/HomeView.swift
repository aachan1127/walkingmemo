//
//  HomeView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedDate: Date = Date()
    @State private var isShowingTodos = false
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    WalkView()
                } label: {
                    Text("お散歩モードスタート")
                }
                .padding()
                
                // カレンダーを表示
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Button("選択した日のメモを見る") {
                    isShowingTodos = true
                }
                .padding()
                .sheet(isPresented: $isShowingTodos) {
                    TodosByDateView(selectedDate: selectedDate)
                        .environmentObject(authViewModel)
                }
                
                // 「削除済みのメモを見る」ボタンを追加
                NavigationLink(destination: DeleteView().environmentObject(authViewModel)) {
                    Text("削除済みのメモを見る")
                }
                .padding()
            }
            .navigationTitle("Home画面")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandImage(size: .small)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MyPageView()
                    } label: {
                        Image("avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .tint(.primary)
    }
}

#Preview {
    HomeView()
}
