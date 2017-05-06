//
//  WeatherRequest.swift
//  WeatherApp
//
//  Created by Oliver Gepp on 17.01.17.
//  Copyright © 2017 Zuehlke Engineering AG. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeatherRequest {
    
   
    private var lakeName: String
    
    
    init(lakeName: String) {
        
        self.lakeName = lakeName
    }
    

    func getRequestURL(lakeNameForRequest: String) -> String{
        var requestName: String
        requestName = lakeNameForRequest
        if lakeNameForRequest == "Bielersee" {requestName = "Biel"}
        else if lakeNameForRequest=="Vierwaldstättersee"{requestName = "Luzern"}
        else if lakeNameForRequest=="Genfersee"{requestName = "Genf"}


        let openWeatherNowURL = "http://api.openweathermap.org/data/2.5/weather?q=" + requestName + "&units=metric&APPID=3f32ae699559cc963085bac1b8d45a3d"
        return openWeatherNowURL
    }
    
    
    // zühlke: 3f32ae699559cc963085bac1b8d45a3d
    // wakingup: f775032d25536c0a7f515e7dc480a702
    
    
    func performRequest(successHandler: @escaping (WeatherData) -> Void, errorHandler: @escaping () -> Void) {
        
        let urlStr = getRequestURL(lakeNameForRequest: lakeName)
        
        
        //let urlStr = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&lang=de&units=metric&APPID=3f32ae699559cc963085bac1b8d45a3d"
        guard let url = URL(string: urlStr) else {
            print("invalid url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data:Data?, response: URLResponse?, error: Error?) in
            
            if let error = error{
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse{
            
                if response.statusCode >= 400{
                    print("Computer says NO: \(response.statusCode)")
                    return
                }
            }
            else {
                print("no response received")
                return
            }
           
            guard let data = data else {
                print("No data received")
                return
            }
            
            let json = JSON(data:data)
            print("Received JSON: %@", json.description)
            
            let weatherData = WeatherData()
            
            weatherData.city = json["name"].stringValue
            
            weatherData.weather = json["weather"][0]["description"].stringValue
            weatherData.icon = json["weather"][0]["icon"].stringValue
            
            weatherData.temp = json["main"]["temp"].doubleValue
            weatherData.minTemp = json["main"]["temp_min"].doubleValue
            weatherData.maxTemp = json["main"]["temp_max"].doubleValue
            weatherData.humidity = json["main"]["humidity"].intValue
            
            successHandler(weatherData)
        }
        
        task.resume()
    }
    
}
