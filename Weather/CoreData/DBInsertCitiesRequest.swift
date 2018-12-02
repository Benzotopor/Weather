//
//  DBInsertCitiesRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 02.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

protocol StorageInsertCitiesRequest: StorageRequestProtocol {
    init(cities: [City])
}

class DBInsertCitiesRequest: DBBaseRequest, StorageInsertCitiesRequest {
    
    let cities: [City]
    
    required init(cities: [City]) {
        self.cities = cities
        super.init()
    }
    
    override func execute() {
        
        let context = db.getNewContext()
        
        context.perform {
            autoreleasepool {
                
                for city in self.cities {
                    
                    let entity = DBRecordCity(context: context)
                    
                    entity.id           = Int64(city.id)
                    entity.name         = city.name
                    entity.latitude     = city.latitude
                    entity.longitude    = city.longitude
                    entity.temperature  = city.temperature
                    entity.icon         = city.icon
                }
            }
            
            do {
                try context.save()
            } catch {
                fatalError("context saving error : \(error)")
            }
            
            context.reset()
            
            DispatchQueue.global(qos: .userInitiated).async { 
                self.completionHandler?()
            }
        }
    }
}
