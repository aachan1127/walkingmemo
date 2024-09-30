//
//  EditProfileView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/28.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var selectedImage: PhotosPickerItem? = nil
    @State var name = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Edit field
                editField
            }
            .navigationTitle("プロフィール変更")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("変更") {
                        Task {
                            
                            print("変更ボタンが押されました")
                            
                            guard let currentUser = authViewModel.currentUser else { return }
                            
                            await authViewModel.updateUserProfile(
                                withId: currentUser.id,
                                name: name)
                            
                            dismiss() //変更ボタンを押した後に画面を閉じる処理
                        }
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    EditProfileView()
}

extension EditProfileView {
    
    private var editField: some View {
        VStack(spacing: 16) {
            //photo picker
            PhotosPicker(selection: $selectedImage) {
                ZStack {
                    Image("avatar")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .frame(width: 150)
                    
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.white.opacity(0.75))
                        .frame(width: 60)
                }
            }
            
            // Input field
            InputField(text: $name, label: "お名前", placeholder: "")
            
        }
        .padding(.horizontal)
        .padding(.vertical, 32)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
        .padding()
        .onAppear {
            if let currentUser = authViewModel.currentUser {
                name = currentUser.name
            }
        }
    }
}
