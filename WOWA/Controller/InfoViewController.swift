//
//  InfoViewController.swift
//  WOWA
//
//  Created by 오예준 on 2023/05/16.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class InfoViewController: UIViewController, MKMapViewDelegate {
    
    var locationManger = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
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
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스가 켜져있는 경우 ")
                self.locationManger.startUpdatingLocation() //위치 정보 받아오기
            } else {
                print("위치 서비스 꺼져있는 경우")
            }
        }
        let gymInfo = DatabaseManager.manager.loadGymInfo()!
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(gymInfo.location[0], gymInfo.location[1])
        annotation.title = "헬스장 위치"
        annotation.subtitle = gymInfo.gymName
        mapView.addAnnotation(annotation)
        
        let from = CLLocation(latitude: gymInfo.location[0], longitude: gymInfo.location[1])
        let to = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
        
        print(from.distance(from: to))
        
    }
    
    
    @IBAction func registGymButtonPressed(_ sender: UIButton) {
        print("헬스장 등록")
        var location = [Double]()
        location.append(35.8844652)
        location.append(128.613920)
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
