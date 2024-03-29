//
//  TableViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 24/07/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
import CoreLocation


class MeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var meetingAddress: UILabel!
    @IBOutlet weak var meetingDuration: UILabel!
    @IBOutlet weak var meetingTime: UILabel!
}

let days = ["Today", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

class TableViewController: UITableViewController, CLLocationManagerDelegate, TableUpdateDelegate{
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var dayButton: UIBarButtonItem!
    var meetings : Meetings = Meetings()
    var locationManager : CLLocationManager!
    var locationOptions = LocationOptions()
    var meetingRow : Int?
    var locationIndex: Int = 0
    
    func update(){
        self.tableView.reloadData()
    }

    
    func setDay(day : Int){
        dayButton.title = days[day]
        if(day == 0){
            meetings.setToday()
        } else {
            meetings.setDay(day: day)
        }
    }
    
    func setLocationOption(index: Int){
        locationIndex = index
        let option = locationOptions.options[index]
        locationButton.title = option.title
        meetings.setRegion(region: option.region)
    }
    
    
    @objc func willEnterForeground(){
        print("will enter foreground")
        meetings.setMeetings()
    }
    
    @objc func didEnterBackground(){
        print("did enter background")
        if(meetings.timer != nil){
            meetings.timer!.invalidate()
        }
    }

    @objc func didBecomeActive(){ print("did become active")}
    @objc func willResignActive(){print("will resign active")}
    @objc func didFinishLaunching(){print("did finish launching")}


    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        meetings.loadMeetings(self)
        
        setLocationOption(index: locationIndex)
        meetings.setToday()

        self.clearsSelectionOnViewWillAppear = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetings.list.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row",indexPath.row)
        meetingRow = indexPath.row
        self.performSegue(withIdentifier: "mapSegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue"{
            if let nextViewController = segue.destination as? MapViewController{
                nextViewController.meetingRow = meetingRow
                nextViewController.meetings = self.meetings.list
                //nextViewController.theDay = theDay
            }
        }
        if(segue.identifier == "locationSegue"){
            print("locationSegue")
            if let nextViewController = segue.destination as? LocationTableViewController{
                nextViewController.locationOptions = self.locationOptions
            }
        }
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingTableViewCell
        
        let meeting = meetings.list[indexPath.row]
        
        cell.meetingTitle?.text = meeting.title// + "\(meeting.day)"
        cell.meetingAddress?.text = meeting.address + " " + meeting.postcode
        cell.meetingDuration?.text = String(meeting.duration)
        let time = meeting.time
        cell.meetingTime?.text = String(format:"%02d:%02d",time/60,time%60)
        return cell
    }
    
    func updateLocationOptions(location: CLLocation?){
        if(location != nil){
            let geocoder = CLGeocoder()
            
            print("calling geocoder")
            geocoder.reverseGeocodeLocation(location!) { (places, error) in
                guard let place = places?[0] else {
                    print(error!)
                    return
                }
//                print("country",place.country)
//                print("name", place.name)
//                print("locality", place.locality)
//                print("sublocality", place.subLocality)
//                print("area",place.administrativeArea)
//                print("subarea",place.subAdministrativeArea)
//                print("road",place.thoroughfare)
//                print("subroad", place.subThoroughfare)
                self.locationOptions.updateOptions(place: place)
                self.setLocationOption(index: self.locationIndex)
            }
        } else {
            locationOptions.updateOptions(place: nil)
            setLocationOption(index: locationIndex)
        }
    }

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations objects: [CLLocation]) {
        print("update location")
        let location = objects.last!
        let accuracy = Double(location.horizontalAccuracy)
        if(accuracy > 0){
            print(location)
            updateLocationOptions(location: location)
        } else {
            print("location was invalid")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location authorization status is", status.rawValue)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }


    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
