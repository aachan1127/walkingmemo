//
//  SentimentAnalyzer.swift
//  memo
//
//  Created by 山本明音 on 2024/10/04.
//

import Foundation
import NaturalLanguage

class SentimentAnalyzer {
    func analyzeSentiment(for text: String, completion: @escaping (String) -> Void) {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        // NLTaggerを使用して感情スコアを取得
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let sentimentScore = Double(sentiment?.rawValue ?? "0") ?? 0.0

        // 分析結果をコンソールに出力
        print("分析結果: \(text) -> 感情スコア: \(sentimentScore)")

        if sentimentScore > 0 {
            print("分類結果: ポジティブ") // デバッグ出力
            completion("ポジティブ")
        } else if sentimentScore < 0 {
            print("分類結果: ネガティブ") // デバッグ出力
            completion("ネガティブ")
        } else {
            print("分類結果: その他") // デバッグ出力
            completion("その他")
        }
    }
}
