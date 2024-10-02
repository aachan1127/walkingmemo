//
//  fetchAIResponse.swift
//  memo
//
//  Created by 山本明音 on 2024/10/01.
//

func fetchAIResponse(for inputText: String) {
    // Hugging FaceのAPIエンドポイント
    let url = URL(string: "https://api-inference.huggingface.co/models/gpt2")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Content-Typeの追加

    // リクエストボディとして送信するデータをJSON形式に変換
    let json: [String: Any] = ["inputs": inputText]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
        print("Error: JSON serialization failed")
        return
    }
    
    request.httpBody = jsonData
    
    // ネットワークリクエストを送信
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)") // ネットワークエラーを表示
            return
        }
        
        guard let data = data else {
            print("Error: No data received")
            return
        }
        
        // レスポンスデータを解析
        if let aiResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
           let generatedText = aiResult.first?["generated_text"] as? String {
            DispatchQueue.main.async {
                aiResponse = generatedText
                isShowSixthView = true
            }
        } else {
            DispatchQueue.main.async {
                aiResponse = "返答を生成できませんでした。"
            }
            print("Error: Could not parse AI response")
        }
    }
    task.resume()
}
