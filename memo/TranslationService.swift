//
//  TranslationService.swift
//  memo
//
//  Created by あなたの名前 on 2024/10/05.
//

import Foundation
import Alamofire

class TranslationService {
    static let shared = TranslationService()

    private init() {}

    func translateText(text: String, targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = getApiKey() else {
            print("APIキーが見つかりません")
            completion(.failure(NSError(domain: "APIKeyError", code: -1, userInfo: nil)))
            return
        }

        let url = "https://translation.googleapis.com/language/translate/v2"
        let parameters: [String: Any] = [
            "q": text,
            "target": targetLanguage,
            "format": "text",
            "key": apiKey
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseDecodable(of: TranslationResponse.self) { response in
            switch response.result {
            case .success(let translationResponse):
                if let translatedText = translationResponse.data.translations.first?.translatedText {
                    completion(.success(translatedText))
                } else {
                    completion(.failure(NSError(domain: "TranslationError", code: -1, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func getApiKey() -> String? {
        // APIキーを安全に取得する方法を実装
        // 例: Info.plist から読み込む
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let apiKey = plist["API_KEY"] as? String {
            return apiKey
        }
        return nil
    }
}

// 翻訳APIのレスポンスモデル
struct TranslationResponse: Decodable {
    let data: TranslationData
}

struct TranslationData: Decodable {
    let translations: [TranslatedText]
}

struct TranslatedText: Decodable {
    let translatedText: String
}
