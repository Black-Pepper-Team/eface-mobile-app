import Alamofire
import Foundation

class CommunitiesApi {
    static let shared = CommunitiesApi()
    
    let url: URL
    
    init() {
        self.url = Config.shared.general.communitiesApiURL
    }
    
    func fetchCommunities() async throws -> FetchCommunitiesResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community/list")
        
        let response = try await AF.request(requestUrl, method: .get)
            .serializingDecodable(FetchCommunitiesResponse.self)
            .result
            .get()
        
        return response
    }
    
    func importCommunity(_ contractAddress: String) async throws -> GetCommunityResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community/import")
        
        let requestPayload = ImportCommunityRequest(
            contractAddress: contractAddress
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(GetCommunityResponse.self)
            .result
            .get()
        
        return response
    }
    
    func createCommunity(_ collectionName: String, _ collectionSymbol: String) async throws -> GetCommunityResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community")
        
        let requestPayload = CreateCommunityRequest(
            collectionName: collectionName,
            collectionSymbol: collectionSymbol
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(GetCommunityResponse.self)
            .result
            .get()
        
        return response
    }
}

struct Community: Codable {
    let id: String
    let name: String
    let contractAddress: String
    let ownerAddress: String
    let status: CommunityStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case contractAddress = "contract_address"
        case ownerAddress = "owner_address"
        case status
    }
}

enum CommunityStatus: String, Codable {
    case ready = "ready"
    case deploying = "deploying"
    case deployFailed = "deploy-failed"
}

struct FetchCommunitiesResponse: Codable {
    let communities: [Community]
}

struct GetCommunityResponse: Codable {
    let community: Community
}

struct ImportCommunityRequest: Codable {
    let contractAddress: String
    
    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
    }
}

struct CreateCommunityRequest: Codable {
    let collectionName: String
    let collectionSymbol: String
    
    enum CodingKeys: String, CodingKey {
        case collectionName = "collection_name"
        case collectionSymbol = "collection_symbol"
    }
}
