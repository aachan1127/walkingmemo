//
//  HomeViewModel.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import Foundation
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    
    @Published var users = [User]() // ユーザー情報を保持する配列
    
    @MainActor
    init() {
        Task {
            self.users = await fetchUsers() // fetchUsersの結果をusersに代入
        }
    }
}

// Download Users Data
private func fetchUsers() async -> [User] { // 非同期でユーザーデータを取得し、[User]を返す
    var users: [User] = []
    do {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        
        for document in snapshot.documents {
            if let user = try? document.data(as: User.self) {
                users.append(user) // データを配列に追加
            }
        }
    } catch {
        print("ユーザーデータ取得失敗: \(error.localizedDescription)")
    }
    return users // 取得したユーザーデータを返す
}
