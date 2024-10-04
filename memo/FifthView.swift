//
//  FifthView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/12.
//

import SwiftUI
import Firebase
import FirebaseAuth
import OpenAI

struct FifthView: View {
    var inputDetail: String
    var inputEmotion: String
    var inputPositiveThought: String

    @State private var aiResponse: String = "ここにフィードバックが表示されます"
    @State private var isRequesting: Bool = false
    @State private var navigateToHome = false // 新しい遷移フラグ
    let openAI: OpenAI
    
    init(inputDetail: String, inputEmotion: String, inputPositiveThought: String) {
        self.inputDetail = inputDetail
        self.inputEmotion = inputEmotion
        self.inputPositiveThought = inputPositiveThought
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "DEFAULT_API_KEY"
        self.openAI = OpenAI(apiToken: apiKey)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView {
                    Text(aiResponse)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 300)
                
                Button(isRequesting ? "リクエスト送信中..." : "AIからフィードバックをもらう") {
                    Task {
                        await fetchAIResponse()
                    }
                }
                .padding()
                .background(isRequesting ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isRequesting)
                
                
                    // Home画面に戻るボタン
                    Button("Home画面に戻る") {
                        saveFeedbackToFirebase() // Firebaseにフィードバックを保存
                        // 他の処理（必要に応じて）
                        navigateToHome = true  // HomeViewへ遷移するトリガー
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
            }
            .navigationTitle("フィードバック画面")
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView() // navigateToHomeがtrueになった時に遷移
            }
        }
    }

    // AIからのフィードバックを取得する関数
    @MainActor
    func fetchAIResponse() async {
        isRequesting = true
        let prompt = """
        あなたは認知療法の専門家です。ユーザーが以下の問題と感情に基づき、前向きな考えを導き出しました。この内容に対して、褒めながら、できるだけ肯定的に、認知療法の観点でどのような点が良かったのかを返答して下さい。
        - 問題: \(inputDetail)
        - 感情: \(inputEmotion)
        - 前向きな考え: \(inputPositiveThought)
        """
        
        guard let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: "あなたは認知療法の専門家です。"),
              let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
            print("メッセージ生成エラー")
            return
        }
        
        let query = ChatQuery(messages: [systemMessage, userMessage], model: .gpt3_5Turbo)
        
        do {
            let result = try await openAI.chats(query: query)
            if let firstChoice = result.choices.first {
                switch firstChoice.message {
                case .assistant(let assistantMessage):
                    aiResponse = assistantMessage.content ?? "No response"
                    UserDefaults.standard.set(aiResponse, forKey: "aiResponse")
                default:
                    break
                }
            }
        } catch {
            aiResponse = "エラー: \(error.localizedDescription)"
            print("エラー発生: \(error.localizedDescription)")
        }
        
        isRequesting = false
    }
    
    // Firebaseにデータを保存する関数
    private func saveFeedbackToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        let db = Firestore.firestore()
        let documentID = UUID().uuidString // 一意のドキュメントID
        
        // 保存するデータ
        let feedbackData: [String: Any] = [
            "userID": userID,
            "inputDetail": inputDetail,
            "inputEmotion": inputEmotion,
            "inputPositiveThought": inputPositiveThought,
            "aiResponse": aiResponse,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("feedbacks").document(documentID).setData(feedbackData) { error in
            if let error = error {
                print("データの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("データがFirebaseに保存されました")
            }
        }
    }
}

#Preview {
    FifthView(inputDetail: "サンプル詳細", inputEmotion: "サンプル感情", inputPositiveThought: "サンプル前向きな考え")
}
