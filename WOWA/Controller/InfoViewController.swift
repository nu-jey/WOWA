//
//  InfoViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/05/16.
//

import Foundation
import UIKit
import CoreLocation

class InfoViewController: UIViewController {
    
    var locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스가 켜져있는 경우 ")
            locationManger.startUpdatingLocation() //위치 정보 받아오기 시작
            print(locationManger.location?.coordinate.latitude)
        } else {
            print("위치 서비스 꺼져있는 경우")
        }
    }
    
    
    @IBAction func registGymButtonPressed(_ sender: UIButton) {
        var location = [Double]()
        location.append(locationManger.location!.coordinate.latitude)
        location.append(locationManger.location!.coordinate.longitude)
        DatabaseManager.manager.registGym(gymName: "제이어스 짐", location: location)
    }
    
}

extension InfoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("경위도 업데이트")
        if let location = locations.first {
            print("위도: \(location.coordinate.latitude)")
            print("경도: \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
