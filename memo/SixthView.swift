//
//  SixthView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/02.
//

import SwiftUI
import OpenAI

struct SixthView: View {
    var selectedTodo: Todo // ThirdViewから渡される選択されたTodo
    @State private var aiResponse: String = "AIからの返答を待っています..." // AIからの返答を格納する変数
    let openAI: OpenAI
    
    // init()で環境変数からAPIキーを取得し、OpenAIクラスに渡す
    init(selectedTodo: Todo) {
        self.selectedTodo = selectedTodo
        // 環境変数からAPIキーを取得
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "DEFAULT_API_KEY"
        self.openAI = OpenAI(apiToken: apiKey)
    }
    
    var body: some View {
        VStack {
            // ユーザーが選択した問題を表示
            Text("ユーザーが抱えている問題: \(selectedTodo.value)")
                .font(.title)
                .padding()

            // スクロール可能なAIからの返答
            ScrollView {
                Text(aiResponse)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300) // 必要に応じてスクロールの高さを調整

            // AIに相談ボタン
            Button("AIに相談") {
                Task {
                    await fetchAIResponse(for: selectedTodo.value) // 選択されたTodoの内容を送信
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }

    // AIからのアドバイスを取得する関数
    @MainActor
    func fetchAIResponse(for inputText: String) async {
        print("AIリクエスト開始")

        // 認知療法のプロンプトを設定
        let prompt = """
        あなたは認知療法の専門家です。ユーザーが抱えるネガティブな考えに対して、前向きな思考を促すアドバイスを提供してください。
        ユーザーが抱えている問題: \(inputText)
        """

        // OpenAIへのリクエスト準備
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
                default:
                    break
                }
            }
        } catch {
            aiResponse = "エラー: \(error.localizedDescription)"
            print("エラー発生: \(error.localizedDescription)")
        }
    }
}
