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
    
    var body: some View {
        NavigationStack {
            List(todos, id: \.id) { todo in
                Text(todo.value)
            }
            .navigationTitle("\(formattedDate(selectedDate))のメモ")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            do {
                todos = try getTodos(for: selectedDate)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getTodos(for date: Date) throws -> [Todo] {
        if let userID = authViewModel.currentUser?.id {
            let key = "todos_\(userID)"
            if let data = UserDefaults.standard.data(forKey: key) {
                let allTodos = try JSONDecoder().decode([Todo].self, from: data)
                let calendar = Calendar.current
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
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

#Preview {
    TodosByDateView(selectedDate: Date())
}
