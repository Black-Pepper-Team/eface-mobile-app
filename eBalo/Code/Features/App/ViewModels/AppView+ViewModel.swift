//
//  AppView+ViewModel.swift
//  eBalo
//
//  Created by Ivan Lele on 19.03.2024.
//

import SwiftUI
import Web3
import Web3ContractABI
import Web3PromiseKit
import Alamofire
import Identity
import AVFoundation
import NFCPassportReader

extension AppView {
    class ViewModel: ObservableObject {
        let config: Config
        
        @Published var isIntroPassed = false
        
        @Published var credentials = SimpleStorage.loadCredentials()
        
        @Published var secretKey = SimpleStorage.loadSecretKey()
        
        @Published var historyEntries: [EbaloHistoryEntry] = []
        
        @Published var contacts: [Contact] = []
        
        @Published var fetchHistoryCancelable: Task<(), Never>? = nil
        
        @Published var balance = 0
        
        init() {
            do {
                config = try Config()
            } catch let error {
                fatalError("appview model error: \(error)")
            }
            
            Task { @MainActor in
                self.contacts = SimpleStorage.loadContacts()
            }
        }
        
        func fetchHistory() {
            print("start fetching history")
            if secretKey == nil {
                print("not key return")
                
                return
            }
            
            if fetchHistoryCancelable != nil {
                print("histrory fetching return")
                
                return
            }
            
            guard let privKey = try? EthereumPrivateKey(hexPrivateKey: secretKey!) else {
                print("bad private key")
                
                return
            }
            
            let pubKey = privKey.publicKey.address
            
            let task = Task { @MainActor in
                do {
                    defer {
                        fetchHistoryCancelable = nil
                    }
                    
                    var requestUrl = "https://api-sepolia.etherscan.io/api"
                    requestUrl += "?module=account"
                    requestUrl += "&action=txlist"
                    requestUrl += "&address=\(pubKey.hex(eip55: false))"
                    requestUrl += "&startblock=0"
                    requestUrl += "&page=1"
                    requestUrl += "&offset=50"
                    requestUrl += "&sort=desc"
                    requestUrl += "&apikey=2TIRBQ6YTX2PRSHHJFG62G5AYJ4QM717TK"
                    
                    let response = try await AF.request(requestUrl)
                        .serializingDecodable(EthersacnResp.self)
                        .result
                        .get()
                    
                    self.historyEntries = []
                    
                    for tx in response.result {
                        addTxToHistory(tx, pubKey)
                    }
                    
                } catch let error {
                    print(error)
                }
            }
            
            fetchHistoryCancelable = task
        }
        
        func fetchBalance() {
            print("fetch balance")
            
            if secretKey == nil {
                return
            }
            
            Task { @MainActor in
                guard let pk = try? EthereumPrivateKey(hexPrivateKey: secretKey!) else {
                    return
                }
                
                let addr = pk.address.hex(eip55: false)
                
                var url = "https://api-sepolia.etherscan.io/api"
                url += "?module=account"
                url += "&action=balance"
                url += "&address=\(addr)"
                url += "&tag=latest"
                url += "&apikey=2TIRBQ6YTX2PRSHHJFG62G5AYJ4QM717TK"
                
                let response = try await AF.request(url)
                    .serializingDecodable(EthersacnAccResp.self)
                    .result
                    .get()
                
                self.balance = Int(response.result) ?? 0
            }
        }
        
        func testDima(_ image: UIImage, _ registrationStatus: RegistrationStatus, _ userNickName: String) async throws -> String {
            var nickName = userNickName
            
            if nickName.isEmpty {
                nickName = "identity"
            }
            
            let encodedImage = image.rotate(radians: 0)!.jpegData(compressionQuality: 1)!.base64EncodedString()
            
            let secretKey = try EthereumPrivateKey(hexPrivateKey: secretKey!)
            
            let requestAttr = DimaRequestAttributes(
                did: registrationStatus.identity.getDID(),
                userID: registrationStatus.identity.usedId,
                publicKey: secretKey.address.hex(eip55: false),
                metadata: nickName,
                image: encodedImage
            )
            
            let requestBody = DimaRequest(data: DimaRequestDataClass(id: 1, type: "EXTRACT", attributes: requestAttr))
            
            let request = "https://c2b8-185-46-149-146.ngrok-free.app/integrations/face-extractor-svc/extract"
            
            let responseRaw = await AF.request(request, method: .post, parameters: requestBody, encoder: JSONParameterEncoder())
                .serializingDecodable(DimaResponse.self)
                .response
            
            if responseRaw.response?.statusCode == 403 {
                throw "ERRWRONGEBALO"
            }
            
            let response = try responseRaw.result.get()
            
            if let userId = response.data.attributes.userId {
                if userId != registrationStatus.identity.usedId {
                    registrationStatus.identity.setOldUsedId(userId)
                }
                
                registrationStatus.isFaceRevoced = true
            }
            
            return response.data.attributes.claimID
        }
        
