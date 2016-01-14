//
//  Forecast.swift
//  AdaptiveWeather
//
//  Created by Adam Ahrens on 6/1/15.
//  Copyright (c) 2015 Appsbyahrens. All rights reserved.
//

import Foundation

struct Forecast: CustomStringConvertible {
    
    var day: String!
    var dayOfWeek: String!
    var temperature: Double!
    var weatherDescription: String!
    
    // Printable Protocol
    var description: String {
        get {
            if let day = day, dayOfWeek = dayOfWeek, temp = temperature, desc = weatherDescription {
                return "Farhenheit=\(temp), Day=\(day), DayOfWeek=\(dayOfWeek), Description=\(desc)"
            }
            
            return "Parsing failed"
        }
    }
    
    init(json: JSON) {
        // Set weather Rain, Clear, Sunny, etc
        weatherDescription = json["weather"][0]["main"].stringValue
        
        // Set the temperature
        let kelvin = json["temp"]["day"].stringValue
        if let k = NSNumberFormatter().numberFromString(kelvin)?.doubleValue {
            // Convert to Fahrenheit
            let fahrenheit = ((k - 273.15) * 1.8) + 32.0
            temperature = fahrenheit
        }
        
        // Convert Unix to NSDate
        let unix = json["dt"].doubleValue
        let date = NSDate(timeIntervalSince1970: unix)
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "d"
        day = dayFormatter.stringFromDate(date)
        
        let dayOfWeekFormatter = NSDateFormatter()
        dayOfWeekFormatter.dateFormat = "E"
        dayOfWeek = dayOfWeekFormatter.stringFromDate(date)
    }
}