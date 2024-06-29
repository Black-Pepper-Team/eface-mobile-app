//
//  Config.swift
//  eBalo
//
//  Created by Ivan Lele on 18.03.2024.
//

import Foundation

class Config {
    static let shared = try! Config()
    
    let general: General
    
    init() throws {
        self.general = try General()
    }
}

extension Config {
    class General {
        let privacyPolicyURL: URL
        let termsOfUseURL: URL
        let chatApiURL: URL
        
        init() throws {
            guard
                var privacyPolicyURLRaw = Bundle.main.object(forInfoDictionaryKey: "PRIVACY_POLICY_URL") as? String,
                var termsOfUseURLRaw = Bundle.main.object(forInfoDictionaryKey: "TERMS_OF_USE_URL") as? String,
                var chatApiURLRaw = Bundle.main.object(forInfoDictionaryKey: "CHAT_API_URL") as? String
            else {
                throw "some config value aren't initialized"
            }
            
            privacyPolicyURLRaw = String(privacyPolicyURLRaw.dropFirst())
            privacyPolicyURLRaw = String(privacyPolicyURLRaw.dropLast())
            
            termsOfUseURLRaw = String(termsOfUseURLRaw.dropFirst())
            termsOfUseURLRaw = String(termsOfUseURLRaw.dropLast())
            
            chatApiURLRaw = String(chatApiURLRaw.dropFirst().dropLast())
            
            guard
                let privacyPolicyURL = URL(string: privacyPolicyURLRaw),
                let termsOfUseURL = URL(string: termsOfUseURLRaw),
                let chatApiURL = URL(string: chatApiURLRaw)
            else {
                throw "PRIVACY_POLICY_URL and/or TERMS_OF_USE_URL aren't URLs"
            }
            
            self.privacyPolicyURL = privacyPolicyURL
            self.termsOfUseURL = termsOfUseURL
            self.chatApiURL = chatApiURL
        }
    }
}
