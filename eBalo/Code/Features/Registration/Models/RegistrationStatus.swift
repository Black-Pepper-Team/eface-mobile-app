//
//  RegistrationStatus.swift
//  eBalo
//
//  Created by Ivan Lele on 23.03.2024.
//

import Foundation
import Identity

class RegistrationStatus: ObservableObject {
    @Published var isCreatingNew = false
    
    @Published var isPassPassed = false
    @Published var isFacePassed = false
    @Published var isVoicePassed = false
    
    @Published var isPassPassing = false
    @Published var isFacePassing = false
    @Published var isVoicePassing = false
    
    @Published var isPassRevoced = false
    @Published var isFaceRevoced = false
    @Published var isVoiceRevoced = false
    
    @Published var identity: IdentityIdentity!
    
    @Published var faceClaimId = ""
    @Published var voiceClaimId = ""
    @Published var passClaimId = ""
    
    func start() {
        isCreatingNew = true
        identity = IdentityNewIdentity(SimpleStorage.loadSecretKey() ?? "", nil, nil)!
    }
    
    func clean() {
        isPassPassed = false
        isFacePassed = false
        isVoicePassed = false
        
        isPassPassing = false
        isFacePassing = false
        isVoicePassing = false
        
        isCreatingNew = false
        
        identity = IdentityNewIdentity(SimpleStorage.loadSecretKey() ?? "", nil, nil)!
        
        faceClaimId = ""
        voiceClaimId = ""
        passClaimId = ""
        
        isPassRevoced = false
        isFaceRevoced = false
        isVoiceRevoced = false
    }
}
