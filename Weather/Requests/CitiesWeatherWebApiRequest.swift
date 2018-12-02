//
//  CitiesWeatherWebApiRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 02.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol CitiesWeatherRequestProtocol: BaseRequestProtocol {
    init(cities: [City])
    var cities: [City] {get}
}

class CitiesWeatherWebApiRequest: BaseRequest, CitiesWeatherRequestProtocol {

    var cities: [City]
   
    required init(cities: [City]) {
        self.cities = cities
        super.init()
    }
    
    override func prepare() {
        
        let citiesIds = cities.map{String($0.id)}.joined(separator: ",")
        
        path = "/group?id=\(citiesIds)&units=metric&appid=\(appid)"
        
        guard let path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: baseUrl + path) else {
                fatalError("incorrect path : \(self.path)")
        }
        
        request = URLRequest(url: url)
    }
    
    override func handle(json: JSON) -> NSError? {
        
        guard let jsonArray = json[JSONKeys.list].array else {
            return invalidJsonError()
        }
        
        for i in 0 ..< jsonArray.count {
            
            guard let city = City(json: jsonArray[i]) else {
                continue
            }
            
            cities[i] = city
        }
        
        return nil
    }
}
