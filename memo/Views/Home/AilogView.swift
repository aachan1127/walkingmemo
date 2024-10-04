//
//  AilogView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/04.
//

import SwiftUI

struct AilogView: View {
    var aiFeedback: String

    var body: some View {
        VStack {
            Text("AIフィードバック")
                .font(.title)
                .padding()
            
            ScrollView {
                Text(aiFeedback)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
        }
        .padding()
    }
}

#Preview {
    AilogView(aiFeedback: "サンプルフィードバック")
}
