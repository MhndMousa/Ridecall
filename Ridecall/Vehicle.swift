//
//  Vehicle.swift
//  Ridecall
//
//  Created by Muhannad Alnemer on 6/17/19.
//  Copyright © 2019 Muhannad Alnemer. All rights reserved.
//

import Foundation

class Vehicle: NSObject {
    var id : NSNumber
    var is_active: Bool
    var is_available: Bool
    var lat: Double
    var license_plate_number : String
    var lng : Double
    var pool : String
    var remaining_mileage :NSNumber
    var remaining_range_in_meters : NSNumber
    var transmission_mode : String
    var vehicle_make : String
    var vehicle_pic :String
    var vehicle_pic_absolute_url : String
    var vehicle_type : String
    var vehicle_type_id : NSNumber

    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as! NSNumber
        self.is_active = dictionary["is_active"] as! Bool
        self.is_available = dictionary["is_available"] as! Bool
        self.lat = dictionary["lat"] as? Double ?? 0.0
        self.license_plate_number = dictionary["license_plate_number"] as! String
        self.lng  = dictionary["lng"] as? Double ?? 0.0
        self.pool  = dictionary["pool"] as! String
        self.remaining_mileage = dictionary["remaining_mileage"] as? NSNumber ?? 0
        self.remaining_range_in_meters = dictionary["remaining_range_in_meters"] as? NSNumber ?? 0
        self.transmission_mode = dictionary["transmission_mode"] as? String ?? "no_entry"
        self.vehicle_make  = dictionary["vehicle_make"] as! String
        self.vehicle_pic  = dictionary["vehicle_pic"] as! String
        self.vehicle_pic_absolute_url  = dictionary["vehicle_pic_absolute_url"] as! String
        self.vehicle_type  = dictionary["vehicle_type"] as! String
        self.vehicle_type_id  = dictionary["vehicle_type_id"] as? NSNumber ?? 0
    }

}
