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
    var title: NSAttributedString
    var region: CLCircularRegion?
}


class LocationOptions {
    let london : CLLocationCoordinate2D = CLLocationCoordinate2DMake(51.512433, -0.116978)
    var options: [LocationOption] = []
    let live : [NSAttributedString.Key: Any]
    let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
    let grey = [NSAttributedString.Key.foregroundColor: UIColor.gray]
    let findingLocation: NSAttributedString!
    let centralLondon: NSAttributedString!
    let allLondon: NSAttributedString!

    
    init(color: UIColor){
        live = [NSAttributedString.Key.foregroundColor: color]
        findingLocation = NSAttributedString(string: "Finding Location...", attributes: grey)
        centralLondon = NSAttributedString(string: "Central London", attributes: black)
        allLondon = NSAttributedString(string: "All London", attributes: black)
        options.append(LocationOption(title: findingLocation ,region: nil))
        options.append(LocationOption(title: centralLondon ,region: CLCircularRegion(center: london, radius: 4000, identifier: "Central London")))
        options.append(LocationOption(title: allLondon, region: nil))
    }
    
    func updateOptions(place: CLPlacemark?){
        var placeName = place?.subLocality
        if(placeName == nil){
            placeName = place?.locality
        }
        if(placeName == nil) {
            options[0].title = NSAttributedString(string: "Finding your location...", attributes: grey)
            options[0].region = nil
        } else {
        options[0].title = NSAttributedString(string: "⊙ \(placeName!)", attributes: live)
        options[0].region = CLCircularRegion(center: place!.location!.coordinate, radius: 4000, identifier: "Your Location")
        }
    }


}
