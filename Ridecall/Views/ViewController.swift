//
//  ViewController.swift
//  Ridecall
//
//  Created by Muhannad Alnemer on 6/17/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//
import Foundation
import UIKit
import GoogleMaps

class ViewController: UIViewController,GMSMapViewDelegate,UIScrollViewDelegate {
    
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
        scrollView.showsVerticalScrollIndicator = true
        
        scrollView.contentSize = CGSize(width: infoView.layer.bounds.width * 3, height: infoView.layer.bounds.height)
        scrollView.backgroundColor = .blue
        
        let pagingView = UIPageControl()
        pagingView.numberOfPages = 3
        pagingView.currentPageIndicatorTintColor = .green
//        pagingView .
        
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


    
    // MARK:  Map methods
    func createMap(){
        // Creates a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 11.7)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // config map
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
      
        
        
        
        view.insertSubview(mapView, at: 0)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.delegate = self
        
        
        
        
        
        
        
        

        // Creates markers in on the map.
        for car in vehicles {
            let position = CLLocationCoordinate2DMake(car.lat, car.lng)
            let marker = GMSMarker(position: position)
            
            // Assign each marker the licence plate of the car
            marker.title = car.license_plate_number
            
//            marker.icon = UIImage(named: "Ridecell_icon 50x-1")
            let img = UIImage(named: "Ridecell_icon-1")
            let size = CGSize(width: 35, height: 41)
            marker.icon = imageWithImage(image: img!, scaledToSize: size)
//            marker.iconView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
//
//            do {
//                let iconUrl =  try Data(contentsOf: URL(string:  car.vehicle_pic_absolute_url)!)
//                marker.icon = UIImage(data: iconUrl)
//            }
//            catch  {
//                print("error")
//            }
            
            
            // Get the approximate address of each marker
            GMSGeocoder().reverseGeocodeCoordinate(position, completionHandler: { (res, err) in
                if let address = res?.firstResult(){
                    //
                    let lines = address.lines! as [String]
                    marker.snippet = lines.joined()
                } else{
                    // The veicle will be in the center on the map on (0 latitude, 0 longtitude)
                    marker.snippet = "This vehicle is missing coordinates"
                }
            })
            
            // Display marker on the map
            marker.map = mapView
        }
    }
    
  
    
    
    // MARK: Google Maps Delegates
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
//        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
//        let title2 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        let title = UILabel()
        let title2 = UILabel()
        let verticalStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        title2.contentMode = .scaleToFill
        title2.numberOfLines = 0
        
        v.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant:5 ).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant:-5 ).isActive = true
        verticalStack.topAnchor.constraint(equalTo: v.topAnchor, constant:5 ).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant:-5 ).isActive = true

        verticalStack.addSubview(title)
        title.text = marker.title
        title.font = UIFont(name: "HelveticaNeue", size: 11)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor).isActive = true
        title.topAnchor.constraint(equalTo: verticalStack.topAnchor).isActive = true
        
        verticalStack.addSubview(title2)
        title2.text = marker.snippet
        title2.font = UIFont(name: "HelveticaNeue-Thin", size: 11)
        title2.translatesAutoresizingMaskIntoConstraints = false
        title2.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor).isActive = true
        title2.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor).isActive = true
        title2.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        title2.bottomAnchor.constraint(equalTo: verticalStack.bottomAnchor).isActive = true
        
        v.layer.cornerRadius = 8
//        v.layoutIfNeeded()
//        verticalStack.layoutIfNeeded()

        
        
        // Add blur behind the view
        
//        let blurEffect = UIBlurEffect(style: .extraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = v.bounds
////        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.layer.cornerRadius = 8
//        v.insertSubview(blurEffectView, at: 0)
//
        
        
        v.backgroundColor = .white
        v.alpha = 0.9
        return v
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
  
    
    // MARK:  ScrollView Delegates
    
    
    

    
    
    
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

func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

extension UIColor {
    
    // MARK: - Initialization
    
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
        
    }
    
    
    
}
