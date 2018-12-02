//
//  DataBase.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 30.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStorage {
    
    private let privateManagedObjectContext: NSManagedObjectContext
    private let persistentContainer: NSPersistentStoreCoordinator
    
    static var shared: CoreDataStorage {
        return  _sharedInstance!
    }
    
    static func initialize(completionClosure: @escaping () -> ()) {
        _sharedInstance = CoreDataStorage(completionClosure: completionClosure)
    }
    
    private static var _sharedInstance: CoreDataStorage!
    
    private init(completionClosure: @escaping () -> ()) {
        
        guard let modelURL = Bundle.main.url(forResource: "DBModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        persistentContainer = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        privateManagedObjectContext.persistentStoreCoordinator = self.persistentContainer
        privateManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storeURL = docURL.appendingPathComponent("db.sqlite")
            do {
                try self.persistentContainer.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                fatalError("Persistent store coordinator error : \(error)")
            }
        }
    }
    
    func getNewContext() -> NSManagedObjectContext {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = privateManagedObjectContext
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        moc.automaticallyMergesChangesFromParent = true
        
        return moc
    }
    
    internal func savePrivateContext(completionHandler: (() -> Void)? = nil) {
        privateManagedObjectContext.perform {
            do {
                try self.privateManagedObjectContext.save()
            } catch {
                fatalError("private context save error : \(error)")
            }
            completionHandler?()
        }
    }
}
