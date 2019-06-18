//
//  ViewController.swift
//  Ridecall
//
//  Created by Muhannad Alnemer on 6/17/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var vehicles = [Vehicle]()
    override func viewDidLoad() {
        super.viewDidLoad()
        createMap()
        let json = readJSONFromFile("vehicles_data")!
//        jsonTwo()
        for vechicle  in json  {
            print(vechicle)
            vehicles.append(Vehicle(vechicle))
        }
        
        print(vehicles)
    }
    
    func createMap() {
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 11.7)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
     func readJSONFromFile(_ fileName: String) ->  [[String: Any]]?
    {
        var json:  [[String: Any]]?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data) as! [[String : Any]]
            } catch {
                // Handle error here
            }
        }
        return json
    }
    
//    func jsonTwo() -> [[String: Any]]{
//        let url = Bundle.main.url(forResource: "vehicles_data", withExtension: "json")!
//        let data = try! Data(contentsOf: url)
//        let JSON = try! JSONSerialization.jsonObject(with: data, options: [])
//        print(".........." , JSON , ".......")
//        if let jsonArray = JSON as? [[String: Any]] {
//            for item in jsonArray {
//                let brand = item["license_plate_number"] as? String ?? "No licence" //A default value
//                print("=======",brand,"=======")
//            }
//        }
//    }
    


}

