//
//  NavigationViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 30/07/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController, DayDelegate{
    
    func changedDay(day: Int) {
        //print("hello",day)
        let controller = self.topViewController as? TableViewController
        controller?.updateDay(day: day)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
