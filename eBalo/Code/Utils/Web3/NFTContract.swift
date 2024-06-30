import Foundation

import Web3
import Web3PromiseKit
import Web3ContractABI

class NFTContract {
    let web3: Web3
    let contract: DynamicContract
    
    init(_ addressRaw: String) throws {
        let contractAddress = try EthereumAddress(hex: addressRaw, eip55: false)
        
        self.web3 = Web3(rpcURL: Config.shared.general.ethRpcUrl.absoluteString)
        
        self.contract = try web3.eth.Contract(
            json: EthAbi.erc721Abi,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func getTokensByOwner(_ ownerAddress: String) async throws -> [BigUInt] {
        let owner = try EthereumAddress(hex: ownerAddress, eip55: false)
        
        let method = contract["getTokensByOwner"]!
        
        let response = try method(owner).call().wait()
        
        guard let responseRaw = response["tokens_"] as? [BigUInt] else { throw "Proof is not hex" }
        
        return responseRaw
    }
}
