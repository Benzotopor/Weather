//
//  CityWeatherWebApiRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CityWeatherRequestProtocol: BaseRequestProtocol {
    init(city: String)
    var isNotFoundReceived: Bool {get}
    var city: City? {get}
}

class CityWeatherWebApiRequest: BaseRequest, CityWeatherRequestProtocol {
    
    private let _cityName: String

    required init(city: String) {
        self._cityName = city
    }

    var isNotFoundReceived: Bool {
        return receivedCode == 404
    }
    
    var city: City?
    
    override func prepare() {
        path = "/weather?q=\(_cityName)&appid=\(appid)&units=metric"
        
        guard
            let path = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: baseUrl + path) else {
            fatalError("incorrect path : \(self.path)")
        }
        
        request = URLRequest(url: url)
    }
    
    override func handle(json: JSON) -> NSError? {
        
        guard let city = City(json: json) else {
            return invalidJsonError()
        }

        self.city = city

        return nil
    }
}
