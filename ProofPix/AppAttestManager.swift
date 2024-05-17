//
//  AppAttestManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 5/17/24.
//

import Foundation
import DeviceCheck

class AppAttestManager {
    
    private var keyId: String?;
    private var attestation: Data?;
    private let service = DCAppAttestService.shared
    
    init() {
        if service.isSupported {
            // Perform key generation and attestation.
            service.generateKey { keyId, error in
                guard error == nil else {
                    self.keyId = nil;
                    return
                }
                self.keyId = keyId!;
            }
        }
    }
    
    func attestKey(hash: Data) {
        if let keyId {
            service.attestKey(keyId, clientDataHash: hash) { attestation, error in
                guard error == nil else { return }
                self.attestation = attestation
            }
        }
    }
}
