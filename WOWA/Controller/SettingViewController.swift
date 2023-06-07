//
//  ViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/04/03.
//

import UIKit
import CoreLocation
import MapKit
import SwiftUI

class SettingViewController: UIViewController, MKMapViewDelegate {
    var locationManger = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var gymAnnotation: MKPointAnnotation?
    @ObservedObject var assistant = Assistant()
    
    @IBOutlet weak var text: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest // 위치 정확도 -> 최고 수준으로
        locationManger.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() { // 위치 정보가 켜져 있는 경우
                self.locationManger.startUpdatingLocation() //위치 정보 받아오기
            } else {
                // 위치 정보가 꺼져있는 경우
            }
        }
        
        // 헬스장 정보 불러오기
        if let gymInfo = DatabaseManager.manager.loadGymInfo() {
            gymAnnotation = MKPointAnnotation()
            gymAnnotation!.coordinate = CLLocationCoordinate2DMake(gymInfo.location[0], gymInfo.location[1])
            gymAnnotation!.title = "헬스장 위치"
            gymAnnotation!.subtitle = gymInfo.gymName
            mapView.addAnnotation(gymAnnotation!)
            
            // 거리측정
            let from = CLLocation(latitude: gymInfo.location[0], longitude: gymInfo.location[1])
            let to = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
    
            print(from.distance (from: to))
        }
        
        
    }

    @IBAction func registGymButtonPressed(_ sender: UIButton) {
        
        var location = [Double]()
        location.append((locationManger.location?.coordinate.latitude)!)
        location.append((locationManger.location?.coordinate.longitude)!)
        print("헬스장 등록: \(location)")
        DatabaseManager.manager.registGym(gymName: "제이어스 짐", location: location)
        if gymAnnotation != nil {
            mapView.removeAnnotation(gymAnnotation!)
        }
        let gymInfo = DatabaseManager.manager.loadGymInfo()
        if let gymInfo = DatabaseManager.manager.loadGymInfo() {
            gymAnnotation = MKPointAnnotation()
            gymAnnotation!.coordinate = CLLocationCoordinate2DMake(gymInfo.location[0], gymInfo.location[1])
            gymAnnotation!.title = "헬스장 위치"
            gymAnnotation!.subtitle = gymInfo.gymName
            mapView.addAnnotation(gymAnnotation!)
        }
    }
    
    @IBAction func watchButtonPressed(_ sender: Any) {
        text.text = String(assistant.weight[0])
        assistant.loadWorkList(wl: "123")
    }
    
}


extension SettingViewController: CLLocationManagerDelegate {
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

