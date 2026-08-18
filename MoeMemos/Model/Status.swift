//
//  Status.swift
//  MoeMemos
//
//  Created by Mudkip on 2023/1/30.
//

import Foundation

struct MemosProfile: Decodable {
    let version: String
}

struct MemosServerStatus: Decodable {
    let profile: MemosProfile
    enum CodingKeys: String, CodingKey { case version }
    init(from decoder: Decoder) throws {
        let v = try decoder.container(keyedBy: CodingKeys.self)
        profile = MemosProfile(version: try v.decode(String.self, forKey: .version))
    }
}
