//
//  CitiesPresenter.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation

protocol CitiesPresenterCoordiantor: class {
    
}

protocol CitiesScreen: ScreenProtocol {
    func set(cities: [City])
    func add(city: City)
    func remove(cityIdx: Int)
    func showSearchedCityNotFoundMessage()
    func offerForSearch(city: City)
    func showLoadingSearchedCity()
    func fullReload(cities: [City])
    func showErrorOnReload(message: String)
    func showError(message: String)
}

protocol CitiesPresenterProtocol: class {
    
    associatedtype CityWeatherRequest:  CityWeatherRequestProtocol
    associatedtype InsertCityRequest:   StorageInsertCityRequestProtocol
    associatedtype CachedCitiesRequest: StorageAllCitiesRequestProtocol
    associatedtype DeleteCityRequest:   StorageDeleteCityRequestProtocol
    associatedtype CitiesWeatherDownloader: CitiesWeatherDownloaderProtocol
    associatedtype InsertCitiesRequest: StorageInsertCitiesRequest
    
    init(coordinator: CitiesPresenterCoordiantor, screen: CitiesScreen)
}

class CitiesPresenter < CityWeatherRequest: CityWeatherRequestProtocol,
                        InsertCityRequest: StorageInsertCityRequestProtocol,
                        CachedCitiesRequest: StorageAllCitiesRequestProtocol,
                        DeleteCityRequest: StorageDeleteCityRequestProtocol,
                        CitiesWeatherDownloader: CitiesWeatherDownloaderProtocol,
                        InsertCitiesRequest: StorageInsertCitiesRequest>: BasePresenter, CitiesPresenterProtocol {
    
    weak var screen: CitiesScreen?
    let coordinator: CitiesPresenterCoordiantor
    
    var citySearchRequest: CityWeatherRequest?
    var cityInsertRequest: InsertCityRequest?
    
    var cities: [City] = []
    
    var downloader: CitiesWeatherDownloader!
    
    required init(coordinator: CitiesPresenterCoordiantor, screen: CitiesScreen) {
        
        self.coordinator = coordinator
        self.screen = screen
        
        super.init()
    }
    
    func newSearch(text: String) {
        
        citySearchRequest?.errorHandler = nil
        citySearchRequest?.successHandler = nil
        
        citySearchRequest = CityWeatherRequest(city: text)
        
        citySearchRequest?.successHandler = { [weak self] in
            guard let sself = self else { return }
            
            DispatchQueue.main.async {
                if let city = sself.citySearchRequest?.city {
                    sself.screen?.offerForSearch(city: city)
                }
            }
        }
        
        citySearchRequest?.errorHandler = { [weak self] error in
            guard let sself = self else { return }
            
            DispatchQueue.main.async {
                
                sself.screen?.showSearchedCityNotFoundMessage()
            }
        }
        
        citySearchRequest?.send()
    }
    
    func insertCity(city: City) {
        
        let request = InsertCityRequest(city: city)
        request.completionHandler = { [weak self] in
            guard let sself = self else { return }
            
            DispatchQueue.main.async {
                sself.cities.append(city)
                sself.screen?.add(city: city)
            }
        }
        request.execute()
    }
    
    func update() {
        
        guard !cities.isEmpty else  { return }
        
        downloader = CitiesWeatherDownloader(cities: self.cities)
        downloader.start {[weak self] error in
            guard let sself = self else { return }
                        
            DispatchQueue.main.async {
                
                if let error = error {
                    
                    sself.screen?.showErrorOnReload(message: error.localizedDescription)
                    
                } else {
                    sself.cities = sself.downloader.cities
                    sself.screen?.fullReload(cities: sself.cities)
                    sself.updateRecords()
                }
            }
        }
    }
    
    func updateRecords() {
        
        let request = InsertCitiesRequest(cities: cities)
        request.execute()
        
    }
}

extension CitiesPresenter: CitiesScreenEventsHandlerProtocol {
    
    func onScreenReady() {
        
        let request = CachedCitiesRequest()
        request.completionHandler = { [weak self] in
            
            guard let sself = self else { return }
            
            sself.cities = request.cachedCities
            
            DispatchQueue.main.async {
                sself.screen?.set(cities: sself.cities)
                sself.update()
            }
        }
        
        request.execute()
    }
    
    func onSearch(text: String) {
        screen?.showLoadingSearchedCity()
        newSearch(text: text)
    }
    
    func onAdd(city: City) {
        
        if !cities.contains(city) {
            insertCity(city: city)
        }
    }
    
    func onDelete(cityIdx: Int) {
        
        let request = DeleteCityRequest(city: cities[cityIdx])
        request.completionHandler = { [weak self] in
            
            guard let sself = self else { return }
            
            DispatchQueue.main.async {
                sself.cities.remove(at: cityIdx)
                sself.screen?.remove(cityIdx: cityIdx)
            }
        }
        
        request.execute()
    }
    
    func onUpdate() {
        update()
    }
}
