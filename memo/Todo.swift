//
//  Todo.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import Foundation

struct Todo: Identifiable, Codable, Equatable {
    var id: UUID
    var value: String
    var date: Date? // 日付をオプショナルに変更
    var isDeleted: Bool = false // 削除フラグを追加
}
