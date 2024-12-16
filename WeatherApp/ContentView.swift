//
//  ContentView.swift
//  WeatherApp
//
//  Created by Mehmet Alp Sönmez on 11/12/2024.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    
    
    var body: some View {
        VStack {
            if let weatherData = weatherData {
                Text("\(Int(weatherData.temperature))°C")
                    .font(.custom("", size: 70))
                    .padding()
                
                VStack {
                    Text("\(weatherData.locationName)")
                        .font(.title2).bold()
                    Text("\(weatherData.condition)")
                        .font(.body).bold()
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                Text("CodeLab")
                    .bold()
                    .padding()
                    .foregroundStyle(.gray)
            } else {
                ProgressView()
            }
        }
        .frame(width: 300, height: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .onAppear() {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.locationPublisher) { location in
                   print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                   fetchWeatherData(for: location)
               }
           }
    
    private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "b39c9850f4948c955bc49043a7d697f4"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                return
            }
            
            // Log the API response
            print("API response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = WeatherData(
                        locationName: weatherResponse.name,
                        temperature: weatherResponse.main.temp,
                        condition: weatherResponse.weather.first?.description ?? "Unknown"
                    )
                }
                print("Decoded weather data: \(self.weatherData)")
            } catch {
                print("Failed to decode weather data: \(error.localizedDescription)")
            }
            
        }.resume()
    }
    
}

#Preview {
    ContentView()
}
