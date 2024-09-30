//
//  MyPageView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct MyPageView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfileView = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            
            // User info
            userInfo
            
            // System info
            Section("一般") {
                
                MyPageRow(iconName: "gear", label: "バージョン", tintColor: .gray, value: "1.0.0")
            }
            
            // Navigation
            Section("アカウント") {
                Button {
                    showEditProfileView.toggle()
                } label: {
                    MyPageRow(iconName: "square.and.pencil.circle.fill", label: "プロフィール変更", tintColor: .red)
                }
                
                Button {
                    authViewModel.logout()
                } label: {
                    
                    MyPageRow(iconName: "arrow.left.circle.fill", label: "ログアウト", tintColor: .red)
                }
                
                Button {
                    showDeleteAlert = true
                } label: {
                    MyPageRow(iconName: "xmark.circle.fill", label: "アカウント削除", tintColor: .red)
                }
                .alert("アカウント削除", isPresented: $showDeleteAlert) {
                    Button("キャンセル") {}
                        // AuthViewModelに実装したdeletAccountメソッドを呼び出す
                    Button("削除") {Task { await authViewModel.deleteAccount() }}
                } message: {
                    Text("アカウントを削除しますか？")
                }

                
            }
            
        }
        .sheet(isPresented: $showEditProfileView, content: {
            EditProfileView()
        })
    }
}

#Preview {
    MyPageView()
}

extension MyPageView {
    private var userInfo: some View {
        Section {
            HStack(spacing: 16) {
                Image("avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUser?.name ?? "")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.footnote)
                        .tint(.gray)
                }
            }
        }
    }
}
