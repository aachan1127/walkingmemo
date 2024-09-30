//
//  InputField.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import SwiftUI

struct InputField: View {
    
    @Binding var text: String
    let label: String
    let placeholder: String
    var isSecureField = false
    var withDivider = true
    var isVertical = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            if isSecureField {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text, axis: isVertical ? .vertical : .horizontal)
                // ログイン画面でメールアドレスを入力するときに先頭が大文字にならないようにする処理
                    .textInputAutocapitalization(.never)
                    .keyboardType(keyboardType)
            }
            Divider()
        }
    }
}

#Preview {
    InputField(text: .constant(""), label: "メールアドレス", placeholder: "入力してください")
}
