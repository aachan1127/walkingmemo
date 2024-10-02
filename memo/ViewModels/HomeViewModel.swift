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
    
    // Download Users Data
    private func fetchUsers() async -> [User] {
        var users: [User] = []
        do {
            let snapshot = try await Firestore.firestore().collection("users").getDocuments()
            
            for document in snapshot.documents {
                let data = document.data()
                let id = document.documentID
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let user = User(id: id, name: name, email: email)
                users.append(user)
            }
        } catch {
            print("ユーザーデータ取得失敗: \(error.localizedDescription)")
        }
        return users
    }
}
