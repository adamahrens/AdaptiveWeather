//
//  DailyWeatherCollectionViewCell.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 5/31/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import UIKit

class DailyWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dayOfTheWeek: UILabel!
    
    func configureCellWithForecast(forecast: Forecast) {
        dayNumber.text = forecast.day
        dayOfTheWeek.text = forecast.dayOfWeek
        if let image = imageForDescription(forecast.weatherDescription) {
            weatherImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        dayNumber.text = nil
        dayOfTheWeek.text = nil
        weatherImageView.image = nil
    }
    
    func imageForDescription(description: String) -> UIImage? {
        if description == "Clear" {
            return UIImage(named: "Clear")
        }
        
        if description == "Clouds" {
            return UIImage(named: "PartlySunny")
        }
        
        if description == "Rain" {
            return UIImage(named: "Rain")
        }
        
        if description == "Thunderstorm" {
            return UIImage(named: "Thunderstorm")
        }
        
        return nil
    }
}
