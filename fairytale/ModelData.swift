import Foundation

struct Fairytale: Codable {
    let fairytaleId: Int64
    let mainImageUrl: String
    let name: String
}

struct APIResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [Fairytale]
}
