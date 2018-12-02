//
//  CitiesModuleBuilder.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

class CitiesModuleBuilder: NSObject {
    func build<
            R1: CityWeatherRequestProtocol,
            R2: StorageInsertCityRequestProtocol,
            R3: StorageAllCitiesRequestProtocol,
            R4: StorageDeleteCityRequestProtocol,
            R5: CitiesWeatherDownloaderProtocol,
            R6: StorageInsertCitiesRequest>(coordiantor: CitiesPresenterCoordiantor) -> (CitiesPresenter<R1, R2, R3, R4, R5, R6>, CitiesListViewController) {
        
        let vc = CitiesListViewController()
        let p = CitiesPresenter<R1, R2, R3, R4, R5, R6>(coordinator: coordiantor, screen: vc)
        
        vc.eventsHandler = p
        
        return (p, vc)
    }
}
