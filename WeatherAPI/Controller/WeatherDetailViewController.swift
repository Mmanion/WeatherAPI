//
//  WeatherDetailViewController.swift
//  WeatherAPI
//
//  Created by Matthew Manion on 8/20/19.
//  Copyright © 2019 Matthew Manion. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class WeatherDetailViewController: UIViewController {

    var cityNameData = "test"
    var cityTemperatureData = "test"
    var cityWindSpeedData = "test"
    var cityWindDegreeData = "test"
    var cityCloudData = "test"
    var cityIconData = "test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(cityNameData)
//        navigationController?.navigationBar.barTintColor = UIColor(red: 132/255.0, green: 161/255.0, blue: 190/255.0, alpha: 1.0)
        
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDegreeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        cityNameLabel.text = cityNameData
        temperatureLabel.text = cityTemperatureData
        cloudLabel.text = cityCloudData
        windSpeedLabel.text = cityWindSpeedData
        windDegreeLabel.text = cityWindDegreeData
        loadWeatherIcon()
    }
    

    func loadWeatherIcon() {
        let imageURL = "http://openweathermap.org/img/w/" + self.cityIconData + ".png"
        Alamofire.request(imageURL).responseImage { response in
            DispatchQueue.main.async {
                if let image = response.result.value {
                    self.weatherIcon.image = image
                }
            }
        }
    }

}
