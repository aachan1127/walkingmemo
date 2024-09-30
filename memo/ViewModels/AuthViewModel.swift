//
//  AuthViewModel.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        print("ログインユーザー:\(self.userSession?.email)")
        
        Task {
            await self.fetchCurrentUser()
        }
    }
    
    // Login
    @MainActor
    func login(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("ログイン成功: \(result.user.email)")
            self.userSession = result.user
            print("self.userSeesion: \(self.userSession?.email)")
            
            await self.fetchCurrentUser()
        } catch {
            print("ログイン失敗: \(error.localizedDescription)")
        }
    }
    
    // Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            print("ログアウト成功")
            self.resetAccount()
        } catch {
            print("ログアウト失敗: \(error.localizedDescription)")
        }
    }
    
    // Create Account
    @MainActor
    func createAccount(email: String, password: String, name: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("ユーザー登録成功: \(result.user.email)")
            self.userSession = result.user
            
            let newUser = User(id: result.user.uid, name: name, email: email)
            await uploadUserData(withUser: newUser)
            
            await self.fetchCurrentUser()
        } catch {
            print("ユーザー登録失敗: \(error.localizedDescription)")
        }
        
        print("アカウント登録画面からcreateAccountメソッドが呼び出されました")
    }
    
    // Delete Account
    @MainActor
    func deleteAccount() async {
        guard let id = self.currentUser?.id else { return }
        
        do {
            try await Auth.auth().currentUser?.delete()
            //Firestoreのユーザーコレクションに存在するドキュメントを特定して削除
            try await Firestore.firestore().collection("users").document(id).delete()
            print("アカウント削除成功")
            self.resetAccount()
        } catch {
            print("アカウント削除失敗: \(error.localizedDescription)")
        }
    }
    
    // Reset Account
    private func resetAccount() {
        
        self.userSession = nil
        self.currentUser = nil
    }
    
    // Upload User Data
    private func uploadUserData(withUser user: User) async {
        do {
            let userData = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(userData)
            print("データ保存成功")
        } catch {
            print("データ保存失敗: \(error.localizedDescription)")
        }
    }
    
    // Fetch current user
    @MainActor
    private func fetchCurrentUser() async {
        
        guard let uid = self.userSession?.uid else { return }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
            print("カレントユーザー所得成功: \(self.currentUser)")
        } catch {
            print("カレントユーザー取得失敗: \(error.localizedDescription)")
        }
    }
    
    // Update user profile
    func updateUserProfile(withId id: String, name: String) async {
        let data: [AnyHashable: Any] = [
            "name": name
        ]
        
        do {
            try await Firestore.firestore().collection("users").document(id).updateData(data)
            print("プロフィール更新成功")
            
            // プロフィール更新後、最新のユーザー情報を取得
            await self.fetchCurrentUser()
       } catch {
           print("プロフィール更新失敗: \(error.localizedDescription)")
        }
    }
}
