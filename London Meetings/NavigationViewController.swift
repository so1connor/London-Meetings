//
//  NavigationViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 30/07/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController, DayDelegate, LocationOptionDelegate{
    
    func changedDay(day: Int) {
        let controller = self.topViewController as? TableViewController
        controller?.setDay(day: day)
    }
    
    func setLocationOption(option: LocationOption){
        let controller = self.topViewController as? TableViewController
        controller?.setLocationOption(option: option)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("navigation controller memory warning")
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
