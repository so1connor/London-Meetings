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

class TableViewController: UITableViewController, CLLocationManagerDelegate{
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var todayButton: UIBarButtonItem!
    var meetings : Meetings = Meetings()
    var locationManager : CLLocationManager!
    var currentLocation :CLLocation?
    var locationOptions : LocationOptions = LocationOptions()
    var meetingRow : Int?
//    var theDay: Int = 0

    
    func setDay(day : Int){
        todayButton.title = days[day]
        if(day == 0){
            meetings.setToday()
        } else {
            meetings.setDay(day: day)
        }
        self.tableView.reloadData()
    }
    
    func setLocationOption(option: LocationOption){
        locationButton.title = option.title.string
        meetings.setRegion(region: option.region)
        self.tableView.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if(meetings.timer != nil){
            meetings.timer!.invalidate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //meetings.setToday()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        meetings.loadMeetings()
        
        setLocationOption(option: locationOptions.options[0])
        meetings.setToday()
//        setDay(day: theDay)

        self.clearsSelectionOnViewWillAppear = true
        
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
            locationOptions.updateLocationOptions(location: location)
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
