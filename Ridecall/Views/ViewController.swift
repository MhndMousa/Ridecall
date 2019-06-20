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
    
    // MARK:  Variables

    var vehicles = [Vehicle]()
    var slides = [Slide]()
    var markerVehicle = [Vehicle:GMSMarker]()
    lazy var mapView = GMSMapView()
    
    let pageControl = UIPageControl()
    let scrollView = UIScrollView()
    @IBOutlet weak var informationContainer: UIView!
    
    // MARK:  UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Import JSON information into array of calss Vehicle.swift
        let json = readJSONFromFile("vehicles_data")!
        for vechicle  in json  {
            print(vechicle)
            vehicles.append(Vehicle(vechicle))
        }
        
        // Configure UIViews in the project
        slides = createSlides(quantity: vehicles.count)
        mapView = createMap()
        createScrollView()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    
    // MARK:  Google Maps methods
    
    func createMap() -> GMSMapView{
        
        // Initialize a camera and posiiton onto at San Fransisco
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 11.7)
         mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        
        // Configure map with style.json settings
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

        
        // Configure the mapview constraints
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
            let img = UIImage(named: "Ridecell_icon-1")
            let size = CGSize(width: 30, height: 35)
            marker.icon = imageWithImage(image: img!, scaledToSize: size)
            
            // Get the approximate address of each marker
            GMSGeocoder().reverseGeocodeCoordinate(position, completionHandler: { (res, err) in
                if let address = res?.firstResult(){
                    let lines = address.lines! as [String]
                    // Assign it to each marker
                    marker.snippet = lines.joined()
                } else{
                    // The veicle will be in the center on the map on (0 latitude, 0 longtitude) if i didn't have longtitude and latitude
                    marker.snippet = "This vehicle is missing coordinates"
                }
            })
            
            // Display marker on the map
            marker.map = mapView
            markerVehicle[car] = marker
            
            
        }
        return mapView
    }
    
  
    
    
    // MARK: Google Maps Delegates
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let informationBubbleView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        let title = UILabel()
        let title2 = UILabel()
        let verticalStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Enlarge marker
        let img = UIImage(named: "Ridecell_icon-1")
        let size = CGSize(width: 40, height: 47)
        marker.icon = imageWithImage(image: img!, scaledToSize: size)
        
        
        // Drawing the bubble over the marker on the on click
        
        informationBubbleView.layer.cornerRadius = 8
        informationBubbleView.backgroundColor = .white
        informationBubbleView.alpha = 0.9
        informationBubbleView.addSubview(verticalStack)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.leadingAnchor.constraint(equalTo: informationBubbleView.leadingAnchor, constant:5 ).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: informationBubbleView.trailingAnchor, constant:-5 ).isActive = true
        verticalStack.topAnchor.constraint(equalTo: informationBubbleView.topAnchor, constant:5 ).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: informationBubbleView.bottomAnchor, constant:-5 ).isActive = true

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
        title2.contentMode = .scaleToFill
        title2.numberOfLines = 0
        
    
        return informationBubbleView
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        let img = UIImage(named: "Ridecell_icon-1")
        let size = CGSize(width: 30, height: 35)
        marker.icon = imageWithImage(image: img!, scaledToSize: size)
    }
    
    
    // MARK:  UIScrollView Methods
    
    func createScrollView(){
        
        // This is a container that wwill hold scroll view and page controller at the bottom of screen
        informationContainer.layer.shadowColor = UIColor.black.cgColor
        informationContainer.layer.shadowOpacity = 0.4
        informationContainer.layer.shadowOffset = .zero
        informationContainer.layer.shadowRadius = 5
        informationContainer.addSubview(scrollView)
        informationContainer.addSubview(pageControl)
        
        // Configure UIScrollView dimensions and properties
        scrollView.delegate  = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.view.layer.bounds.width * 3, height: informationContainer.layer.bounds.height)
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints    = false
        scrollView.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: informationContainer.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: informationContainer.bottomAnchor).isActive = true
        
        
        // Configure UIPageControl dimensions and properties
        pageControl.numberOfPages = slides.count
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "2ba527")
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints    = false
        pageControl.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        pageControl.topAnchor.constraint(equalTo: informationContainer.topAnchor, constant: -5).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: informationContainer.centerXAnchor).isActive = true
        
        //Add slides on the scroll view with proper spacing for each
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: self.view.layer.bounds.width * CGFloat(i), y: 0,
                                     width: self.view.layer.bounds.width, height: informationContainer.frame.height)
            slides[i].backgroundColor = .clear
            scrollView.addSubview(slides[i])
        }
    }
    
    
    // Creates an array of Slide
    func createSlides(quantity num:Int) -> [Slide] {
        var s = [Slide]()
        for i in 0..<num {
            let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide.insertAndUpdate(vehicle: vehicles[i])
            s.append(slide)
        }
        return s
    }

    // MARK:  ScrollView Delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        print("animatedto: ", markerVehicle[vehicles[Int(pageIndex)]]!.position)
        mapView.animate(toLocation: markerVehicle[vehicles[Int(pageIndex)]]!.position)
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
                print("Error while parsing the data from json")
            }
        }
        
        return json
    }
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}


extension UIColor {
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