        func testMisha(_ recordingURL: URL, _ registrationStatus: RegistrationStatus, _ userNickName: String) async throws -> String {
            var nickName = userNickName
            
            if nickName.isEmpty {
                nickName = "identity"
            }
            
            let encodedVoice = try Data(contentsOf: recordingURL).base64EncodedString()
            
            let requestAttr = MishaRequestAttributes(
                did: registrationStatus.identity.getDID(),
                userID: registrationStatus.identity.usedId,
                publicKey: registrationStatus.identity.getPublicKeyHex(),
                metadata: nickName,
                voice: encodedVoice
            )
            
            let requestBody = MishaRequest(data: MishaRequestDataClass(id: 1, type: "EXTRACT", attributes: requestAttr))
            
            let request = "https://b2c7-62-80-164-77.ngrok-free.app/integrations/face-extractor-svc/extract"
            
            let responseRaw = await AF.request(request, method: .post, parameters: requestBody, encoder: JSONParameterEncoder())
                .serializingDecodable(MishaResponse.self)
                .response
            
            if responseRaw.response?.statusCode == 403 {
                throw "ERRWRONGVOICE"
            }
            
            let response = try responseRaw.result.get()
            
            if let userId = response.data.attributes.userId {
                if userId != registrationStatus.identity.usedId {
                    registrationStatus.identity.setOldUsedId(userId)
                }
                
                registrationStatus.isVoiceRevoced = true
            }
            
            return response.data.attributes.claimID
        }
        
