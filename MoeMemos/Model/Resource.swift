//
//  Resource.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/10.
//

import Foundation

struct Resource: Decodable, Identifiable, Equatable {
    let id: String
    let createdTs: Date
    let creatorId: String
    let filename: String
    let size: Int
    let type: String
    let updatedTs: Date
    let externalLink: String?
    let publicId: String?
    let name: String?
    let uid: String?

    enum CodingKeys: String, CodingKey { case name, createTime, filename, size, type, externalLink }
    init(from decoder: Decoder) throws {
        let v = try decoder.container(keyedBy: CodingKeys.self)
        id = try v.decode(String.self, forKey: .name); createdTs = try v.decodeIfPresent(Date.self, forKey: .createTime) ?? .now; creatorId = ""
        filename = try v.decodeIfPresent(String.self, forKey: .filename) ?? ""
        if let s = try? v.decode(String.self, forKey: .size) { size = Int(s) ?? 0 } else { size = try v.decodeIfPresent(Int.self, forKey: .size) ?? 0 }
        type = try v.decodeIfPresent(String.self, forKey: .type) ?? "application/octet-stream"; updatedTs = createdTs
        externalLink = try v.decodeIfPresent(String.self, forKey: .externalLink); publicId = nil; name = id; uid = nil
    }
    init(id: String, createdTs: Date, creatorId: String, filename: String, size: Int, type: String, updatedTs: Date, externalLink: String?, publicId: String?, name: String?, uid: String?) {
        self.id = id; self.createdTs = createdTs; self.creatorId = creatorId; self.filename = filename; self.size = size; self.type = type
        self.updatedTs = updatedTs; self.externalLink = externalLink; self.publicId = publicId; self.name = name; self.uid = uid
    }
    
    func path() -> String {
        if let uid = uid, !uid.isEmpty {
            return "/o/r/\(uid)"
        }
        if let name = name, !name.isEmpty {
            return "/o/r/\(name)"
        }
        if let publicId = publicId, !publicId.isEmpty {
            return "/o/r/\(id)/\(publicId)"
        }
        return "/file/\(id)/\(filename)"
    }
}
