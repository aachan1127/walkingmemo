//
//  HomeView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedDate: Date = Date()
    @State private var isShowingTodos = false
    @State private var todosByDate: [Date: [Todo]] = [:] // 日付ごとのTodoを保持
    @State private var isUserLoaded = false // ユーザー情報のロード状態を管理

    var body: some View {
        NavigationStack {
            if !isUserLoaded {
                ProgressView("ユーザー情報を取得中です...")
                    .onAppear {
                        if authViewModel.currentUser == nil {
                            waitForCurrentUser()
                        } else {
                            isUserLoaded = true
                            loadTodos()
                        }
                    }
            } else {
                VStack {
                    NavigationLink {
                        WalkView()
                    } label: {
                        Text("お散歩モードスタート")
                    }
                    .padding()

                    // カスタムカレンダーを表示
                    CustomCalendarView(selectedDate: $selectedDate, todosByDate: todosByDate)
                        .id(todosByDate.hashValue) // 追加
                        .frame(height: 400)
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
                .onAppear {
                    loadTodos()
                }
                .onChange(of: authViewModel.currentUser) { _ in
                    loadTodos()
                }
            }
        }
        .tint(.primary)
    }

    func waitForCurrentUser() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if authViewModel.currentUser != nil {
                isUserLoaded = true
                loadTodos()
            } else {
                waitForCurrentUser()
            }
        }
    }

    func loadTodos() {
        if let userID = authViewModel.currentUser?.id {
            print("ログインユーザーID: \(userID)")
            let key = "todos_\(userID)"
            if let data = UserDefaults.standard.data(forKey: key) {
                do {
                    let allTodos = try JSONDecoder().decode([Todo].self, from: data)
                    // 削除されていないTodoのみをフィルタリング
                    let validTodos = allTodos.filter { !$0.isDeleted }
                    // 日付ごとにTodoをグループ化
                    let groupedTodos = Dictionary(grouping: validTodos) { todo -> Date in
                        guard let date = todo.date else { return Date.distantPast }
                        return Calendar.current.startOfDay(for: date)
                    }
                    todosByDate = groupedTodos
                    print("todosByDate: \(todosByDate)") // デバッグ用
                } catch {
                    print("データのデコードに失敗しました: \(error.localizedDescription)")
                }
            } else {
                print("データが見つかりません")
            }
        } else {
            print("ユーザーがログインしていません")
        }
    }
}

#Preview {
    HomeView()
}
