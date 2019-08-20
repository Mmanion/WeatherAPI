//
//  CityRealm.swift
//  WeatherAPI
//
//  Created by Matthew Manion on 8/20/19.
//  Copyright © 2019 Matthew Manion. All rights reserved.
//

import Foundation
import RealmSwift

class CityRealm: Object {
    @objc dynamic var name = ""
    @objc dynamic var cityName = ""
    @objc dynamic var temperature : Int = 0
    @objc dynamic var windSpeed = ""
    @objc dynamic var windDeg = ""
    @objc dynamic var cloud = ""
    @objc dynamic var icon = ""
    
    var details: [(String, String)] {
        return [("name", name ?? ""),
                ("cityName", cityName ?? ""),
                ("temperature", String(temperature) ?? ""),
                ("windSpeed", windSpeed ?? ""),
                ("windDeg", windDeg ?? ""),
                ("cloud", cloud ?? ""),
                ("icon", icon ?? "")]
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}
