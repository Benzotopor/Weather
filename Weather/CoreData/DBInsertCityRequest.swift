//
//  DBInsertCityRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 30.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

protocol StorageInsertCityRequestProtocol: StorageRequestProtocol {
    init(city: City)
}

class DBInsertCityRequest: DBBaseRequest, StorageInsertCityRequestProtocol {
    
    let city: City
    
    required init(city: City) {
        self.city = city
        super.init()
    }
    
    override func execute() {

        let context = db.getNewContext()

        context.perform {
            
            autoreleasepool {
                let record = DBRecordCity(context: context)
                
                record.id           = Int64(self.city.id)
                record.name         = self.city.name
                record.latitude     = self.city.latitude
                record.longitude    = self.city.longitude
                record.temperature  = self.city.temperature
                record.icon         = self.city.icon
                
                do {
                    try context.save()
                } catch {
                    fatalError("error in save context : \(error)")
                }
                    
                self.db.saveChanges()
                
                context.reset()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.completionHandler?()
            }
        }
    }
}
