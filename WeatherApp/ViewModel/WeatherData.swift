//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Mehmet Alp Sönmez on 11/12/2024.
//

import CoreLocation
import Foundation
import Observation
import Combine

struct WeatherData {
    let locationName: String
    let temperature: Double
    let condition: String
}

struct WeatherResponse: Codable {
    let name: String
    let main: MainWeather
    let weather: [Weather]
}

struct MainWeather: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var locationPublisher = PassthroughSubject<CLLocation, Never>() // Emits non-optional CLLocation
    var location: CLLocation? {
        didSet {
            if let location = location {
                locationPublisher.send(location) // Emit only non-nil values
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationManager.stopUpdatingLocation() // Stop updates after fetching
        print("Fetched location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location: \(error.localizedDescription)")
    }
}
