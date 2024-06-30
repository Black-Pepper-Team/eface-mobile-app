import Foundation

import Web3
import Web3PromiseKit
import Web3ContractABI

class ChatContract {
    static let shared = try! ChatContract()
    
    let web3: Web3
    let contract: DynamicContract
    
    init() throws {
        let contractEthereumAddress = try EthereumAddress(hex: Config.shared.general.chatAddress, eip55: false)
        
        self.web3 = Web3(rpcURL: Config.shared.general.ethRpcUrl.absoluteString)
        
        self.contract = try web3.eth.Contract(
            json: EthAbi.chatAbi,
            abiKey: nil,
            address: contractEthereumAddress
        )
    }
    
    func listMessages(_ nfcAddressRaw: String, _ offset: Int, _ limit: Int) async throws -> [ChatMessage] {
        let nftAddress = try EthereumAddress(hex: nfcAddressRaw, eip55: false)
        
        let method = contract["listMessages"]!
        
        let response = try method(nftAddress, offset, limit).call().wait()
        
        var result: [ChatMessage] = []
        
        guard let responseRaw = response[""] as? [[String: Any]] else { throw "Proof is not hex" }
        for raw in responseRaw {
            guard let message = raw["message"] as? String else { throw "Proof is not hex" }
            guard let timestampRaw = raw["timestamp"] as? BigUInt else { throw "Proof is not hex" }
            
            let timestamp = Date(timeIntervalSince1970: TimeInterval(timestampRaw))
            
            result.append(
                ChatMessage(
                    message: message,
                    timestamp: timestamp
                )
            )
        }
        
        return result
    }
    
    func getMessagesCount(_ nftAddressRaw: String) async throws -> BigUInt {
        let nftAddress = try EthereumAddress(hex: nftAddressRaw, eip55: false)
        
        let method = contract["getMessagesCount"]!
        
        let response = try method(nftAddress).call().wait()
        
        guard let responseRaw = response[""] as? BigUInt else { throw "Proof is not hex" }
        
        return responseRaw
    }
}

struct ChatMessage {
    let message: String
    let timestamp: Date
}