        func testAnton(_ model: NFCPassportModel, _ registrationStatus: RegistrationStatus, _ userNickName: String) async throws -> String {
            var nickName = userNickName
            
            if nickName.isEmpty {
                nickName = "identity"
            }
            
            let requestURL = "https://33f1-62-80-164-77.ngrok-free.app/integrations/identity-provider-service/v1/create-identity"
            
            let inputs = try preparePayloadForCreateIdentity(model, registrationStatus.identity, nickName)
            
            var request = URLRequest(url: URL(string: requestURL)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = inputs
            
            let responseRaw = await AF.request(request)
                .serializingDecodable(CreateIdentityResponse.self)
                .response
            
            if responseRaw.response?.statusCode == 429 {
                throw "ErrorTooManyRequest"
            }
            
            let response = try responseRaw.result.get()
            
            if let userId = response.data.attributes.userId {
                if userId != registrationStatus.identity.usedId {
                    registrationStatus.identity.setOldUsedId(userId)
                }
                
                registrationStatus.isPassRevoced = true
            }
            
            return response.data.attributes.claimID
        }
        
        func registerUser(_ registrationStatus: RegistrationStatus) async throws -> String {
            let secretKey = try EthereumPrivateKey(hexPrivateKey: secretKey!)
            
            let web3 = Web3(rpcURL: "https://rpc.qtestnet.org")
            let contractAddress = EthereumAddress(hexString: "0xdf8D167190287B9B97749360093E879539EA3429")
            
            let calldata = try registrationStatus.identity.getRegisterCallData()
            
            let gasPrice = try web3.eth.gasPrice().wait()
            
            let call = EthereumCall(
                from: secretKey.address,
                to: contractAddress!,
                gasPrice: gasPrice,
                value: EthereumQuantity(0),
                data: try EthereumData(calldata)
            )
            
            let gasLimit = try web3.eth.estimateGas(call: call).wait()
            
            let nonce = try web3.eth.getTransactionCount(address: secretKey.address, block: .latest).wait()
            
            let tx = EthereumTransaction(
                nonce: nonce,
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                from: secretKey.address,
                to: contractAddress!,
                value: EthereumQuantity(0),
                data: try! EthereumData(calldata)
            )
            
            let signedTx = try tx.sign(with: secretKey, chainId: 35443)
            
            return try web3.eth.sendRawTransaction(transaction: signedTx).wait().hex()
        }
        
        func getAddressByUserId(_ userId: String) async throws-> String {
            let web3 = Web3(rpcURL: "https://rpc.qtestnet.org/")
            
            let abi = NSDataAsset(name: "BioRegistry")!.data
            
            let contractAddress = try? EthereumAddress(hex: "0xdecBc08607b58e44C5b3133435aF8dDc16224dC1", eip55: false)
            
            let contract = try web3.eth.Contract(json: abi, abiKey: nil, address: contractAddress)
            
            let outouts = try contract["getUserAccountByUUID"]!(userId).call().wait()[""] as! EthereumAddress
            
            return outouts.hex(eip55: true)
        }
        
        func addTxToHistory(_ tx: EthersacnRespResult, _ pk: EthereumAddress) {
            var isReceiving = true
            if tx.from == pk.hex(eip55: false) {
                isReceiving = false
            }
            
            let value = Int(tx.value) ?? 0
            if value == 0 {
                return
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(Int(tx.timeStamp) ?? 0))
            
            let entry = EbaloHistoryEntry(
                txId: tx.hash,
                at: date,
                value: value,
                isReceiving: isReceiving
            )
            
            historyEntries.append(entry)
        }
        
        func preparePayloadForCreateIdentity(_ model: NFCPassportModel, _ identity: IdentityIdentity, _ nickName: String) throws -> Data {
            guard
                let sod = model.getDataGroup(.SOD) as? SOD,
                let dg1 = model.getDataGroup(.DG1)
            else {
                throw "Invalid data groups"
            }
            
            let certs = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.body))
            
            guard let cert = certs.first else {
                throw "Certificates were not found"
            }
            
            var signatureAlgorithm = try sod.getSignatureAlgorithm()
            if signatureAlgorithm == "sha256WithRSAEncryption" {
                signatureAlgorithm = "SHA256withRSA"
            }
            
            let signedAttributes = try sod.getSignedAttributes().hexStringEncoded()
            let signature = try sod.getSignature().hexStringEncoded()
            let encapsulatedContent = try sod.getEncapsulatedContent().hexStringEncoded()
            
            let digestAlgorithm = try sod.getEncapsulatedContentDigestAlgorithm()
            
            let inputs = try prepareInputs(Data(dg1.data))
            
            let (proofRaw, pubSignalsRaw) = try generatePassportVerification(inputs, digestAlgorithm: digestAlgorithm)
            
            let proof = try JSONDecoder().decode(Proof.self, from: proofRaw)
            let pubSignals = try JSONDecoder().decode([String].self, from: pubSignalsRaw)
            
            let zkproof = Zkproof(
                proof: proof,
                pubSignals: pubSignals
            )
                    
            let documentSod = DocumentSod(
                signedAttributes: signedAttributes,
                algorithm: signatureAlgorithm,
                signature: signature,
                pemFile: cert.certToPEM(),
                encapsulatedContent: encapsulatedContent
            )
            
            let userAddress = try EthereumPrivateKey(hexPrivateKey: secretKey!)
            
            let request = CreateIdentityRequest(
                data: CreateIdentityRequestDataClass(
                    id: identity.getDID(),
                    documentSod: documentSod,
                    zkproof: zkproof,
                    userId: identity.usedId,
                    userAddress: userAddress.address.hex(eip55: false)
                )
            )
        
            return try JSONEncoder().encode(request)
        }
        
