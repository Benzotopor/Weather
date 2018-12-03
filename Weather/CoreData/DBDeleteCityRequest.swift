//
//  DBCityDeleteRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 01.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import CoreData

protocol StorageDeleteCityRequestProtocol: StorageRequestProtocol {
    init(city: City)
}

class DBDeleteCityRequest: DBBaseRequest, StorageDeleteCityRequestProtocol {
    
    let city: City
    
    required init(city: City) {
        self.city = city
        super.init()
    }
    
    override func execute() {
        
        let context = db.getNewContext()
        
        context.perform {
            
            autoreleasepool {
                
                let request: NSFetchRequest<DBRecordCity> = DBRecordCity.fetchRequest()
                request.predicate = NSPredicate(format: "id == \(self.city.id)")
                
                do {
                    
                    let result = try context.fetch(request)
                    
                    if let record = result.first {
                        context.delete(record)
                        try context.save()
                        self.db.saveChanges()
                    }
                    
                } catch {
                    fatalError("error in fetching : \(error)")
                }
            }
            
            context.reset()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.completionHandler?()
            }
        }
    }
}
