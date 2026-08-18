//
//  MemosViewModel.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/5.
//

import Foundation

@MainActor
class MemosViewModel: ObservableObject {
    let memosManager: MemosManager
    init(memosManager: MemosManager = .shared) {
        self.memosManager = memosManager
    }
    var memos: Memos { get throws { try memosManager.api } }

    @Published private(set) var memoList: [Memo] = [] {
        didSet {
            matrix = DailyUsageStat.calculateMatrix(memoList: memoList)
        }
    }
    @Published private(set) var tags: [Tag] = []
    @Published private(set) var matrix: [DailyUsageStat] = DailyUsageStat.initialMatrix
    @Published private(set) var inited = false
    @Published private(set) var loading = false
    
    func loadMemos() async throws {
        do {
            loading = true
            let user = try await memos.me()
            let response = try await memos.listMemos(data: MemosListMemo.Input(pageSize: 200, state: .normal, filter: "creator == '\(user.id)'"))
            memoList = response
            loading = false
            inited = true
        } catch {
            loading = false
            throw error
        }
    }
    
    func loadTags() async throws {
        let response = try await memos.tags(user: try await memos.me().id)
        tags = response.map({ name in
            Tag(name: name)
        })
    }
    
    func createMemo(content: String, visibility: MemosVisibility = .private, resourceIdList: [String]? = nil) async throws {
        let response = try await memos.createMemo(data: MemosCreate.Input(content: content, visibility: visibility, attachments: resourceIdList?.map { AttachmentInput(name: $0, filename: nil, content: nil, type: nil) }))
        memoList.insert(response, at: 0)
        try await loadTags()
    }
    
    private func updateMemo(_ memo: Memo) {
        for (i, item) in memoList.enumerated() {
            if item.id == memo.id {
                memoList[i] = memo
                break
            }
        }
    }
    
    func updateMemoOrganizer(id: String, pinned: Bool) async throws {
        let response = try await memos.updateMemoOrganizer(memoId: id, pinned: pinned)
        // the response might be incorrect
        var memo = response
        memo.pinned = pinned
        
        updateMemo(memo)
    }
    
    func archiveMemo(id: String) async throws {
        _ = try await memos.updateMemo(data: MemosPatch.Input(name: id, state: .archived, content: nil, visibility: nil, pinned: nil, attachments: nil))
        memoList = memoList.filter({ memo in
            memo.id != id
        })
    }
    
    func editMemo(id: String, content: String, visibility: MemosVisibility = .private, resourceIdList: [String]? = nil) async throws {
        let response = try await memos.updateMemo(data: MemosPatch.Input(name: id, state: nil, content: content, visibility: visibility, pinned: nil, attachments: resourceIdList?.map { AttachmentInput(name: $0, filename: nil, content: nil, type: nil) }))
        updateMemo(response)
        try await loadTags()
    }
    
    func upsertTags(names: [String]) async throws {
        for name in names {
            _ = name
        }
        
        try await loadTags()
    }
    
    func deleteTag(name: String) async throws {
        tags.removeAll { tag in
            tag.name == name
        }
    }

    func deleteMemo(id: String) async throws {
        _ = try await memos.deleteMemo(id: id)
        memoList = memoList.filter({ memo in
            memo.id != id
        })
    }
}
