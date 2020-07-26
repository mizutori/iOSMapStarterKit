//
//  ViewController.swift
//  iOSAppleMapStarterKit
//
//  Created by Takamitsu Mizutori on 2020/07/25.
//  Copyright © 2020 Takamitsu Mizutori. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var locationManager:CLLocationManager!

    var didStartUpdatingLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    override func viewDidAppear(_ animated: Bool) {
        initLocation()
    }

    private func initLocation() {
        if !CLLocationManager.locationServicesEnabled() {
            print("No location service")
            return
        }

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //ユーザーが位置情報の許可をまだしていないので、位置情報許可のダイアログを表示する
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showPermissionAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        @unknown default:
            break
        }
    }


    func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        } else if status == .restricted || status == .denied {
            showPermissionAlert()
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            updateMap(currentLocation: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    // MARK: - Map
    private func updateMap(currentLocation: CLLocation){
        print("Location:\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")

        let now = Date()
        let delta = now.timeIntervalSince(currentLocation.timestamp)
        print("This location was obtianed \(delta) seconds ago")
        if delta > 60{
            print("This location is too old")
            return
        }

        let horizontalRegionInMeters: Double = 5000

        let width = self.mapView.frame.width
        let height = self.mapView.frame.height

        let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInMeters))

        let region:MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                           latitudinalMeters: verticalRegionInMeters,
                                                           longitudinalMeters: horizontalRegionInMeters)

        mapView.setRegion(region, animated: true)

    }

    // MARK - Utility
    private func showPermissionAlert(){
        //位置情報が制限されている/拒否されている
        let alert = UIAlertController(title: "位置情報の取得", message: "設定アプリから位置情報の使用を許可して下さい。", preferredStyle: .alert)
        let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(goToSetting)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

