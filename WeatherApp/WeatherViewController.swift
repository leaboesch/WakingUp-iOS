//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Oliver Gepp on 17.01.17.
//  Copyright © 2017 Zuehlke Engineering AG. All rights reserved.
//

import UIKit
import CoreLocation

/*
 @IBOutlet weak var lakeSelected: UIPickerView!
 * Brugg AG: 47.479501, 8.213011
 */

class WeatherViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    //let locationManager = CLLocationManager()
    
    // for Lake Picker
    @IBOutlet weak var lakeLabel: UILabel!
    var lakes = ["Bodensee", "Vierwaldstättersee", "Bielersee", "Genfersee", "Sempachersee"]
    
    fileprivate var weatherRequest: WeatherRequest? = nil
   // fileprivate var location: CLLocation? = nil
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lakePicker: UIPickerView!
    
    var selectedLake = "Bodensee"
    
    
    // for lake picker
    //:MARK - Delegates and data sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lakes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lakes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lakeLabel.text = lakes[row]
        selectedLake = lakes[row]
        performServerRequest_Lake()
    }
  
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lakePicker.delegate = self
        lakePicker.dataSource = self
       // locationManager.delegate = self
        //locationManager.requestLocation()
        askForPermission()
    }
    
    
    fileprivate func showDeviceNotAllowed() {
        
        let alertController = UIAlertController(title: "Entschuldigung", message: "Die Standortbestimmung ist für die App nicht freigegeben", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func performServerRequest_Lake() {
        
        // hier koordinaten für den see finden
        
        let request = WeatherRequest(lakeName: selectedLake)
 
        request.performRequest(successHandler: { (weatherData: WeatherData) in
            
            DispatchQueue.main.async {
                self.updateUI(weatherData: weatherData)
            }
            
        }) {
            print("error loading weather")
        }
    }
    
    
    
    private func updateUI(weatherData:WeatherData){
    
       cityLabel.text = weatherData.city

        weatherLabel.text = weatherData.weather
        
      
        tempLabel.text = weatherData.formattedTemp
        var temp = weatherData.formattedTemp
        temp.characters.removeLast()
        
        if let temperature = Double(temp){
            if temperature < 13.0{
                    tempLabel.text = "1"
                    weatherLabel.text = "Chli chalt"
            }
            else if temperature < 20.0{
                tempLabel.text = "3"
                weatherLabel.text = "Für die Motivierten"
            }
            else if temperature < 30.0{
                tempLabel.text = "6"
                weatherLabel.text = "Go for it!"
            }
            else {
                tempLabel.text = "10"
                weatherLabel.text = "Abkühlung gefällig?"
            }
        }
        
        minTempLabel.text = weatherData.formattedMinTemp
        maxTempLabel.text = weatherData.formattedMaxTemp
        humidityLabel.text = weatherData.formattedHumidity
        
        if let imageName = weatherData.icon{
            let imageRequest = WeatherIconRequest(iconName: imageName)
            imageRequest.performRequest(successHandler: { (image : UIImage) in
                DispatchQueue.main.async {
                    self.updateImage(image: image)
                }
            }, errorHandler: { 
                print("error loading weather icon")
            })
        }
    }
    
    private func updateImage(image: UIImage){
        iconImageView.image = image
    }
    
    
    @IBAction func reloadPressed(_ sender: AnyObject){
        
    }
    
}


extension WeatherViewController : CLLocationManagerDelegate{
    
 

    

    fileprivate func checkPermission() {
        
        print("Checking permission")
        switch(CLLocationManager.authorizationStatus()) {
        case .denied:
            showDeviceNotAllowed()
        case .restricted:
            showDeviceNotAllowed()
        case .notDetermined:
            askForPermission()
        case .authorizedWhenInUse:
            startLocationRequest()
        default:
            print("other status, do nothing")
        }
    }
    
    
    fileprivate func askForPermission() {
        print("Requesting permission")
        //locationManager.requestWhenInUseAuthorization()
    }
    
    fileprivate func startLocationRequest() {
        print("Start location request")
       // locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //locationManager.startUpdatingLocation()
    }
    
}

