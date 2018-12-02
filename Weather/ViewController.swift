//
//  ViewController.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 29.11.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(acitivityIndicator)
        acitivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        acitivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        acitivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        acitivityIndicator.startAnimating()
    }
}
