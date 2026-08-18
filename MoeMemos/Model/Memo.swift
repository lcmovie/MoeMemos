//
//  Memo.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/4.
//

import Foundation
import SwiftUI

enum MemosVisibility: String, Decodable, Encodable, CaseIterable {
    case `public` = "PUBLIC"
    case `protected` = "PROTECTED"
    case `private` = "PRIVATE"
}

enum MemosRowStatus: String, Decodable, Encodable {
    case normal = "NORMAL"
    case archived = "ARCHIVED"
}

struct Memo: Decodable, Equatable, Identifiable {
    let id: String
    let createdTs: Date
    let creatorId: String
    let creatorName: String?
    var content: String
    var pinned: Bool
    let rowStatus: MemosRowStatus
    let updatedTs: Date
    let visibility: MemosVisibility
    let resourceList: [Resource]?

    enum CodingKeys: String, CodingKey { case name, createTime, creator, content, pinned, state, updateTime, visibility, attachments }
    init(from decoder: Decoder) throws {
        let v = try decoder.container(keyedBy: CodingKeys.self)
        id = try v.decode(String.self, forKey: .name); createdTs = try v.decodeIfPresent(Date.self, forKey: .createTime) ?? .now
        creatorId = try v.decodeIfPresent(String.self, forKey: .creator) ?? ""; creatorName = nil
        content = try v.decodeIfPresent(String.self, forKey: .content) ?? ""; pinned = try v.decodeIfPresent(Bool.self, forKey: .pinned) ?? false
        rowStatus = try v.decodeIfPresent(MemosRowStatus.self, forKey: .state) ?? .normal; updatedTs = try v.decodeIfPresent(Date.self, forKey: .updateTime) ?? createdTs
        visibility = try v.decodeIfPresent(MemosVisibility.self, forKey: .visibility) ?? .private; resourceList = try v.decodeIfPresent([Resource].self, forKey: .attachments)
    }
    init(id: String, createdTs: Date, creatorId: String, creatorName: String?, content: String, pinned: Bool, rowStatus: MemosRowStatus, updatedTs: Date, visibility: MemosVisibility, resourceList: [Resource]?) {
        self.id = id; self.createdTs = createdTs; self.creatorId = creatorId; self.creatorName = creatorName; self.content = content; self.pinned = pinned
        self.rowStatus = rowStatus; self.updatedTs = updatedTs; self.visibility = visibility; self.resourceList = resourceList
    }
}

struct Tag: Identifiable, Hashable {
    let name: String
    
    var id: String { name }
}

extension MemosVisibility {
    var title: LocalizedStringKey {
        switch self {
        case .public:
            return "memo.visibility.public"
        case .protected:
            return "memo.visibility.protected"
        case .private:
            return "memo.visibility.private"
        }
    }
    
    var iconName: String {
        switch self {
        case .public:
            return "globe"
        case .protected:
            return "house"
        case .private:
            return "lock"
        }
    }
}

extension Memo {
    func renderTime() -> String {
        if Calendar.current.dateComponents([.day], from: createdTs, to: .now).day! > 7 {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            return formatter.string(from: createdTs)
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: createdTs, relativeTo: .now)
    }
}
