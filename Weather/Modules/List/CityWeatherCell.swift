//
//  CityWeatherCell.swift
//  Weather
//
//  Created by Nusratbek Usmanov on 01.12.2018.
//  Copyright © 2018 Nusratbek. All rights reserved.
//

import UIKit

class CityWeatherCell: UITableViewCell {

    @IBOutlet weak var cityWeatherImage: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityWeatherLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class var height: CGFloat {
        return 70
    }
}

extension UITableViewCell {
    class var identifier: String {
        return theClassName
    }
}

extension NSObject {
    class var theClassName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
