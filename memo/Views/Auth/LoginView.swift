//
//  LoginView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct LoginView: View {
    
//    private let authViewModel = AuthViewModel()
//    let authViewModel: AuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Image
                BrandImage(size: .large)
                    .padding(.vertical, 32)
                
                // Form
                VStack (spacing: 24){
                    InputField(text: $email, label: "メールアドレス", placeholder: "入力してください", keyboardType: .emailAddress)
                    
                    InputField(text: $password, label: "パスワード", placeholder: "半角英数字6文字以上", isSecureField: true)
                }
                
                // Button
                BasicButton(label: "ログイン", icon: "arrow.right") {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                }
                .padding(.top, 24)
                
                Spacer()
                
                //Navigation
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack {
                        Text("まだアカウントをお持ちでない方")
                        Text("アカウント登録")
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color(.darkGray))
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    LoginView()
}
