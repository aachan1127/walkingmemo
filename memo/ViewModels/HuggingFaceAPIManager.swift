//
//  HuggingFaceAPIManager.swift
//  memo
//
//  Created by 山本明音 on 2024/10/01.
//

import Foundation

class HuggingFaceAPIManager {
    private let apiURL = "https://api-inference.huggingface.co/models/gpt2"
    private let apiToken = "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" // Hugging FaceのAPIトークン

    // API呼び出しのメソッド
    func fetchAIResponse(for inputText: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 入力テキストをJSONとして送信
        let json: [String: Any] = ["inputs": inputText]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Error: JSON serialization failed")
            return
        }
        request.httpBody = jsonData
        
        // URLSessionでリクエストを送信
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // 応答をデコードしてコールバックで返す
            if let aiResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
               let generatedText = aiResult.first?["generated_text"] as? String {
                completion(generatedText)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
