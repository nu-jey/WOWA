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

class InfoViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManger = CLLocationManager()
    var gymAnnotation: MKPointAnnotation?
    var settingInfo: SettingInfo?
    var tableViewData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var setTextField: UILabel!
    @IBOutlet weak var repTextField: UILabel!
    
    @IBOutlet weak var stepperRep: UIStepper!
    @IBOutlet weak var stepperSet: UIStepper!
    
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
        
        // tableView
        tableView.dataSource = self
        tableView.delegate = self
        loadSettingInfo()
    }
    
    @IBAction func registGymButtonPressed(_ sender: UIButton) {
        // 위치 정보 불러오기 - 현재 위치
        var location = [Double]()
        location.append((locationManger.location?.coordinate.latitude)!)
        location.append((locationManger.location?.coordinate.longitude)!)
        
        let alert = UIAlertController(title: "운동 완료", message: "무게 등록", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [self] (ok) in
            // realm에 정보 저장
            DatabaseManager.manager.registGym(gymName: alert.textFields![0].text!, location: location)
            if gymAnnotation != nil {
                mapView.removeAnnotation(gymAnnotation!)
            }
            
            // 지도에 헬스장 어노테이션 추가
            let gymInfo = DatabaseManager.manager.loadGymInfo()
            if let gymInfo = DatabaseManager.manager.loadGymInfo() {
                gymAnnotation = MKPointAnnotation()
                gymAnnotation!.coordinate = CLLocationCoordinate2DMake(gymInfo.location[0], gymInfo.location[1])
                gymAnnotation!.title = "헬스장 위치"
                gymAnnotation!.subtitle = gymInfo.gymName
                mapView.addAnnotation(gymAnnotation!)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancle", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(add)
        alert.addTextField()
        alert.textFields![0].placeholder = "헬스장 이름을 작성해주세요"
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func removeGymButtonPressed(_ sender: UIButton) {
        print("삭제")
        DatabaseManager.manager.deleteGymInfo()
        if gymAnnotation != nil {
            mapView.removeAnnotation(gymAnnotation!)
        }
    }
    
    @IBAction func stepperSetPressed(_ sender: UIStepper) {
        setTextField.text = Int(sender.value).description
    }
    
    @IBAction func stepperRepPressed(_ sender: UIStepper) {
        repTextField.text = Int(sender.value).description
    }
    
    @IBAction func saveSetRepInfoButtonPressed(_ sender: UIButton) {
        DatabaseManager.manager.saveSettingInfoSetAndRep(set: Int(setTextField.text!)!, rep: Int(repTextField.text!)!)
    }
    
    
    @IBAction func addBodyPartButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "운동 부위", message: "추가", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [self] (ok) in
            let addPart = alert.textFields![0].text!
            if DatabaseManager.manager.isPossibleBodyPart(inputBodyPart: addPart) {
                tableViewData.append(addPart)
                DatabaseManager.manager.saveSettingInfoBodyPart(bodyPart: tableViewData)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                // 중복 처리
            }
        }
        
        let cancel = UIAlertAction(title: "Cancle", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(add)
        alert.addTextField()
        alert.textFields![0].placeholder = "추가할 운동 부위를 작성해주세요"
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadSettingInfo() {
        settingInfo = DatabaseManager.manager.loadSettingInfo()
        stepperSet.value = Double(settingInfo!.set)
        setTextField.text = String(settingInfo!.set)
        stepperRep.value = Double(settingInfo!.rep)
        repTextField.text = String(settingInfo!.rep)
        tableViewData = settingInfo!.bodyPart.map { $0 }
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

extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = tableViewData[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print(indexPath.row)
            self.tableViewData.remove(at: indexPath.row)
            DatabaseManager.manager.saveSettingInfoBodyPart(bodyPart: self.tableViewData)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
}
