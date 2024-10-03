//
//  FifthView.swift
//  memo
//
//  Created by 山本明音 on 2024/09/12.
//

import SwiftUI
import OpenAI

struct FifthView: View {
    var inputDetail: String
    var inputEmotion: String
    var inputPositiveThought: String

    @State private var aiResponse: String = "ここにフィードバックが表示されます"
    @State private var isRequesting: Bool = false // リクエスト中の状態管理
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
                // 最初の画面に戻るボタン
                NavigationLink {
                    HomeView()
                } label: {
                    Text("最初の画面に戻る")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .onAppear {
                    // FifthViewに遷移する際にローカルデータを削除
                    UserDefaults.standard.removeObject(forKey: "aiResponse")
                }

                ZStack {
                    Color.blue
                        .ignoresSafeArea() // 全画面を青色にする
                    VStack {
                        Text("FifthView")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()

                        // フィードバック表示部分
                        ScrollView {
                            Text(aiResponse)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 300)

                        // AIリクエストボタン
                        Button(isRequesting ? "リクエスト送信中..." : "AIからフィードバックをもらう") {
                            Task {
                                await fetchAIResponse() // APIリクエスト送信
                            }
                        }
                        .padding()
                        .background(isRequesting ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isRequesting) // リクエスト中はボタン無効化
                    }
                }
            }
            .navigationTitle("フィードバック画面")
        }
    }

    // AIからのフィードバックを取得する関数
    @MainActor
    func fetchAIResponse() async {
        isRequesting = true // リクエスト開始時にフラグを立てる

        // プロンプト作成
        let prompt = """
        あなたは認知療法の専門家です。ユーザーが以下の問題と感情に基づき、前向きな考えを導き出しました。この内容に対して、できるだけ肯定的で、認知療法の観点でどのような点が良かったのかを返答して下さい。
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
                    print("AIレスポンス受信: \(aiResponse)")

                    // ローカルに保存
                    UserDefaults.standard.set(aiResponse, forKey: "aiResponse")
                default:
                    break
                }
            }
        } catch {
            aiResponse = "エラー: \(error.localizedDescription)"
            print("エラー発生: \(error.localizedDescription)")
        }
        
        isRequesting = false // リクエスト終了時にフラグを下ろす
    }
}

#Preview {
    FifthView(inputDetail: "サンプル詳細", inputEmotion: "サンプル感情", inputPositiveThought: "サンプル前向きな考え")
}
