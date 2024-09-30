//
//  ContentView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/02.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    ContentView()
}
