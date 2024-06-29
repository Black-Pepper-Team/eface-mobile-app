//
//  SimpleStorage.swift
//  eBalo
//
//  Created by Ivan Lele on 22.03.2024.
//

import Foundation

class SimpleStorage {
    static let credentialsKey = "DistirbutedLab.eBalo.credentials"
    static let secretKeyKey = "DistirbutedLab.eBalo.secretKey"
    static let userIDKey = "DistirbutedLab.eBalo.userID"
    static let contactsKey = "DistirbutedLab.eBalo.contacts"
    
    static func loadCredentials() -> [Credential] {
        guard let json = UserDefaults.standard.data(forKey: Self.credentialsKey) else {
            return []
        }
        
        guard let credentials = try? JSONDecoder().decode([Credential].self, from: json) else {
            print("failed to load crededntials: invalid credentials")
            
            return []
        }
        
        return credentials
    }
    
    static func saveCredentials(_ credentials: [Credential]) {
        let jsonData = try! JSONEncoder().encode(credentials)
        
        UserDefaults.standard.set(jsonData, forKey: Self.credentialsKey)
    }
    
    static func eraceCredentials() {
        UserDefaults.standard.removeObject(forKey: Self.credentialsKey)
    }
    
    static func loadSecretKey() -> String? {
        UserDefaults.standard.string(forKey: Self.secretKeyKey)
    }
    
    static func saveSecretKey(_ secretKey: String) {
        UserDefaults.standard.set(secretKey, forKey: Self.secretKeyKey)
    }
    
    static func eraceSecretKey() {
        UserDefaults.standard.removeObject(forKey: Self.secretKeyKey)
    }
    
    static func loadUserId() -> String? {
        UserDefaults.standard.string(forKey: Self.userIDKey)
    }
    
    static func saveUserId(_ secretKey: String) {
        UserDefaults.standard.set(secretKey, forKey: Self.userIDKey)
    }
    
    static func eraceUserId() {
        UserDefaults.standard.removeObject(forKey: Self.userIDKey)
    }
    
    static func loadContacts() -> [Contact] {
        guard let json = UserDefaults.standard.data(forKey: Self.contactsKey) else {
            return []
        }
        
        guard let contacts = try? JSONDecoder().decode([Contact].self, from: json) else {
            print("failed to load contacts: invalid contacts")
            
            return []
        }
        
        return contacts
    }
    
    static func saveContacts(_ contacts: [Contact]) {
        let jsonData = try! JSONEncoder().encode(contacts)
        
        UserDefaults.standard.set(jsonData, forKey: Self.contactsKey)
    }
}
