//
//  EthersacnResp.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import Foundation


// MARK: - EthersacnResp
struct EthersacnResp: Codable {
    let status, message: String
    let result: [EthersacnRespResult]
}

// MARK: - Result
struct EthersacnRespResult: Codable {
    let blockNumber, timeStamp, hash, nonce: String
    let blockHash, transactionIndex: String
    let from: String
    let to, value, gas, gasPrice: String
    let isError, txreceiptStatus: String
    let input: String
    let contractAddress, cumulativeGasUsed, gasUsed, confirmations: String
    let methodID: String
    let functionName: String

    enum CodingKeys: String, CodingKey {
        case blockNumber, timeStamp, hash, nonce, blockHash, transactionIndex, from, to, value, gas, gasPrice, isError
        case txreceiptStatus = "txreceipt_status"
        case input, contractAddress, cumulativeGasUsed, gasUsed, confirmations
        case methodID = "methodId"
        case functionName
    }
}

// MARK: - EthersacnAccResp
struct EthersacnAccResp: Codable {
    let status, message, result: String
}

struct DimaRequest: Codable {
    let data: DimaRequestDataClass
}

// MARK: - DataClass
struct DimaRequestDataClass: Codable {
    let id: Int
    let type: String
    let attributes: DimaRequestAttributes
}

// MARK: - Attributes
struct DimaRequestAttributes: Codable {
    let did, userID, publicKey, metadata: String
    let image: String

    enum CodingKeys: String, CodingKey {
        case did
        case userID = "user_id"
        case publicKey = "public_key"
        case metadata, image
    }
}

// MARK: - DimaResponse
struct DimaResponse: Codable {
    let data: DimaResponseDataClass
}

// MARK: - DataClass
struct DimaResponseDataClass: Codable {
    let id: Int
    let type: String
    let attributes: DimaResponseAttributes
}

// MARK: - Attributes
struct DimaResponseAttributes: Codable {
    let embedding: String
    let claimID: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case embedding
        case claimID = "claim_id"
        case userId = "user_id"
    }
}

struct MishaRequest: Codable {
    let data: MishaRequestDataClass
}

// MARK: - DataClass
struct MishaRequestDataClass: Codable {
    let id: Int
    let type: String
    let attributes: MishaRequestAttributes
}

// MARK: - Attributes
struct MishaRequestAttributes: Codable {
    let did, userID, publicKey, metadata: String
    let voice: String

    enum CodingKeys: String, CodingKey {
        case did
        case userID = "user_id"
        case publicKey = "public_key"
        case metadata, voice
    }
}

// MARK: - DimaResponse
struct MishaResponse: Codable {
    let data: MishaResponseDataClass
}

// MARK: - DataClass
struct MishaResponseDataClass: Codable {
    let id: Int
    let type: String
    let attributes: MishaResponseAttributes
}

// MARK: - Attributes
struct MishaResponseAttributes: Codable {
    let embedding: String
    let claimID: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case embedding
        case claimID = "claim_id"
        case userId = "user_id"
    }
}

// MARK: - CreateIdentityRequest
struct CreateIdentityRequest: Codable {
    let data: CreateIdentityRequestDataClass
}

// MARK: - CreateIdentityRequestDataClass
struct CreateIdentityRequestDataClass: Codable {
    let id: String
    let documentSod: DocumentSod
    let zkproof: Zkproof
    let userId: String
    let userAddress: String

    enum CodingKeys: String, CodingKey {
        case id
        case documentSod = "document_sod"
        case zkproof
        case userId = "user_id"
        case userAddress = "user_address"
    }
}

// MARK: - DocumentSod
struct DocumentSod: Codable {
    let signedAttributes, algorithm, signature, pemFile: String
    let encapsulatedContent: String

    enum CodingKeys: String, CodingKey {
        case signedAttributes = "signed_attributes"
        case algorithm, signature
        case pemFile = "pem_file"
        case encapsulatedContent = "encapsulated_content"
    }
}

// MARK: - Zkproof
struct Zkproof: Codable {
    let proof: Proof
    let pubSignals: [String]

    enum CodingKeys: String, CodingKey {
        case proof
        case pubSignals = "pub_signals"
    }
}

// MARK: - Proof
struct Proof: Codable {
    let piA: [String]
    let piB: [[String]]
    let piC: [String]
    let proofProtocol: String

    enum CodingKeys: String, CodingKey {
        case piA = "pi_a"
        case piB = "pi_b"
        case piC = "pi_c"
        case proofProtocol = "protocol"
    }
}

// MARK: - CreateIdentityResponse
struct CreateIdentityResponse: Codable {
    let data: CreateIdentityResponseDataClass
}

// MARK: - CreateIdentityResponseDataClass
struct CreateIdentityResponseDataClass: Codable {
    let id, type: String
    let attributes: CreateIdentityResponseDataClassAttributes
}

// MARK: - Attributes
struct CreateIdentityResponseDataClassAttributes: Codable {
    let claimID, issuerDid: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case claimID = "claim_id"
        case issuerDid = "issuer_did"
        case userId = "user_id"
    }
}

struct PassportInput: Codable {
    let inKey: [UInt8]
    let currDateYear: Int
    let currDateMonth: Int
    let currDateDay: Int
    let credValidYear: Int
    let credValidMonth: Int
    let credValidDay: Int
    let ageLowerbound: Int
    
    private enum CodingKeys: String, CodingKey {
        case inKey = "in", currDateYear, currDateMonth, currDateDay, credValidYear, credValidMonth, credValidDay, ageLowerbound
    }
}

// MARK: - DimaEbaloResponse
struct DimaEbaloResponse: Codable {
    let data: DimaEbaloResponseDataClass
}

// MARK: - DataClass
struct DimaEbaloResponseDataClass: Codable {
    let id: Int
    let type: String
    let attributes: DimaEbaloResponseAttributes
}

// MARK: - Attributes
struct DimaEbaloResponseAttributes: Codable {
    let image: String
}

struct DimaEbaloRequest: Codable {
    let data: DimaEbaloRequestDataClass
}

// MARK: - DataClass
struct DimaEbaloRequestDataClass: Codable {
    let attributes: DimaEbaloRequestAttributes
    let id: Int
    let type: String
}

// MARK: - Attributes
struct DimaEbaloRequestAttributes: Codable {
    let metadata, publicKey, userId: String

    enum CodingKeys: String, CodingKey {
        case metadata
        case publicKey = "public_key"
        case userId = "user_id"
    }
}

struct PresentResponse: Codable {
    let EBT: String
    
    enum CodingKeys: String, CodingKey {
        case EBT = "EBT"
    }
}
