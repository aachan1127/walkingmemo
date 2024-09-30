//
//  HomeView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel() // StateObjectでViewModelを管理
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    WalkView()
                } label: {
                    Text("WalkViewへナビ遷移")
                }
            }
            .padding()
            .navigationTitle("このアプリのタイトル？") // アプリのタイトル決まったらここ変える？
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandImage(size: .small)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MyPageView()
                    } label: {
                        Image("avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
            }
            .navigationTitle("Home画面")
        }
        .tint(.primary)
    }
}

#Preview {
    HomeView()
}
