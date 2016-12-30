//
//  FridayTableViewController.swift
//  hackillinois-2017-ios
//
//  Created by Shotaro Ikeda on 6/11/16.
//  Copyright © 2016 Shotaro Ikeda. All rights reserved.
//

import UIKit

class FridayTableViewController: GenericDayViewController {
    override func viewDidLoad() {
        
        for n in 0..<10 {
            let item = DayItem(name: "Friday Event \(n)", location: "REPLACE ME", time: "MM:DD PM")
            dayItems.append(item)
        }
        
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(-57, 0, 0, -57);
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
}
