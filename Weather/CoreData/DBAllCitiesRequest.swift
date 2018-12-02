//
//  DBCachedCitiesRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 01.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import CoreData

protocol StorageAllCitiesRequestProtocol: StorageRequestProtocol {
    var cachedCities: [City] {get}
    init()
}

class DBAllCitiesRequest: DBBaseRequest, StorageAllCitiesRequestProtocol {
    
    required override init() {
        super.init()
    }
    
    var cachedCities: [City] = []
    
    override func execute() {
        
        cachedCities.removeAll()
        
        let context = db.getNewContext()
        
        context.perform {
            autoreleasepool {
                
                let fetchRequest : NSFetchRequest<DBRecordCity> = DBRecordCity.fetchRequest()
                fetchRequest.returnsObjectsAsFaults = false
                do {
                    let result = try context.fetch(fetchRequest)
                    
                    for record in result {
                        let city = City(id: Int(record.id),
                                        name: record.name!,
                                        latitude: record.latitude,
                                        longitude: record.longitude,
                                        temperature: record.temperature,
                                        icon: record.icon!)
                        self.cachedCities.append(city)
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
