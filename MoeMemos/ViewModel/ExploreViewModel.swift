//
//  ExploreViewModel.swift
//  MoeMemos
//
//  Created by Mudkip on 2023/3/26.
//

import Foundation

@MainActor
class ExploreViewModel: ObservableObject {
    let memosManager: MemosManager
    init(memosManager: MemosManager = .shared) {
        self.memosManager = memosManager
    }
    var memos: Memos { get throws { try memosManager.api } }

    @Published private(set) var memoList: [Memo] = []
    @Published private(set) var loading = false
    @Published private(set) var hasMore = false
    private var currentOffset = 0
    
    func loadMemos() async throws {
        do {
            loading = true
            let response = try await memos.listMemos(data: MemosListMemo.Input(pageSize: 100, state: .normal, filter: nil))
            memoList = response
            loading = false
            hasMore = false
        } catch {
            loading = false
            throw error
        }
    }
    
    func loadMoreMemos() async throws {
        guard !loading && hasMore else { return }
        do {
            loading = true
            let response: [Memo] = []
            memoList += response
            loading = false
            hasMore = response.count >= 20
        } catch {
            loading = false
            throw error
        }
    }
}
