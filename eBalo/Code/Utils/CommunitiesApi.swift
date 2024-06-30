import Alamofire
import Foundation
import Web3
import Identity

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
    
    func createCommunity(_ privateKey: String, _ collectionName: String, _ collectionSymbol: String) async throws -> GetCommunityResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community")
        
        let requestPayload = CreateCommunityRequest(
            collectionName: collectionName,
            collectionSymbol: collectionSymbol,
            privateKey: privateKey
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(GetCommunityResponse.self)
            .result
            .get()
        
        return response
    }
    
    func registerInCommunity(_ nftID: String, _ nftOwner: String, _ contractID: String, _ secretKey: String, _ privateKey: String) async throws -> RegisterInCommunityResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community/register")
        
        let identity = IdentityNewIdentity(secretKey, nil, nil)!
        
        let requestPayload = RegisterInCommunityRequest(
            nftID: nftID,
            nftOwner: nftOwner,
            contractID: contractID,
            bjjPublicKey: identity.getPublicKeyHex(),
            privateKey: privateKey
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(RegisterInCommunityResponse.self)
            .result
            .get()
        
        return response
    }
    
    func mintNft(_ contractAddress: String, _ privateKey: String, _ participantAddress: String) async throws -> SimpleResponse {
        let requestUrl = url.appendingPathComponent("/integrations/community-indexer/v1/community/add-participant")
        
        let reqeustPayload = MintNftRequest(
            contractAddress: contractAddress,
            privateKey: privateKey,
            participantAddress: participantAddress
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: reqeustPayload, encoder: JSONParameterEncoder.default)
            .serializingDecodable(SimpleResponse.self)
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
    let privateKey: String
    
    enum CodingKeys: String, CodingKey {
        case collectionName = "collection_name"
        case collectionSymbol = "collection_symbol"
        case privateKey = "private_key"
    }
}

struct RegisterInCommunityRequest: Codable {
    let nftID: String
    let nftOwner, contractID, bjjPublicKey, privateKey: String

    enum CodingKeys: String, CodingKey {
        case nftID = "nft_id"
        case nftOwner = "nft_owner"
        case contractID = "contract_id"
        case bjjPublicKey = "bjj_public_key"
        case privateKey = "private_key"
    }
}

struct RegisterInCommunityResponse: Codable {
    let id: String
    let status: RegisterInCommunityStatus
}

enum RegisterInCommunityStatus: String, Codable {
    case registered = "registered"
    case processing = "processing"
    case failedRegister = "failed-register"
}

struct SimpleResponse: Codable {
    let id: String
}

struct MintNftRequest: Codable {
    let contractAddress, privateKey, participantAddress: String

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case privateKey = "private_key"
        case participantAddress = "participant_address"
    }
}
