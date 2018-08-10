//
//  LocationOptions.swift
//  London Meetings
//
//  Created by Steve O'Connor on 07/08/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct LocationOption {
    var live: Bool
    var title: NSAttributedString
    var region: CLCircularRegion?
    var reuseIdentifier: String
}


class LocationOptions {
    static let london : CLLocationCoordinate2D = CLLocationCoordinate2DMake(51.512433, -0.116978)
    var options: [LocationOption] = []
    let centralLondon : LocationOption
    let allLondon : LocationOption
    let blue = [NSAttributedStringKey.foregroundColor: UIColor.blue]
    let black = [NSAttributedStringKey.foregroundColor: UIColor.black]

    
    init(){
        centralLondon = LocationOption(live: false, title: NSAttributedString(string: "Central London", attributes: black),region: CLCircularRegion(center: LocationOptions.london, radius: 4000, identifier: "Central London"), reuseIdentifier: "DefaultLocationCell")
        allLondon = LocationOption(live: false, title: NSAttributedString(string: "All London", attributes: black), region: nil, reuseIdentifier: "DefaultLocationCell")
        updateLocationOptions(location: nil)
    }


    func updateLocationOptions(location: CLLocation?){
        if(location != nil){
            let geocoder = CLGeocoder()
            
            print("calling geocoder")
            geocoder.reverseGeocodeLocation(location!) { (places, error) in
                if(error == nil){
                    var list: [LocationOption] = []
                    if(places != nil){
                        let place: CLPlacemark = places![0]
                        let title = NSMutableAttributedString(string: "⊙", attributes: self.blue)
                        title.append(NSAttributedString(string: " \(place.subLocality ?? "Your Location")", attributes: self.black))
                        list.append(LocationOption(live: true, title: title, region: CLCircularRegion(center: location!.coordinate, radius: 4000, identifier: "Your Location"), reuseIdentifier: "LiveLocationCell"))
                    }
                    list.append(self.centralLondon)
                    list.append(self.allLondon)
                    self.options = list
                } else {
                    print(error!)
                }
            }
        } else {
           options = [centralLondon,allLondon]
        }
    }
}
