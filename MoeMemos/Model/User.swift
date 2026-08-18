//
//  User.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/5.
//

import Foundation

struct MemosUserSetting: Decodable {
    static let memoVisibilityKey = "memo-visibility"
    let key: String
    let value: String
}

struct MemosUser: Decodable {
    let createdTs: Date
    let email: String?
    let username: String?
    let id: String
    let name: String?
    let nickname: String?
    let role: String?
    let updatedTs: Date?
    let userSettingList: [MemosUserSetting]?

    enum CodingKeys: String, CodingKey { case name, createTime, updateTime, email, username, displayName, role }
    init(from decoder: Decoder) throws {
        let v = try decoder.container(keyedBy: CodingKeys.self)
        id = try v.decodeIfPresent(String.self, forKey: .name) ?? ""; createdTs = try v.decodeIfPresent(Date.self, forKey: .createTime) ?? .now
        updatedTs = try v.decodeIfPresent(Date.self, forKey: .updateTime); email = try v.decodeIfPresent(String.self, forKey: .email)
        username = try v.decodeIfPresent(String.self, forKey: .username); name = try v.decodeIfPresent(String.self, forKey: .displayName)
        nickname = name; role = try v.decodeIfPresent(String.self, forKey: .role); userSettingList = nil
    }
    
    var displayName: String {
        nickname ?? name ?? ""
    }
    
    var displayEmail: String {
        email ?? username ?? ""
    }
}

extension MemosUser {
    var defaultMemoVisibility: MemosVisibility {
        guard let visibilityJson = self.userSettingList?.first(where: { $0.key == MemosUserSetting.memoVisibilityKey })?.value.data(using: .utf8) else { return .private }
        do {
            return try JSONDecoder().decode(MemosVisibility.self, from: visibilityJson)
        } catch {
            return .private
        }
    }
}
