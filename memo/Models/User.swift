//
//  User.swift
//  memo
//
//  Created by 山本明音 on 2024/09/27.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
//    var photoUrl: String?　 画像登録させる？
}
