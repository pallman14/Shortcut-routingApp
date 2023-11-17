//  Price Allman
//  linksViewController.swift
//  Shortcut


import UIKit

class linksViewController: UIViewController {

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Action triggered when the gas prices button is pressed
    @IBAction func pricesBtnPressed(_ sender: Any) {
        
        // Open the GasBuddy website in the default web browser
        UIApplication.shared.open(URL(string:"https://www.gasbuddy.com/home#:~:text=GasBuddy%20%2D%20Find%20The%20Nearest%20Gas%20Stations%20%26%20Cheapest%20Prices")! as URL, options: [:], completionHandler: nil)
    }
    
    // Action triggered when the Toll calculator button is pressed
    @IBAction func tollBtnPressed(_ sender: Any) {
        
        // Open the TollGuru website in the default web browser
        UIApplication.shared.open(URL(string:"https://tollguru.com/car-toll-calculator")! as URL, options: [:], completionHandler: nil)
    }
    
    // Action triggered when the radar button is pressed
    @IBAction func radarBtnPressed(_ sender: Any) {
        
        // Open the National Weather Service Radar website in the default web browser
        UIApplication.shared.open(URL(string:"https://radar.weather.gov/?settings=v1_eyJhZ2VuZGEiOnsiaWQiOm51bGwsImNlbnRlciI6Wy05NSwzN10sImxvY2F0aW9uIjpudWxsLCJ6b29tIjo0fSwiYW5pbWF0aW5nIjpmYWxzZSwiYmFzZSI6InN0YW5kYXJkIiwiYXJ0Y2MiOmZhbHNlLCJjb3VudHkiOmZhbHNlLCJjd2EiOmZhbHNlLCJyZmMiOmZhbHNlLCJzdGF0ZSI6ZmFsc2UsIm1lbnUiOnRydWUsInNob3J0RnVzZWRPbmx5IjpmYWxzZSwib3BhY2l0eSI6eyJhbGVydHMiOjAuOCwibG9jYWwiOjAuNiwibG9jYWxTdGF0aW9ucyI6MC44LCJuYXRpb25hbCI6MC42fX0%3D")! as URL, options: [:], completionHandler: nil)
    }
}
