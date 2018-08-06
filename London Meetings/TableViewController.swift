//
//  TableViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 24/07/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
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

struct LocationOption {
    var live: Bool
    var distance: CLLocationDistance
    var title: NSAttributedString
    var reuseIdentifier: String
}

class MeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var meetingAddress: UILabel!
    @IBOutlet weak var meetingDuration: UILabel!
    @IBOutlet weak var meetingTime: UILabel!
}

let days = ["Today", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]


class TableViewController: UITableViewController, CLLocationManagerDelegate{
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var todayButton: UIBarButtonItem!
    var locationManager : CLLocationManager!
    var locationFirst : Bool = true
    var currentLocation :CLLocation?
    //let blackAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
    let centralLondon = LocationOption(live: false, distance: 5000, title: NSAttributedString(string: "Central London", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black]), reuseIdentifier: "DefaultLocationCell")
    let allLondon = LocationOption(live: false, distance: 10000, title: NSAttributedString(string: "All London", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black]), reuseIdentifier: "DefaultLocationCell")
    var locationOptions : [LocationOption] = []
    var theDay : Int = 0
    var timer : Timer?
    let london : CLLocationCoordinate2D = CLLocationCoordinate2DMake(51.512433, -0.116978)
    var meetingRow : Int?
    var original: [Meeting] = []
    var localmeetings: [Meeting] = []
    var meetings: [Meeting] = []
    var region: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(51.512433, -0.116978), radius: CLLocationDistance(4000), identifier: "London")
    
    func updateTime(){
        let today = Date()
        let calendar = Calendar.current
        let myday = calendar.component(.weekday, from: today)
        let hour = calendar.component(.hour, from: today)
        let minute = calendar.component(.minute, from: today)
        let minutes = hour * 60 + minute
//        print(myday)
//        print(minutes)
        let todaysmeetings = localmeetings.filter {$0.day == myday - 1}
        meetings = todaysmeetings.filter {$0.time > minutes}
        if(meetings.count != 0){
            timer = Timer.scheduledTimer(withTimeInterval: Double(meetings[0].time - minutes), repeats: true, block: { (Timer) in
            self.updateDay(day: self.theDay)
            })
        }
    }
    
    func updateDay(day : Int){
        todayButton.title = days[day]
        theDay = day
        if(day == 0){
            updateTime()
        } else {
            meetings = localmeetings.filter {$0.day == day - 1}
        }
        meetings = meetings.sorted {$0.time < $1.time}
        self.tableView.reloadData()
        print("meetings", meetings.count)
    }
    
    func setLocationOption(option: LocationOption){
        locationButton.title = option.title.string
        if(option.live){
            region = CLCircularRegion(center: (currentLocation?.coordinate)!, radius: option.distance, identifier: "Live London")
            
        } else {
            region = CLCircularRegion(center: london, radius: option.distance, identifier: "Central London")

        }
        localmeetings = original.filter{
            let location = CLLocationCoordinate2DMake($0.lat,$0.lng)
            return region.contains(location)
        }
        updateDay(day: theDay)
    }
    
    func updateLocationOptions(){
        if(currentLocation != nil){
            let blueAttribute = [NSAttributedStringKey.foregroundColor: UIColor.blue]
            let blackAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
            let geocoder = CLGeocoder()
            //locationManager.stopUpdatingLocation()
            print("calling geocoder")
            geocoder.reverseGeocodeLocation(currentLocation!) { (places, error) in
                if(error == nil){
                    var list: [LocationOption] = []
                    if(places != nil){
                        let place: CLPlacemark = places![0]
                        let title = NSMutableAttributedString(string: "⊙", attributes: blueAttribute)
                        title.append(NSAttributedString(string: " \(place.subLocality ?? "Your Location")", attributes: blackAttribute))
                        list.append(LocationOption(live: true, distance: 4000, title: title, reuseIdentifier: "LiveLocationCell"))
                    }
                    list.append(self.centralLondon)
                    list.append(self.allLondon)
                    self.locationOptions = list
                } else {
                    //print(error!)
                }
                //self.locationManager.startUpdatingLocation()
            }
//            for i in 1...6 {
//                let title = NSMutableAttributedString(string: "⊙", attributes: blueAttribute)
//                title.append(NSAttributedString(string: " \(i) km", attributes: blackAttribute))
//                locationOptions.append(LocationOption(live: true, distance: CLLocationDistance(i * 1000), title: title, reuseIdentifier: "LiveLocationCell"))
//            }
        } else {
        locationOptions = [centralLondon,allLondon]
        }
    //setLocationOption(option: <#T##LocationOption#>)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(timer != nil){
            timer!.invalidate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "meetings", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                do {
                    original = try decoder.decode([Meeting].self, from: data)
                    //print(meetings)
                } catch {
                    print(error)
                }
            } catch {
                // handle error
            }
        }
        setLocationOption(option: centralLondon)

        self.clearsSelectionOnViewWillAppear = false
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetings.count
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
                nextViewController.meetings = meetings
                nextViewController.theDay = theDay
            }
        }
        if(segue.identifier == "locationSegue"){
            print("locationSegue")
            if let nextViewController = segue.destination as? LocationTableViewController{
                nextViewController.locationOptions = self.locationOptions
            }
        }
    }
    
//    @objc func buttonPress(sender: UIButton){
//        //print("pressed", sender.tag)
//        print(meetings[sender.tag].postcode)
//        meeting = meetings[sender.tag]
//        self.performSegue(withIdentifier: "mapSegue", sender:sender)
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath) as! MeetingTableViewCell
        
        let meeting = meetings[indexPath.row]
        
        cell.meetingTitle?.text = meeting.title// + "\(meeting.day)"
        cell.meetingAddress?.text = meeting.address + " " + meeting.postcode
        cell.meetingDuration?.text = String(meeting.duration)
        let time = meeting.time
        cell.meetingTime?.text = String(format:"%02d:%02d",time/60,time%60)
//        cell.meetingPostcode?.setTitle(meeting.postcode, for: .normal)
//        cell.meetingPostcode.tag = indexPath.row
//        cell.meetingPostcode.addTarget(self, action: #selector(TableViewController.buttonPress(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations objects: [CLLocation]) {
        print("update location")
        let location = objects.last!
        let accuracy = Double(location.horizontalAccuracy)
        if(accuracy > 0){
            currentLocation = location
            updateLocationOptions()
//            if(locationFirst){
//                locationManager.stopUpdatingLocation()
//                locationManager.startMonitoringSignificantLocationChanges()
//                locationFirst = false
//                }
        } else {
            print("location was invalid")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location authorization status is", status.rawValue)
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        updateLocationOptions()
//        if(CLLocationManager.significantLocationChangeMonitoringAvailable()){
//            locationManager.startMonitoringSignificantLocationChanges()
//            print("significant changes available")
//        } else {
            locationManager.startUpdatingLocation()
//        }
        
    }

    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }


    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
