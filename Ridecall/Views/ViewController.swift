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
    let pagingView = UIPageControl()
    let scrollView = UIScrollView()
    lazy var mapView = GMSMapView()
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var infoView: UIView!
    
    // MARK:  UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = readJSONFromFile("vehicles_data")!
        for vechicle  in json  {
            print(vechicle)
            vehicles.append(Vehicle(vechicle))
        }
        slides = createSlides()
        createMap()
        configureScrollView()
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    // MARK:  Horizontal scroll
    
    func configureScrollView(){
        scrollView.delegate  = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.contentSize = CGSize(width: self.view.layer.bounds.width * 3, height: infoView.layer.bounds.height)
        scrollView.backgroundColor = .clear
        
        pagingView.numberOfPages = 3
        pagingView.currentPageIndicatorTintColor = UIColor(hex: "349134")
        pagingView.pageIndicatorTintColor = .gray
        
        infoView.addSubview(scrollView)
        infoView.addSubview(pagingView)
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.4
        infoView.layer.shadowOffset = .zero
        infoView.layer.shadowRadius = 5
        
//        gradientView.setGradientBackground(colorOne: UIColor(hex: "7eb759")!, colorTwo: UIColor(hex: "ffffff")!)
        

        
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

        //Add slides
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: self.view.layer.bounds.width * CGFloat(i), y: 0,
                                     width: self.view.layer.bounds.width, height: infoView.frame.height)
            slides[i].backgroundColor = .clear
            scrollView.addSubview(slides[i])
        }
    }
    
    func createSlides() -> [Slide] {
        var s = [Slide]()
        
        for i in 0..<3 {
            let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide.reserveButton.layer.cornerRadius = 8
            slide.vehicle = vehicles[i]
            slide.populate(vehicles[i])
            s.append(slide)
        }
        return s
    }

    
    // MARK:  Map methods
    
    func createMap(){
        
        
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

        
        view.insertSubview(mapView, at: 0)
//        view = mapv
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: infoView.topAnchor).isActive = true
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
            let size = CGSize(width: 30, height: 35)
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
            markerVehicle[car] = marker
            
            
        }
    }
    
  
    
    
    // MARK: Google Maps Delegates
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        let title = UILabel()
        let title2 = UILabel()
        let verticalStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Enlarge marker
        let img = UIImage(named: "Ridecell_icon-1")
        let size = CGSize(width: 40, height: 47)
        marker.icon = imageWithImage(image: img!, scaledToSize: size)
        
        popUpView.layer.cornerRadius = 8
        popUpView.backgroundColor = .white
        popUpView.alpha = 0.9
        
        popUpView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant:5 ).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant:-5 ).isActive = true
        verticalStack.topAnchor.constraint(equalTo: popUpView.topAnchor, constant:5 ).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor, constant:-5 ).isActive = true

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
        
    
        return popUpView
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        let img = UIImage(named: "Ridecell_icon-1")
        let size = CGSize(width: 30, height: 35)
        marker.icon = imageWithImage(image: img!, scaledToSize: size)
    }
    
    
    // MARK:  ScrollView Delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pagingView.currentPage = Int(pageIndex)
        
        print("animatedto: ", markerVehicle[vehicles[Int(pageIndex)]]!.position)
        mapView.animate(toLocation: markerVehicle[vehicles[Int(pageIndex)]]!.position)
    }
    
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
func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
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

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}
