//
//  ProofPixApp.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/16/24.
//

import SwiftUI

@main
struct ProofPixApp: App {
    let persistenceController = PersistenceController.shared
    let secureEnclaveManager = SecureEnclaveManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(){
                    SecureEnclaveManager.shared.generateAsymmetricKeyPairIfNeeded()
                }
        }
    }
}
