//
//  TodosByDateView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI
import Firebase

struct TodosByDateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var selectedDate: Date
    @State var todos: [Todo] = []
    @State private var isEditing = false
    @State private var selectedTodos = Set<UUID>()
    @State private var showAilogView = false
    @State private var aiFeedback: String = "フィードバックを取得中..."

    var body: some View {
        NavigationStack {
            List(selection: $selectedTodos) {
                ForEach(todos, id: \.id) { todo in
                    Text(todo.value)
                }
                .onDelete(perform: deleteTodo)
            }
            .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
            .navigationTitle("\(formattedDate(selectedDate))のメモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                        if !isEditing {
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
            
            Button("AIによるフィードバックを確認") {
                fetchAIResponseFromFirebase()
                showAilogView = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .sheet(isPresented: $showAilogView) {
                AilogView(aiFeedback: aiFeedback)
                    .presentationDetents([.medium, .large]) // ハーフモーダル
                    .presentationDragIndicator(.visible)
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
        guard let userID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return []
        }

        let key = "todos_\(userID)"
        if let data = UserDefaults.standard.data(forKey: key) {
            var allTodos = try JSONDecoder().decode([Todo].self, from: data)
            allTodos = allTodos.filter { !$0.isDeleted }

            let calendar = Calendar.current
            return allTodos.filter { todo in
                if let todoDate = todo.date {
                    return calendar.isDate(todoDate, inSameDayAs: date)
                } else {
                    return false
                }
            }
        } else {
            return []
        }
    }

    func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            var todo = todos[index]
            todo.isDeleted = true
            if let allTodos = try? getAllTodos() {
                if let idx = allTodos.firstIndex(where: { $0.id == todo.id }) {
                    var updatedTodos = allTodos
                    updatedTodos[idx] = todo
                    saveAllTodos(updatedTodos)
                }
            }
        }
        loadTodos()
    }

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

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    func fetchAIResponseFromFirebase() {
        guard let userID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            self.aiFeedback = "ユーザーがログインしていません。"
            return
        }

        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        db.collection("feedbacks")
            .whereField("userID", isEqualTo: userID)
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThan: endTimestamp)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("フィードバック取得エラー: \(error.localizedDescription)")
                    self.aiFeedback = "フィードバックの取得に失敗しました。"
                    return
                }
                if let document = snapshot?.documents.first {
                    self.aiFeedback = document.data()["aiResponse"] as? String ?? "フィードバックが見つかりませんでした。"
                } else {
                    self.aiFeedback = "フィードバックが見つかりませんでした。"
                }
            }
    }
}

#Preview {
    TodosByDateView(selectedDate: Date())
}
