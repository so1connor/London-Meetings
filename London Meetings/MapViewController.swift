//
//  MapViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 01/08/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //@IBOutlet weak var todayButton: UIBarButtonItem!
    
    @IBOutlet weak var meetingAddress: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var meetingTime: UILabel!
    //@IBOutlet weak var meetingAddress: UILabel!
    @IBOutlet weak var meetingDuration: UILabel!
    var meetingRow : Int?
    var meetings : [Meeting]?
    var theDay : Int = 0
    let days = ["Today", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var currentRow = 0
    var annotation = MKPointAnnotation()
    
    @IBAction func previousAction(_ sender: Any) {
        if(meetingRow != nil){
            if(meetingRow == (meetings?.count)! - 1){
                nextButton.isEnabled = true
            }
            if(meetingRow! > 0){
                meetingRow! -= 1
                setMeeting()
            }
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if(meetingRow != nil){
            if(meetingRow == 0){
                previousButton.isEnabled = true
            }
            if(meetingRow! < (meetings?.count)!){
                meetingRow! += 1
                setMeeting()
                }

        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isZoomEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func setMeeting(){
        if(meetingRow != nil){
            if(meetingRow == 0){
                previousButton.isEnabled = false
            }
            if(meetingRow == meetings!.count - 1){
                nextButton.isEnabled = false
            }

            let row = meetingRow!
            let meeting = meetings![row]
            let location = CLLocationCoordinate2DMake(meeting.lat,meeting.lng)
            let region = MKCoordinateRegion.init(center: location, span: MKCoordinateSpan.init(latitudeDelta: 0.01,longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            meetingTitle.text = meeting.title
            meetingDuration.text = String(meeting.duration)
            let time = meeting.time
            meetingTime.text = String(format:"%02d:%02d",time/60,time%60)
            
            meetingAddress.text = meeting.address + " " + meeting.postcode
            
            mapView.removeAnnotation(annotation)
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
        else {
            print("map meeting was nil")
        }
        

    }

    override func viewWillAppear(_ animated: Bool) {
        setMeeting()
        //todayButton.title = days[theDay]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
