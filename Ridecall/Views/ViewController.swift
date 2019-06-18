//
//  ViewController.swift
//  Ridecall
//
//  Created by Muhannad Alnemer on 6/17/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController,GMSMapViewDelegate {

    var vehicles = [Vehicle]()
    @IBOutlet weak var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = readJSONFromFile("vehicles_data")!
    
        for vechicle  in json  {
            print(vechicle)
            vehicles.append(Vehicle(vechicle))
        }
    
        createMap()
        configInfoView()
        
    }
    
    
    // MARK:  Horizontal scroll

    func configInfoView(){
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: infoView.layer.bounds.width * 3, height: infoView.layer.bounds.height)
        scrollView.backgroundColor = .blue
        
        
        let pagingView = UIPageControl()
        pagingView.numberOfPages = 3
        pagingView.currentPageIndicatorTintColor = .green
        
        
        infoView.addSubview(scrollView)
        infoView.addSubview(pagingView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints    = false
        scrollView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: infoView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: infoView.bottomAnchor).isActive = true
        
        pagingView.translatesAutoresizingMaskIntoConstraints    = false
        pagingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        pagingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        pagingView.topAnchor.constraint(equalTo: infoView.topAnchor).isActive = true
        pagingView.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true

        
    }


    
    // MARK:  Maps
    func createMap(){
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 11.7)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view.insertSubview(mapView, at: 0)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.delegate = self
        

        // Creates a marker in the center of the map.
        for car in vehicles {
            let position = CLLocationCoordinate2DMake(car.lat, car.lng)
            let marker = GMSMarker(position: position)
            marker.title = car.license_plate_number
            GMSGeocoder().reverseGeocodeCoordinate(position, completionHandler: { (res, err) in
                if let address = res?.firstResult(){
                    let lines = address.lines! as [String]
                    marker.snippet = lines.joined()
                    print(lines.joined())
                } else{
                    marker.snippet = "This vehicle is missing coordinates"
                }
            })
            marker.map = mapView
        }
    }
    
  
    
    
    // MARK: Google Maps Delegates
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let v = UIView()
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 1))
        let title2 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 1))
        let verticalStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        v.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant:5 ).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant:5 ).isActive = true
        verticalStack.topAnchor.constraint(equalTo: v.topAnchor, constant:5 ).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant:5 ).isActive = true
        
        verticalStack.addSubview(title)
        title.text = marker.title
        title.font = UIFont(name: "HelveticaNeue", size: 12)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor).isActive = true
        title.topAnchor.constraint(equalTo: verticalStack.topAnchor).isActive = true
        
        verticalStack.addSubview(title2)
        title2.text = marker.snippet
        title2.font = UIFont(name: "HelveticaNeue", size: 12)
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor).isActive = true
        title2.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor).isActive = true
        title2.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        title2.bottomAnchor.constraint(equalTo: verticalStack.bottomAnchor).isActive = true
        title2.heightAnchor.constraint(equalTo: title.heightAnchor).isActive = true
        
        v.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
        v.layer.cornerRadius = 8
        
        v.backgroundColor = .white
        return v
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
  
    
    // MARK: Helpers
    func readJSONFromFile(_ fileName: String) ->  [[String: Any]]?
    {
        var json:  [[String: Any]]?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data) as? [[String : Any]]
            } catch {
                // Handle error here
            }
        }
        
        return json
    }
    
    
    
    

}

