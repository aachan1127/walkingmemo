//
//  SettingView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/29.
//

import SwiftUI

struct SettingView: View {
    
    @AppStorage("taskCategory") var taskCategory: String = "タスク"
    @AppStorage("positiveCategory") var positiveCategory: String = "ポジティブ"
    @AppStorage("negativeCategory") var negativeCategory: String = "ネガティブ"
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("カテゴリ設定")) {
                    TextField("タスクカテゴリ", text: $taskCategory)
                    TextField("ポジティブカテゴリ", text: $positiveCategory)
                    TextField("ネガティブカテゴリ", text: $negativeCategory)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
