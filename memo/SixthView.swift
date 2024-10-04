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
    
    @State private var aiResponse: String = "ボタンを押すとここに返答が表示されます"
    @State private var isRequesting: Bool = false
    @State private var buttonText: String = "AIに相談"
    @State private var buttonColor: Color = .blue
    
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
                    await fetchAIResponse()
                }
            }
            .padding()
            .background(buttonColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isRequesting)
        }
        .padding()
    }

    @MainActor
    func fetchAIResponse() async {
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
                default:
                    break
                }
            }
        } catch {
            aiResponse = "エラー: \(error.localizedDescription)"
            print("エラー発生: \(error.localizedDescription)")
        }
        
        isRequesting = false
        buttonText = "AIに相談"
        buttonColor = .blue
    }
}
