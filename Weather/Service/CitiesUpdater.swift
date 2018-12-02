//
//  CitiesUpdater.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 01.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation

protocol CitiesWeatherDownloaderProtocol: class {
    
    associatedtype CitiesWeatherRequest: CitiesWeatherRequestProtocol
    
    init(cities: [City])
    
    func start(completion: ((NSError?) -> Void)?)
    
    var cities: [City] {get}
}

class CitiesWeatherWebApiDownloader<CitiesWeatherRequest: CitiesWeatherRequestProtocol>: NSObject, CitiesWeatherDownloaderProtocol {
    
    var cities: [City]
    
    fileprivate let maximumCitiesPerRequest = 20
    
    required init(cities: [City]) {
        self.cities = cities
        super.init()
    }
    
    private var _count: Int = 0
    private let  _countSemaphore = DispatchSemaphore(value: 1)
    
    private var _error: NSError?
    private let _errorSemaphore = DispatchSemaphore(value: 1)
    
    var error: NSError? {
        get {
            _errorSemaphore.wait()
            let e = _error
            _errorSemaphore.signal()
            return e
        }
        set {
            _errorSemaphore.wait()
            _error = newValue
            _errorSemaphore.signal()
        }
    }
    
    var operationsExecuting: Int {
        get {
            _countSemaphore.wait()
            let result = _count
            _countSemaphore.signal()
            return result
        }
        
        set {
            _countSemaphore.wait()
            _count = newValue
            _countSemaphore.signal()
        }
    }

    func start(completion: ((NSError?) -> Void)?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            autoreleasepool {
                
                var operations: [Operation] = []
                
                for i in stride(from: 0, to: self.cities.count, by: self.maximumCitiesPerRequest) {
                    
                    let subArray = Array(self.cities[i ..< min(i + self.maximumCitiesPerRequest, self.cities.count)])
                    let request = CitiesWeatherRequest(cities: subArray)
                    
                    request.successHandler = { [weak self] in
                        
                        guard let sself = self else { return }
                        
                        for j in 0 ..< subArray.count {
                            sself.cities[i + j] = request.cities[j]
                        }
                        
                        sself.operationsExecuting -= 1
                        
                        if sself.operationsExecuting == 0 {
                            completion?(sself.error)
                        }
                    }
                    
                    request.errorHandler = { [weak self] error in
                        
                        guard let sself = self else { return }
                        
                        sself.operationsExecuting -= 1
                        sself.error = error
                        
                        if sself.operationsExecuting == 0 {
                            completion?(sself.error)
                        }
                    }
                    
                    let operation = CitiesWeatherDownloadOperation(request: request)
                    operations.append(operation)
                }
                
                let queue = OperationQueue()
                self.operationsExecuting = operations.count
                queue.addOperations(operations, waitUntilFinished: false)
            }
        }
    }
}

fileprivate class CitiesWeatherDownloadOperation: Operation {
    
    let request: CitiesWeatherRequestProtocol
    
    init(request: CitiesWeatherRequestProtocol) {
        self.request = request
        super.init()
    }
    
    override func main() {
        request.send()
    }
}
