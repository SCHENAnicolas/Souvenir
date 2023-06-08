//
//  WeatherViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 18/08/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Icon Dictionnary
    private let iconDictionnary = ["01d": UIImage(systemName: "sun.max.fill"),
                                   "01n": UIImage(systemName: "moon.stars.fill"),
                                   "02d": UIImage(systemName: "cloud.sun.fill"),
                                   "02n": UIImage(systemName: "cloud.moon.fill"),
                                   "03d": UIImage(systemName: "cloud.fill"),
                                   "03n": UIImage(systemName: "cloud.fill"),
                                   "04d": UIImage(systemName: "cloud.fill"),
                                   "04n": UIImage(systemName: "cloud.fill"),
                                   "09d": UIImage(systemName: "cloud.drizzle.fill"),
                                   "09n": UIImage(systemName: "cloud.drizzle.fill"),
                                   "10d": UIImage(systemName: "cloud.rain.fill"),
                                   "10n": UIImage(systemName: "cloud.rain.fill"),
                                   "11d": UIImage(systemName: "cloud.bolt.rain.fill"),
                                   "11n": UIImage(systemName: "cloud.bolt.rain.fill"),
                                   "13d": UIImage(systemName: "cloud.snow.fill"),
                                   "13n": UIImage(systemName: "cloud.snow.fill"),
                                   "50d": UIImage(systemName: "cloud.fog.fill"),
                                   "50n": UIImage(systemName: "cloud.fog.fill")]
    
    // MARK: - CLlocation
    private var locationManager: CLLocationManager?
    
    private let service = WeatherService()
    private let newYorkLat = 40.7127281
    private let newYorkLon = -74.0060152
    
    @IBOutlet weak var citySearchTextField: UITextField!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
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
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCorner()
        getNewYorkWeather()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
            
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
        }
    }
    
    // MARK: - IBAction
    @IBAction func searchButton(_ sender: Any) {
        getCoordinate()
    }
    
    // MARK: - CLLocationManager function
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        getAutoLocationWeather(lat: latitude, lon: longitude)
    }
    
    // MARK: - Service's functions
    private func getCoordinate() {
        guard let city = citySearchTextField.text, citySearchTextField.hasText else {
            presentAlert("No city in the search")
            return
        }
        service.getGeoCoordinate(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(coordinate):
                    self?.cityLabel.text = coordinate.city
                    self?.stateLabel.text = coordinate.state
                    self?.getWeather(lat: coordinate.lat, lon: coordinate.lon)
                case .failure(_):
                    self?.presentAlert("Incorrect request")
                }
            }
        }
    }
    
    private func getWeather(lat: Double, lon: Double) {
        service.getWeather(lat: lat, lon: lon) { [weak self] cityWeather in
            DispatchQueue.main.async {
                switch cityWeather {
                case let .success(weather):
                    self?.cityTemp.text = weather.temp
                    self?.cityDescription.text = weather.description
                    self?.cityMin.text = weather.tempMin
                    self?.cityMax.text = weather.tempMax
                    self?.cityImageView.image = self?.updateIcon(weather.iconID)
                    self?.activityIndicator.isHidden = true
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func getNewYorkWeather() {
        service.getWeather(lat: newYorkLat, lon: newYorkLon) { [weak self] newYorkWeather in
            DispatchQueue.main.async {
                switch newYorkWeather {
                case let .success(weather):
                    self?.newYorkTemp.text = weather.temp
                    self?.newYorkDescription.text = weather.description
                    self?.newYorkMin.text = weather.tempMin
                    self?.newYorkMax.text = weather.tempMax
                    self?.newYorkImageView.image = self?.updateIcon(weather.iconID)
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func getAutoLocationWeather(lat: Double, lon: Double) {
        service.getGeoCity(lat: lat, lon: lon) { [weak self] cityAndState in
            DispatchQueue.main.async {
                switch cityAndState {
                case let .success(cityName):
                    self?.cityLabel.text = cityName.city
                    self?.stateLabel.text = cityName.state
                    self?.getWeather(lat: lat, lon: lon)
                    self?.activityIndicator.isHidden = true
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func updateIcon(_ iconID: String) -> UIImage? {
        guard let weatherIcon = iconDictionnary[iconID] else {
            return nil
        }
        return weatherIcon
    }
}

// MARK: - Round Corner
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

// MARK: - Dismiss Keyboard
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        citySearchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
