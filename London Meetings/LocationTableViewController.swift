//
//  LocationTableViewController.swift
//  London Meetings
//
//  Created by Steve O'Connor on 01/08/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationOptionDelegate: class {
    func setLocationOption(index: Int)
}

class DefaultLocationCell: UITableViewCell{
    @IBOutlet weak var defaultLocation: UILabel!
}

class LocationTableViewController: UITableViewController {

    var locationOptions : LocationOptions?
    
    weak var delegate: LocationOptionDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        delegate = self.presentingViewController as? LocationOptionDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        return (locationOptions?.options.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = locationOptions!.options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultLocationCell", for: indexPath) as! DefaultLocationCell
            //cell.defaultLocation.attributedText = option.title
            cell.defaultLocation.text = option.title
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("location pop row", indexPath.row)
        delegate?.setLocationOption(index: indexPath.row)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
