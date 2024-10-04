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
    @State private var navigateToHome = false
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
                Button("Home画面に戻る") {
                    navigateToHome = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
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
            }
            .navigationTitle("フィードバック画面")
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }

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
                    saveFeedbackToFirebase()
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
    
    private func saveFeedbackToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        let db = Firestore.firestore()
        let documentID = UUID().uuidString
        
        // 日付のみ（時刻を00:00:00）に設定
        let date = Calendar.current.startOfDay(for: Date())
        let timestamp = Timestamp(date: date)
        
        let feedbackData: [String: Any] = [
            "userID": userID,
            "inputDetail": inputDetail,
            "inputEmotion": inputEmotion,
            "inputPositiveThought": inputPositiveThought,
            "aiResponse": aiResponse,
            "timestamp": timestamp
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
