//
//  AilogView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/04.
//

import SwiftUI
import Firebase

struct AilogView: View {
    var aiFeedback: String
    var inputDetail: String
    var inputPositiveThought: String
    var selectedDate: Date
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss // 画面を閉じるための環境変数

    var body: some View {
        VStack {
            Text("AIフィードバック")
                .font(.title)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("入力した詳細")
                        .font(.headline)
                    Text(inputDetail)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Text("前向きな考え")
                        .font(.headline)
                    Text(inputPositiveThought)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)

                    Text("AIフィードバック")
                        .font(.headline)
                    Text(aiFeedback)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Button("削除") {
                    deleteFeedback() // Firebaseからデータを削除
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(8)
            }
            .frame(maxHeight: 900)
        }
        .padding()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // Firebaseからデータを削除する関数
    private func deleteFeedback() {
        guard let userID = authViewModel.currentUser?.id else {
            print("ユーザーがログインしていません")
            return
        }

        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        // 指定された日付範囲とユーザーIDに基づいてドキュメントを削除
        db.collection("feedbacks")
            .whereField("userID", isEqualTo: userID)
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThan: endTimestamp)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("フィードバック削除エラー: \(error.localizedDescription)")
                    return
                }
                if let document = snapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("削除に失敗しました: \(error.localizedDescription)")
                        } else {
                            print("フィードバックが削除されました")
                            dismiss() // 画面を閉じる
                        }
                    }
                } else {
                    print("該当フィードバックが見つかりませんでした")
                }
            }
    }
}

#Preview {
    AilogView(aiFeedback: "サンプルフィードバック", inputDetail: "サンプル詳細", inputPositiveThought: "サンプル前向きな考え", selectedDate: Date())
        .environmentObject(AuthViewModel())
}
