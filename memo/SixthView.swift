//
//  SixthView.swift
//  memo
//
//  Created by 山本明音 on 2024/10/02.
//

import SwiftUI
import OpenAI

struct SixthView: View {
    var selectedTodo: Todo
    var inputDetail: String
    var inputEmotion: String
    
    @State private var aiResponse: String = UserDefaults.standard.string(forKey: "aiResponse") ?? "ボタンを押すとここに返答が表示されます"
    @State private var isRequesting: Bool = false // リクエスト中かどうかを示すフラグ
    @State private var buttonText: String = "AIに相談" // ボタンの表示テキスト
    @State private var buttonColor: Color = .blue // ボタンの色
    
    let openAI: OpenAI
    
    init(selectedTodo: Todo, inputDetail: String, inputEmotion: String) {
        self.selectedTodo = selectedTodo
        self.inputDetail = inputDetail
        self.inputEmotion = inputEmotion
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "DEFAULT_API_KEY"
        self.openAI = OpenAI(apiToken: apiKey)
    }
    
    var body: some View {
        VStack {
            Text("ユーザーが抱えている問題: \(selectedTodo.value)")
                .font(.title)
                .padding()
            
            ScrollView {
                Text(aiResponse)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
            
            Button(buttonText) {
                Task {
                    await fetchAIResponse() // プロンプトの内容を送信
                }
            }
            .padding()
            .background(buttonColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isRequesting) // リクエスト中はボタンを無効化
        }
        .padding()
    }

    // AIからのアドバイスを取得する関数
    @MainActor
    func fetchAIResponse() async {
        // リクエスト送信中のUI更新
        isRequesting = true
        buttonText = "リクエスト送信中..."
        buttonColor = .red
        
        let prompt = """
        あなたは認知療法の専門家です。ユーザーが抱えている問題に対して、前向きな思考を促すアドバイスを提供してください。
        - 問題: \(inputDetail)
        - 感情: \(inputEmotion)
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
        
        // リクエスト終了後のUI更新
        isRequesting = false
        buttonText = "AIに相談"
        buttonColor = .blue
    }
}
