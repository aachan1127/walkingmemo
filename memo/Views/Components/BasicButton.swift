//
//  BasicButton.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct BasicButton: View {
    
    let label: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
    } label: {
        HStack {
            Text(label)
            
            if let name = icon {
                Image(systemName: name)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .fontWeight(.bold)
        .foregroundStyle(.white)
        .background(
            .linearGradient(colors: [.brandColorLight, .brandColorDark], startPoint: .topTrailing, endPoint: .bottomLeading))
        .clipShape(Capsule())
        
    }

    }
}

#Preview {
    BasicButton(label: "ボタン") {
        print("ボタンがタップされました")
    }
}
