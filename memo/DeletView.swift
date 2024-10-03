//
//  DeleteView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct DeleteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var deletedTodos: [Todo] = []

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(deletedTodos, id: \.id) { todo in
                        Text(todo.value)
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    restoreTodo(todo)
                                }) {
                                    Label("復元", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.green)
                            }
                    }
                }

                Button(action: completelyDeleteTodos) {
                    Text("完全に削除する")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("削除済みのメモ")
        }
        .onAppear {
            loadDeletedTodos()
        }
    }

    func loadDeletedTodos() {
        if let allTodos = try? getAllTodos() {
            deletedTodos = allTodos.filter { $0.isDeleted }
        }
    }

    func restoreTodo(_ todo: Todo) {
        if var allTodos = try? getAllTodos() {
            if let idx = allTodos.firstIndex(where: { $0.id == todo.id }) {
                allTodos[idx].isDeleted = false
                saveAllTodos(allTodos)
                loadDeletedTodos() // リストを更新
            }
        }
    }

    func completelyDeleteTodos() {
        if var allTodos = try? getAllTodos() {
            // 削除済みのTodoを除外
            allTodos.removeAll { $0.isDeleted }
            saveAllTodos(allTodos)
            deletedTodos = []
        }
    }

    func getAllTodos() throws -> [Todo] {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            if let data = UserDefaults.standard.data(forKey: key) {
                return try JSONDecoder().decode([Todo].self, from: data)
            } else {
                return []
            }
        } else {
            print("ユーザーがログインしていません")
            throw NSError(domain: "UserNotLoggedIn", code: 1, userInfo: nil)
        }
    }

    func saveAllTodos(_ todosToSave: [Todo]) {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            do {
                let encodedTodos = try JSONEncoder().encode(todosToSave)
                UserDefaults.standard.set(encodedTodos, forKey: key)
            } catch {
                print("データのエンコードに失敗しました: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    DeleteView()
}
