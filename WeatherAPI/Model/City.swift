//
//  City.swift
//  WeatherAPI
//
//  Created by Matthew Manion on 8/20/19.
//  Copyright © 2019 Matthew Manion. All rights reserved.
//

import Foundation

class City {
    var name = ""
    var cityName = ""
    var temperature : Int = 0
    var windSpeed = ""
    var windDeg = ""
    var cloud = ""
    var icon = ""
    
    init(name: String, cityName: String, temperature: Int, windSpeed: String, windDeg: String, cloud: String, icon: String ) {
        self.name = name
        self.cityName = cityName
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.windDeg = windDeg
        self.cloud = cloud
        self.icon = icon
    }
    
}
