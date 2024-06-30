import SwiftUI

class EthAbi {
    static let chatAbi = NSDataAsset(name: "ChatAbi")?.data ?? Data()
    
    static let erc721Abi = NSDataAsset(name: "Erc721Abi")?.data ?? Data()
}
