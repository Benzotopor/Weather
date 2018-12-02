//
//  BaseRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias RequestSuccessHandler = () -> Void
typealias RequestErrorHandler = (NSError?) -> Void

protocol BaseRequestProtocol : class {
    
    var successHandler: RequestSuccessHandler? {get set}
    var errorHandler: RequestErrorHandler? {get set}
    
    func send()
}

class BaseRequest: NSObject, BaseRequestProtocol {
    
    let baseUrl: String = "https://api.openweathermap.org/data/2.5"
    let appid: String   = "95b7f25ebb77962319a42203d3e297ce"
    
    var expectedCode: Int = 200
    var receivedCode: Int?
    
    var path = ""
    var request: URLRequest! = nil

    private let _successHandlerSemaphore = DispatchSemaphore(value: 1)
    private var _successHandler: RequestSuccessHandler?
    var successHandler: RequestSuccessHandler? {
        get {
            _successHandlerSemaphore.wait()
            let handler = _successHandler
            _successHandlerSemaphore.signal()
            return handler
        }
        set {
            _successHandlerSemaphore.wait()
            _successHandler = newValue
            _successHandlerSemaphore.signal()
        }
    }
    
    private let _errorHandlerSemaphore = DispatchSemaphore(value: 1)
    private var _errorHandler: RequestErrorHandler?
    
    var errorHandler: RequestErrorHandler? {
        get {
            _errorHandlerSemaphore.wait()
            let handler = _errorHandler
            _errorHandlerSemaphore.signal()
            return handler
        }
        set {
            _errorHandlerSemaphore.wait()
            _errorHandler = newValue
            _errorHandlerSemaphore.signal()
        }
    }
    
    
    func prepare() {
        fatalError("override this method on subclassing")
    }
    
    func send() {
        prepare()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                self.onError(error: error! as NSError)
                return
            }
            
            guard let data = data else {
                
                self.onError(error: NSError(domain: "Nusratbek.Weather",
                                            code: NSURLErrorBadServerResponse,
                                            userInfo: [NSLocalizedDescriptionKey: "Network connection error."] ))
                return
            }
            
            let json = JSON(data: data)
            
            if json == JSON.null {
                self.onError(error: self.invalidJsonError())
            } else if let response = response as? HTTPURLResponse {
                
                self.receivedCode = response.statusCode
                
                if self.receivedCode == self.expectedCode {
                    
                    if let error = self.handle(json: json) {
                        self.onError(error: error)
                    } else {
                        self.successHandler?()
                    }
                    
                } else if let message = json[JSONKeys.message].string {
                    self.onError(error: NSError(domain: "Nusratbek.Weather",
                                                code: NSURLErrorBadServerResponse,
                                                userInfo: [NSLocalizedDescriptionKey: message] ))
                } else {
                    
                    self.onError(error: self.invalidJsonError())
                }
                
            } else {
                self.onError(error: NSError(domain: "Nusratbek.Weather",
                                            code: NSURLErrorBadServerResponse,
                                            userInfo: [NSLocalizedDescriptionKey: "Network connection error."] ))
            }
        }
        
        task.resume()
    }
    
    func handle(json: JSON) -> NSError? {
        return nil
    }
    
    func onError(error: NSError) {
        errorHandler?(error)
    }
    
    func invalidJsonError() -> NSError {
        return NSError(domain: "Nusratbek.Weather",
                       code: NSURLErrorBadServerResponse,
                       userInfo: [NSLocalizedDescriptionKey: "Invalid json in response."])
    }
}

