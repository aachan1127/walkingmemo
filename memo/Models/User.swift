//
//  User.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    var id: String // 必須のString型に変更
    var name: String
    var email: String
}
