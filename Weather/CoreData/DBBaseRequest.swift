//
//  DBBaseRequest.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 30.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

protocol StorageRequestProtocol: class {
    
    var completionHandler: (() -> Void)? {get set}
    func execute()
}

class DBBaseRequest: NSObject, StorageRequestProtocol {
    
    let db: CoreDataStorage = CoreDataStorage.shared
    
    private var _completionHandler: (() -> Void)?
    private var _completionHandlerSemaphore = DispatchSemaphore(value: 1)
    
    var completionHandler: (() -> Void)? {
        set {
            _completionHandlerSemaphore.wait()
            _completionHandler = newValue
            _completionHandlerSemaphore.signal()
        }
        
        get {
            _completionHandlerSemaphore.wait()
            let block = _completionHandler
            _completionHandlerSemaphore.signal()
            return block
        }
    }
    
    func execute() {
        fatalError("override this func in subclassing")
    }
}
