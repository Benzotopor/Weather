//
//  MainCoordinator.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

protocol MainCoordinatorProtocol : CoordiantorProtocol, CitiesPresenterCoordiantor {
    init(window: UIWindow)
    func start()
}

class MainCoordinator: NSObject, MainCoordinatorProtocol {
    
    let window: UIWindow
    var navigationController: UINavigationController?
    
    required init(window: UIWindow) {
        self.window = window
        super.init()
    }
    
    func start() {
        
        let vc = ViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
       
        CoreDataStorage.initialize {
            
            let (_, citiesVC) = CitiesModuleBuilder().build(coordiantor: self)
                as (CitiesPresenter<CityWeatherWebApiRequest,
                    DBInsertCityRequest,
                    DBAllCitiesRequest,
                    DBDeleteCityRequest,
                    CitiesWeatherWebApiDownloader<CitiesWeatherWebApiRequest>,
                    DBInsertCitiesRequest>, CitiesListViewController)
            
            let rootViewController = self.window.rootViewController

            citiesVC.view.frame = (rootViewController?.view.frame)!
            citiesVC.view.layoutIfNeeded()

            UIView.transition(with: self.window, duration: 0.6, options: .transitionCrossDissolve, animations: {
                rootViewController?.view.alpha = 0
                self.window.rootViewController = citiesVC
            })
        }
    }
}

extension MainCoordinator: CitiesPresenterCoordiantor {

}
