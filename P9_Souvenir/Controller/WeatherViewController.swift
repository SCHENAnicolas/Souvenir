//
//  WeatherViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 18/08/2022.
//

import UIKit

enum weatherIcon: String {
    case clearSky = "01d"
    case clearNightSky = "01n"
    case fewClouds = "02d"
    case fewCloudsNight = "02n"
    
    case scatteredClouds = "03d"
    case scatteredCloudsNight = "03n"
    case brokenCloud = "04d"
    case brokenCloudNight = "04n"
    
    case showerRain = "09d"
    case showerRainNight = "09n"
    
    case rain = "10d"
    case rainNight = "10n"
    
    case thunderstorm = "11d"
    case thunderstormNight = "11n"
    
    case snow = "13d"
    case snowNight = "13n"
    
    case mist = "50d"
    case mistNight = "50n"
    
    var image: UIImage {
        switch self {
        case .clearSky: return UIImage(systemName: "sun.max.fill")!
        case .clearNightSky: return UIImage(systemName: "moon.star.fill")!
            
        case .fewClouds: return UIImage(systemName:"cloud.sun.fill")!
        case .fewCloudsNight: return UIImage(systemName: "cloud.moon.fill")!
            
        case .scatteredClouds: return UIImage(systemName:"cloud.fill")!
        case .scatteredCloudsNight: return UIImage(systemName:"cloud.fill")!
        case .brokenCloud: return UIImage(systemName:"cloud.fill")!
        case .brokenCloudNight: return UIImage(systemName:"cloud.fill")!
            
        case .showerRain: return UIImage(systemName: "cloud.drizzle.fill")!
        case .showerRainNight: return UIImage(systemName: "cloud.drizzle.fill")!
            
        case .rain: return UIImage(systemName: "cloud.rain.fill")!
        case .rainNight: return UIImage(systemName: "cloud.rain.fill")!
            
        case .thunderstorm: return UIImage(systemName: "cloud.bolt.rain.fill")!
        case .thunderstormNight: return UIImage(systemName: "cloud.bolt.rain.fill")!
            
        case .snow: return UIImage(systemName: "cloud.snow.fill")!
        case .snowNight: return UIImage(systemName: "cloud.snow.fill")!
            
        case .mist: return UIImage(systemName: "cloud.fog.fill")!
        case .mistNight: return UIImage(systemName: "cloud.fog.fill")!
        }
    }
    
    
    
}

class WeatherViewController: UIViewController {
    
    private let service = WeatherService()
    private let newYorkLat = 40.7127281
    private let newYorkLon = -74.0060152
    
    @IBOutlet weak var citySearchTextField: UITextField!
    
    // MARK: - New York IBOutlet
    @IBOutlet weak var newYorkStackView: UIStackView!
    @IBOutlet weak var newYorkImageView: UIImageView!
    @IBOutlet weak var newYorkTemp: UILabel!
    @IBOutlet weak var newYorkDescription: UILabel!
    @IBOutlet weak var newYorkMin: UILabel!
    @IBOutlet weak var newYorkMax: UILabel!
    
    // MARK: - City IBOutlet
    
    @IBOutlet weak var cityStackView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var cityTemp: UILabel!
    @IBOutlet weak var cityDescription: UILabel!
    @IBOutlet weak var cityMin: UILabel!
    @IBOutlet weak var cityMax: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCorner()
        getNewYorkWeather()
    }
    
    @IBAction func button(_ sender: Any) {
        getCoordinate()
    }
    
    //    MARK: - A modifier
    private func getCoordinate() {
        guard let city = citySearchTextField.text, citySearchTextField.text?.isEmpty == false else {
            presentAlert("No city in the search")
            return
        }
        service.getGeoCoordinate(city: city) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(coordinate):
                    guard case coordinate.isEmpty = false else {
                        self.presentAlert("")
                        return
                    }
                    self.cityLabel.text = coordinate[0].name
                    self.stateLabel.text = coordinate[0].state
                    self.getWeather(lat: coordinate[0].lat, lon: coordinate[0].lon)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func getWeather(lat: Double, lon: Double) {
        service.getWeather(lat: lat, lon: lon) { weatherCity in
            DispatchQueue.main.async {
                switch weatherCity {
                case let .success(weather):
                    self.cityTemp.text = "\(String(weather.main.temp.description))°"
                    self.cityDescription.text = "\(weather.weather[0].weatherDescription)"
                    self.cityMin.text = "\(String(weather.main.tempMin.description))°"
                    self.cityMax.text = "\(String(weather.main.tempMax.description))°"
                    self.cityImageView.image = self.updateIcon(weather.weather[0].icon)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func getNewYorkWeather() {
        service.getWeather(lat: newYorkLat, lon: newYorkLon) { weatherNY in
            DispatchQueue.main.async {
                switch weatherNY {
                case let .success(weatherNY):
                    self.newYorkTemp.text = "\(String(weatherNY.main.temp.description))°"
                    self.newYorkDescription.text = "\(weatherNY.weather[0].weatherDescription)"
                    self.newYorkMin.text = "\(String(weatherNY.main.tempMin.description))°"
                    self.newYorkMax.text = "\(String(weatherNY.main.tempMax.description))°"
                    self.newYorkImageView.image = self.updateIcon(weatherNY.weather[0].icon)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func updateIcon(_ iconID: String) -> UIImage {
        guard let ID = weatherIcon.init(rawValue: iconID)?.image else {
            return UIImage(systemName: "trash")!
        }
        return ID
    }
}


// MARK: - Label
extension WeatherViewController {
    private func roundCornered(_ stackView: UIStackView) {
        stackView.layer.masksToBounds = true
        stackView.layer.cornerRadius = 8.0
    }
    
    /// Method to add round corners to specified label
    private func addRoundCorner() {
        roundCornered(cityStackView)
        roundCornered(newYorkStackView)
    }
}

// MARK: - Keyboard
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        citySearchTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
