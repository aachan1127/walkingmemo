//
//  TodosByDateView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct TodosByDateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var selectedDate: Date
    @State var todos: [Todo] = []
    @State private var isEditing = false
    @State private var selectedTodos = Set<UUID>() // 編集モードで選択されたTodoのIDを保持

    var body: some View {
        NavigationStack {
            List(selection: $selectedTodos) {
                ForEach(todos, id: \.id) { todo in
                    Text(todo.value)
                }
                .onDelete(perform: deleteTodo) // スワイプ削除
            }
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .navigationTitle("\(formattedDate(selectedDate))のメモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                        if !isEditing {
                            // 編集モードが終了したら、選択をクリア
                            selectedTodos.removeAll()
                        }
                    }) {
                        Text(isEditing ? "完了" : "編集")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing && !selectedTodos.isEmpty {
                        Button(action: deleteSelectedTodos) {
                            Text("削除")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadTodos()
        }
    }

    func loadTodos() {
        do {
            todos = try getTodos(for: selectedDate)
        } catch {
            print(error.localizedDescription)
        }
    }

    func getTodos(for date: Date) throws -> [Todo] {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            if let data = UserDefaults.standard.data(forKey: key) {
                var allTodos = try JSONDecoder().decode([Todo].self, from: data)
                let calendar = Calendar.current

                // 削除されていないTodoのみをフィルタリング
                allTodos = allTodos.filter { !$0.isDeleted }

                return allTodos.filter { todo in
                    if let todoDate = todo.date {
                        return calendar.isDate(todoDate, inSameDayAs: date)
                    } else {
                        // dateがnilの場合は除外
                        return false
                    }
                }
            } else {
                return []
            }
        } else {
            print("ユーザーがログインしていません")
            return []
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

    // スワイプ削除
    func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            var todo = todos[index]
            todo.isDeleted = true
            if let allTodos = try? getAllTodos() {
                // 該当のTodoを更新
                if let idx = allTodos.firstIndex(where: { $0.id == todo.id }) {
                    var updatedTodos = allTodos
                    updatedTodos[idx] = todo
                    saveAllTodos(updatedTodos)
                }
            }
        }
        loadTodos()
    }

    // 複数選択削除
    func deleteSelectedTodos() {
        if var allTodos = try? getAllTodos() {
            for id in selectedTodos {
                if let idx = allTodos.firstIndex(where: { $0.id == id }) {
                    allTodos[idx].isDeleted = true
                }
            }
            saveAllTodos(allTodos)
            selectedTodos.removeAll()
            isEditing = false
            loadTodos()
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

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

#Preview {
    TodosByDateView(selectedDate: Date())
}