        func getEbalo(_ image: UIImage) async throws -> DimaEbaloRequestAttributes {
            let encodedImage = image.rotate(radians: 0)!.jpegData(compressionQuality: 1)!.base64EncodedString()
            
            let request = DimaEbaloResponse(data: DimaEbaloResponseDataClass(id: 1, type: "pk", attributes: DimaEbaloResponseAttributes(image: encodedImage)))
            
            let reqeustURL = "https://c2b8-185-46-149-146.ngrok-free.app/integrations/face-extractor-svc/pk-from-image"
            
            let responseRaw = await AF.request(reqeustURL, method: .post, parameters: request, encoder: JSONParameterEncoder())
                .serializingDecodable(DimaEbaloRequest.self)
                .response
            
            if responseRaw.response?.statusCode == 403 {
                throw "ERROREBALONOTFOUND"
            }
            
            let response = try responseRaw.result.get()
            
            return response.data.attributes
        }
        
        func prepareInputs(_ dg1: Data) throws -> Data {
            let currentYear = Calendar.current.component(.year, from: Date())-2000
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentDay = Calendar.current.component(.day, from: Date())
            
            let inputs = PassportInput(
                inKey: dg1.toCircuitInput(),
                currDateYear: currentYear,
                currDateMonth: currentMonth,
                currDateDay: currentDay,
                credValidYear: currentYear+1,
                credValidMonth: currentMonth,
                credValidDay: currentDay,
                ageLowerbound: 18
            )
            
            return try JSONEncoder().encode(inputs)
        }
        
        func createCred(_ userId: String) {
            SimpleStorage.saveUserId(userId)
            
            let cred = Credential(id: userId, createdAt: Date())
            
            SimpleStorage.saveCredentials([cred])
            
            credentials = [cred]
        }
        
        func eraceCreds() {
            SimpleStorage.eraceUserId()
            SimpleStorage.eraceCredentials()
            credentials = []
        }
        
        func transfer(_ identity: IdentityIdentity, token: String, amount: Int, to: String, contract: String) async throws -> String {
            let secretKey = try EthereumPrivateKey(hexPrivateKey: secretKey!)
            
            let web3 = Web3(rpcURL: "https://rpc.qtestnet.org")
            let contractAddress = EthereumAddress(hexString: contract)
            
            let calldata = try identity.getTransferCalldata(token, amount: amount.description, to: to)
            
            let gasPrice = try web3.eth.gasPrice().wait()
            
            let call = EthereumCall(
                from: secretKey.address,
                to: contractAddress!,
                gasPrice: gasPrice,
                value: EthereumQuantity(0),
                data: try EthereumData(calldata)
            )
            
            let gasLimit = try web3.eth.estimateGas(call: call).wait()
            
            let nonce = try web3.eth.getTransactionCount(address: secretKey.address, block: .latest).wait()
            
            let tx = EthereumTransaction(
                nonce: nonce,
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                from: secretKey.address,
                to: contractAddress!,
                value: EthereumQuantity(0),
                data: try! EthereumData(calldata)
            )
            
            let signedTx = try tx.sign(with: secretKey, chainId: 35443)
            
            return try web3.eth.sendRawTransaction(transaction: signedTx).wait().hex()
        }
    }
}

func generatePassportVerification(_ inputs: Data, digestAlgorithm: String) throws -> (proof: Data, pubSignals: Data) {
    if digestAlgorithm == "sha256" {
        let witness = try ZKUtils.calcWtnsPassportVerificationSHA256(inputsJson: inputs)
        let (proof, pubSignals) = try ZKUtils.groth16PassportVerificationSHA256Prover(wtns: witness)
        
        return (proof, pubSignals)
    }
    
    if digestAlgorithm == "sha1" {
        let witness = try! ZKUtils.calcWtnsPassportVerificationSHA256(inputsJson: inputs)
        let (proof, pubSignals) = try! ZKUtils.groth16PassportVerificationSHA256Prover(wtns: witness)
        
        return (proof, pubSignals)
    }
    
    throw "Unsupported digest algorithm"
}

extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    func hexStringEncoded() -> String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }
}

extension Data {
    func toCircuitInput() -> [UInt8] {
        var circuitInput = Data()
        
        for byte in self {
            circuitInput.append(contentsOf: byte.bits())
        }
        
        return [UInt8](circuitInput)
    }
}

extension UInt8 {
    func bits() -> [UInt8] {
        var byte = self
        var bits = [UInt8](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = 1
            }

            byte >>= 1
        }

        return bits.reversed()
    }
}
