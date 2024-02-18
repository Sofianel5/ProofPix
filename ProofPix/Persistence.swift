//
//  Persistence.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/16/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ProofPix")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveURL(url: String) {
        let context = container.viewContext
        let pic = ProvedPic(context: context)
        pic.url = url
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func fetchURLs() -> [String] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ProvedPic> = ProvedPic.fetchRequest()
        do {
            let images = try context.fetch(fetchRequest)
            return images.map { $0.url! }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
