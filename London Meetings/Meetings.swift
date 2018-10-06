//
//  Meetings.swift
//  London Meetings
//
//  Created by Steve O'Connor on 07/08/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import Foundation
import CoreLocation

struct Meeting: Codable{
    var title: String
    var address: String
    var duration: Int
    var time: Int
    var postcode: String
    var code: Int
    var lat: Double
    var lng: Double
    var day: Int
}

protocol TableUpdateDelegate: class {
    func update()
}



class Meetings : NSObject {
    weak var delegate: TableUpdateDelegate?
    var list: [Meeting] = []
    private var original: [Meeting] = []
    private var theDay: Int = 0
    private var today: Bool = false
    private var theRegion: CLCircularRegion?
    private var theMinutes: Int = 0
    var timer: Timer?
    
    func loadMeetings(_ table: TableUpdateDelegate) {
        if let path = Bundle.main.path(forResource: "meetings", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                do {
                    original = try decoder.decode([Meeting].self, from: data)
                    print("original", original.count)
                    delegate = table
                } catch {
                    throw error
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setDay(day: Int){
        print("set day", day)
        today = false
        theDay = day - 1
        setMeetings()
    }
    
    func setToday(){
        print("set today")
        today = true
        setMeetings()
    }
    
    func setRegion(region: CLCircularRegion?){
        print("set region", region as Any)
        theRegion = region
        setMeetings()
    }
    
    func setMeetings(){
        if(today){
            updateToday()
            if (timer != nil){
                timer!.invalidate()
            }
        }
        filterMeetings()
        sortByTime()
        if(today && list.count > 0){
            let interval = Double(list[0].time - theMinutes) * 60
            print("timer scheduled for",interval)
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (Timer) in
                print("timer event")
                self.setMeetings()
            })
        }
        delegate?.update()
    }
    
    func updateToday(){
        print("today", today)
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let minutes = hour * 60 + minute
        theDay = day - 1
        theMinutes = minutes
    }
    
    private func filterMeetings(){
        list = original.filter{
            let location = CLLocationCoordinate2DMake($0.lat,$0.lng)
            var result = false
            if($0.day == theDay){
                result = true
                if(theRegion != nil){
                    result = theRegion!.contains(location)
                }
                if(today && result){
                    result = $0.time > theMinutes
                }
            return result
            }
        return false
        }
    }
    
    private func sortByTime(){
        list = list.sorted {$0.time < $1.time}
    }

}
