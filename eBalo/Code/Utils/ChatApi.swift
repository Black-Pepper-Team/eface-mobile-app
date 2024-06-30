import Alamofire
import Foundation

class ChatApi {
    static let shared = ChatApi()
    
    let url: URL
    
    init() {
        self.url = Config.shared.general.chatApiURL
    }
    
    func sendMessage(_ id: String, _ text: String, _ key: String, _ contacts: [Contact]) async throws -> SendMessageResponse {
        let requestUrl = url.appendingPathComponent("/user-request")
        
        let requestPayload = SendMessageRequest(
            prompt: text,
            id: id,
            key: key,
            contacts: contacts
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(SendMessageResponse.self)
            .result
            .get()
        
        return response
    }
    
    func pollResponse(_ id: String) async throws -> PollResponseResponse {
        let requestUrl = url.appendingPathComponent("/poll-response")
        
        let requestPayload = PollResponseRequest(
            id: id,
            key: ""
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(PollResponseResponse.self)
            .result
            .get()
        
        return response
    }
}

struct SendMessageRequest: Codable {
    let prompt: String
    let id: String
    let key: String
    let contacts: [Contact]
}

struct SendMessageResponse: Codable {
    let id: String
    let status: String
}

struct PollResponseRequest: Codable {
    let id: String
    let key: String
}

struct PollResponseResponse: Codable {
    let id: String
    let status: String
    let text: String?
    let file: Data?
}
