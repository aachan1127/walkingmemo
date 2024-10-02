//
//  FifthView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/12.
//

import SwiftUI

struct FifthView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("最初の画面に戻る")
                }

                ZStack {
                    
                    Color.blue
                        .ignoresSafeArea() //上下の余白をなくす
                    Text("FifthView")
                }
            }
            .navigationTitle("画面5")
        }
    }
}

struct FifthView_Previews: PreviewProvider {
    static var previews: some View {
        FifthView()
    }
}
