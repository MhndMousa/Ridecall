//
//  Slide.swift
//  Ridecall
//
//  Created by Muhannad Alnemer on 6/18/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//

import UIKit

class Slide: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    private var vehicle = Vehicle()
    
    
    @IBOutlet weak var reserveButton: UIButton!
    @IBAction func reserveButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Congratulation",
                                      message: "You have reserve the \(vehicle.vehicle_type) sucessfuly",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    func insertAndUpdate(vehicle: Vehicle){
        self.insert(vehicle: vehicle)
        self.updateView(withInfoOf: vehicle)
    }
    
    // Setter
    func insert(vehicle: Vehicle){
        self.vehicle = vehicle
    }
    

    // Updates the slide view with information of the vehicle
    func updateView(withInfoOf v : Vehicle) {

        do {
            let iconUrl =  try Data(contentsOf: URL(string:  v.vehicle_pic_absolute_url)!)
            self.imageView.image = UIImage(data: iconUrl)
        }catch{
            print("error parsing image")
        }
        label1.text = v.is_available ? "Available" : "Not Avaialbe"
        label1.textColor = v.is_available ?  UIColor(hex: "2ba527") : UIColor(hex: "a01919")
        label2.text = String(describing:v.remaining_mileage)
        label3.text = v.vehicle_make
        label4.text = v.license_plate_number
        self.reserveButton.layer.cornerRadius = 8
        
        reserveButtonTapped(v)
    }
    
    
    
    
    
}
