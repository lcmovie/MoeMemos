//
//  ArchivedMemoListViewModel.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/11/2.
//

import Foundation

@MainActor
class ArchivedMemoListViewModel: ObservableObject {
    let memosManager: MemosManager
    init(memosManager: MemosManager = .shared) {
        self.memosManager = memosManager
    }
    var memos: Memos { get throws { try memosManager.api } }

    @Published private(set) var archivedMemoList: [Memo] = []
    
    func loadArchivedMemos() async throws {
        let user = try await memos.me()
        let response = try await memos.listMemos(data: MemosListMemo.Input(pageSize: 200, state: .archived, filter: "creator == '\(user.id)'"))
        archivedMemoList = response
    }
    
    func restoreMemo(id: String) async throws {
        _ = try await memos.updateMemo(data: MemosPatch.Input(name: id, state: .normal, content: nil, visibility: nil, pinned: nil, attachments: nil))
        archivedMemoList = archivedMemoList.filter({ memo in
            memo.id != id
        })
    }
    
    func deleteMemo(id: String) async throws {
        _ = try await memos.deleteMemo(id: id)
        archivedMemoList = archivedMemoList.filter({ memo in
            memo.id != id
        })
    }
}
