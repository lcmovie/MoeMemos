import Foundation

protocol MemosAPI {
    associatedtype Param = (); associatedtype Input: Encodable = Data; associatedtype Output: Decodable = Data
    static var path: String { get }; static var method: HTTPMethod { get }; static var encodeMode: HTTPBodyEncodeMode { get }
    static var decodeMode: HTTPBodyDecodeMode { get }; static func path(_ param: Param) -> String
}
extension MemosAPI { static var path: String { "/" } }
extension MemosAPI where Param == () { static func path(_ param: Param) -> String { path } }

struct CurrentUserResponse: Decodable { let user: MemosUser }
struct ListMemosResponse: Decodable { let memos: [Memo]; let nextPageToken: String? }
struct ListAttachmentsResponse: Decodable { let attachments: [Resource] }
struct UserStatsResponse: Decodable { let tagCount: [String: Int]? }
struct AttachmentInput: Encodable { let name: String?; let filename: String?; let content: String?; let type: String? }
struct MemosSignIn { struct Input: Encodable { let email: String; let username: String; let password: String; let remember: Bool } }

struct MemosMe: MemosAPI { typealias Output = CurrentUserResponse; static let method = HTTPMethod.get; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/auth/me" }
struct MemosListMemo: MemosAPI {
    struct Input: Encodable { let pageSize: Int?; let state: MemosRowStatus?; let filter: String? }
    typealias Output = ListMemosResponse; static let method = HTTPMethod.get; static let encodeMode = HTTPBodyEncodeMode.urlencoded; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/memos"
}
struct MemosTag: MemosAPI {
    typealias Output = UserStatsResponse; typealias Param = String; static let method = HTTPMethod.get; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.json
    static func path(_ user: String) -> String { "/api/v1/\(user):getStats" }
}
struct MemosCreate: MemosAPI {
    struct Input: Encodable { let content: String; let visibility: MemosVisibility?; let attachments: [AttachmentInput]? }
    typealias Output = Memo; static let method = HTTPMethod.post; static let encodeMode = HTTPBodyEncodeMode.json; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/memos"
}
struct MemosPatch: MemosAPI {
    struct Input: Encodable { let name: String; let state: MemosRowStatus?; let content: String?; let visibility: MemosVisibility?; let pinned: Bool?; let attachments: [AttachmentInput]? }
    typealias Output = Memo; typealias Param = String; static let method = HTTPMethod.patch; static let encodeMode = HTTPBodyEncodeMode.json; static let decodeMode = HTTPBodyDecodeMode.json
    static func path(_ name: String) -> String { "/api/v1/\(name)" }
}
struct MemosDelete: MemosAPI { typealias Param = String; static let method = HTTPMethod.delete; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.none; static func path(_ name: String) -> String { "/api/v1/\(name)" } }
struct MemosListResource: MemosAPI { typealias Output = ListAttachmentsResponse; static let method = HTTPMethod.get; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/attachments" }
struct MemosUploadResource: MemosAPI { typealias Input = AttachmentInput; typealias Output = Resource; static let method = HTTPMethod.post; static let encodeMode = HTTPBodyEncodeMode.json; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/attachments" }
struct MemosDeleteResource: MemosAPI { typealias Param = String; static let method = HTTPMethod.delete; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.none; static func path(_ name: String) -> String { "/api/v1/\(name)" } }
struct MemosStatus: MemosAPI { typealias Output = MemosServerStatus; static let method = HTTPMethod.get; static let encodeMode = HTTPBodyEncodeMode.none; static let decodeMode = HTTPBodyDecodeMode.json; static let path = "/api/v1/instance/profile" }
struct MemosErrorOutput: Decodable { let message: String? }

extension MemosAPI {
    static func request(_ memos: Memos, data: Input?, param: Param) async throws -> Output {
        var url = memos.host.appendingPathComponent(path(param))
        if method == .get, encodeMode == .urlencoded, let data { var c = URLComponents(url: url, resolvingAgainstBaseURL: false)!; c.queryItems = try encodeToQueryItems(data); url = c.url! }
        var request = URLRequest(url: url); request.httpMethod = method.rawValue
        if let token = memos.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let accept = decodeMode.contentType() { request.setValue(accept, forHTTPHeaderField: "Accept") }
        if method == .post || method == .put || method == .patch { if let type = encodeMode.contentType() { request.setValue(type, forHTTPHeaderField: "Content-Type") }; if let data { request.httpBody = try encodeMode.encode(data) } }
        let (body, response) = try await memos.session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MemosError.unknown }
        guard (200..<300).contains(response.statusCode) else { let e = try? JSONDecoder().decode(MemosErrorOutput.self, from: body); throw MemosError.invalidStatusCode(response.statusCode, e?.message ?? String(data: body, encoding: .utf8)) }
        return try decodeMode.decode(body)
    }
}
