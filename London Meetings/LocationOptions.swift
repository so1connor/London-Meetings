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
    var title: String
    var region: CLCircularRegion?
}


class LocationOptions {
    let london : CLLocationCoordinate2D = CLLocationCoordinate2DMake(51.512433, -0.116978)
    var options: [LocationOption] = []
    let findingLocation = "Finding Location..."
    let centralLondon = "Central London"
    let allLondon = "All London"

    
    init(){
        options.append(LocationOption(title: findingLocation ,region: nil))
        options.append(LocationOption(title: centralLondon ,region: CLCircularRegion(center: london, radius: 5000, identifier: "Central London")))
        options.append(LocationOption(title: allLondon, region: nil))
    }
    
    func updateOptions(place: CLPlacemark?){
        var placeName = place?.subLocality
        if(placeName == nil){
            placeName = place?.locality
        }
        if(placeName == nil) {
            options[0].title = findingLocation
            options[0].region = nil
        } else {
            if(options[0].region?.identifier == placeName!){
                return
            }
        options[0].title = "⊙ \(placeName!)"
        options[0].region = CLCircularRegion(center: place!.location!.coordinate, radius: 4000, identifier: placeName!)
        }
    }


}
