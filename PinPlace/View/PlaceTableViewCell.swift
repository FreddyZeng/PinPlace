//
//  PlaceTableViewCell.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeTitleLabel: UILabel!
    
    class var reuseIdentifier: String {
        get {
            return "PlaceTableViewCellReuseIdentifier"
        }
    }
}
