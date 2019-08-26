//
//  ViewController.swift
//  WeatherAPI
//
//  Created by Matthew Manion on 8/20/19.
//  Copyright © 2019 Matthew Manion. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    lazy var cities: Results<CityRealm> = { self.realm.objects(CityRealm.self) }()
    let cityRealm = CityRealm()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        populateDefaultCities()
        getCitiesWeatherData()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
//       
//        
    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else {
            fatalError("TableViewCell does not exist")
        }
        
        cell.cityLabel.text = self.cities[indexPath.row].cityName
        cell.temperatureLabel.text = String(self.cities[indexPath.row].temperature)
        
        let imageURL = "http://openweathermap.org/img/w/" + self.cities[indexPath.row].icon + ".png"
        
        Alamofire.request(imageURL).responseImage { response in
            DispatchQueue.main.async {
                if let image = response.result.value {
                    cell.imageIcon.image = image
                }
            }
        }
        return cell
    }
    
    
    // Segue into WeatherDetailViewController
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "weatherSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weatherSegue"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let weatherDetailViewController = segue.destination as! WeatherDetailViewController
                let city = cities[indexPath.row]
                weatherDetailViewController.cityNameData = city.cityName
                weatherDetailViewController.cityTemperatureData = String(city.temperature)
                weatherDetailViewController.cityWindDegreeData = city.windDeg
                weatherDetailViewController.cityWindSpeedData = city.windSpeed
                weatherDetailViewController.cityCloudData = city.cloud
                weatherDetailViewController.cityIconData = city.icon
            }
        }
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                //         self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    func getCurrentWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateCurrentWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                //         self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    
    func updateCurrentWeatherData(json : JSON)   {
        for city in json {
            let name = "CurrentCity"
            let cityName = json["name"].stringValue
            let tempResult = json["main"]["temp"].doubleValue
            let temperature = Int(tempResult - 273.15)
            let windSpeed = json["wind"]["speed"].stringValue
            let windDeg = json["wind"]["deg"].stringValue
            let cloud = json["clouds"]["all"].stringValue
            let icon = json["weather"][0]["icon"].stringValue
            let newCity = City(name: name, cityName: cityName, temperature: temperature, windSpeed: windSpeed, windDeg: windDeg, cloud: cloud, icon: icon )
            insertOrUpdate(city: newCity)
        }
    }
    
    func updateWeatherData(json : JSON)   {
        for city in json {
            let name = json["name"].stringValue
            let cityName = json["name"].stringValue
            let tempResult = json["main"]["temp"].doubleValue
            let temperature = Int(tempResult - 273.15)
            let windSpeed = json["wind"]["speed"].stringValue
            let windDeg = json["wind"]["deg"].stringValue
            let cloud = json["clouds"]["all"].stringValue
            let icon = json["weather"][0]["icon"].stringValue
            let newCity = City(name: name, cityName: cityName, temperature: temperature, windSpeed: windSpeed, windDeg: windDeg, cloud: cloud, icon: icon )
            insertOrUpdate(city: newCity)
        }
    }
    
    func insertOrUpdate(city: City) {
        let realm = try! Realm()
        try! realm.write({
            let cityRealm = CityRealm()
            cityRealm.name = city.name
            cityRealm.cityName = city.cityName
            cityRealm.temperature = city.temperature
            cityRealm.windSpeed = city.windSpeed
            cityRealm.windDeg = city.windDeg
            cityRealm.cloud = city.cloud
            cityRealm.icon = city.icon
            realm.add(cityRealm, update: true)
        })
        cities = realm.objects(CityRealm.self)
        tableView.reloadData()
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getCurrentWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private func populateDefaultCities() {
        if cities.count == 0 { // 1
            try! realm.write() { // 2
                let defaultCities =
                    ["CurrentCity", "Tokyo", "London" ] // 3
                for city in defaultCities { // 4
                    let newCity = CityRealm()
                    newCity.name = city
                    realm.add(newCity)
                }
            }
            cities = realm.objects(CityRealm.self) // 5
        }
    }
    
    private func getCitiesWeatherData() {
        for city in cities { // 4
            if city.name != "CurrentCity"{
                getWeatherDataByCityName(city: city.name)
            }
        }
    }
    
    func getWeatherDataByCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }


}

