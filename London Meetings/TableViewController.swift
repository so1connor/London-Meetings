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

class MeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var meetingAddress: UILabel!
    @IBOutlet weak var meetingDuration: UILabel!
    @IBOutlet weak var meetingTime: UILabel!
}

let days = ["Today", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]


class TableViewController: UITableViewController{
    @IBOutlet weak var todayButton: UIBarButtonItem!
    var meetingRow : Int?

    
    func updateDay(day : Int){
        todayButton.title = days[day]
        if(day == 0){
            let today = Date()
            let calendar = Calendar.current
            let myday = calendar.component(.weekday, from: today)
            let hour = calendar.component(.hour, from: today)
            let minute = calendar.component(.minute, from: today)
            let minutes = hour * 60 + minute
            print(myday)
            print(minutes)
            meetings = original.filter {$0.day == myday}
            meetings = meetings.filter {$0.time > minutes}
        } else {
            meetings = original.filter {$0.day == day - 1}
        }
    
        meetings = meetings.sorted {$0.time < $1.time}
        self.tableView.reloadData()
    }

    var original: [Meeting] = []
    var meetings: [Meeting] = []
//        Meeting(title: "Soho Sober", address: "24 Dean Street", duration: 60),
//        Meeting(title: "Newcomers", address: "Christ Church", duration: 90),
//        Meeting(title: "Living in the Solution you silly bastards who drink too much", address: "Hop Gardens, Charing Cross Road near Covent Garden tube and Leicester Square", duration: 60)]
    var region: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(51.512433, -0.116978), radius: CLLocationDistance(4000), identifier: "London")
    
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
        original = original.filter{
            let location = CLLocationCoordinate2DMake($0.lat,$0.lng)
            return region.contains(location)
        }
        updateDay(day: 0)
        //meetings = original.filter {$0.day == 0}.sorted {$0.time < $1.time}

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
