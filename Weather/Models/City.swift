//
//  City.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import SwiftyJSON

struct City {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let temperature: Double
    let icon: String
}

extension City {
    init?(json: JSON) {
        guard
            let id          = json[JSONKeys.id].int,
            let name        = json[JSONKeys.name].string,
            let longitude   = json[JSONKeys.coord][JSONKeys.lon].double,
            let latitude    = json[JSONKeys.coord][JSONKeys.lat].double,
            let temperature = json[JSONKeys.main][JSONKeys.temp].double,
            let icon        = json[JSONKeys.weather].array?.first?[JSONKeys.icon].string
        else { return nil }
        
        let iconFullUrl = "https://openweathermap.org/img/w/\(icon).png"
        
        self = City(id: id, name: name, latitude: latitude, longitude: longitude, temperature: temperature, icon: iconFullUrl)
        
    }
}

extension City {
    
    var temperatureToDisplay: String {
        let temp = "\(Int(temperature))°C"
        if temperature > 0 {
            return "+" + temp
        }
        return temp
    }
}

extension City: Equatable {}

func == (lhs: City, rhs: City) -> Bool {
    return lhs.id == rhs.id
}
