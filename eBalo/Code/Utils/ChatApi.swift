import Alamofire
import Foundation

class ChatApi {
    static let shared = ChatApi()
    
    let url: URL
    
    init() {
        self.url = Config.shared.general.chatApiURL
    }
    
    func sendMessage(_ text: String) async throws -> SendMessageResponse {
        let requestUrl = url.appendingPathComponent("/user-request")
        
        let requestPayload = SendMessageRequest(
            prompt: text,
            id: "",
            key: ""
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(SendMessageResponse.self)
            .result
            .get()
        
        return response
    }
    
    func pollResponse() async throws -> PollResponseResponse {
        let requestUrl = url.appendingPathComponent("/poll-response")
        
        let requestPayload = PollResponseRequest(
            id: "1",
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
