//
//  PlaceTableViewCell.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet private(set) weak var placeTitleLabel: UILabel!

    class var reuseIdentifier: String {
        get {
            return "PlaceTableViewCellReuseIdentifier"
        }
    }

    class var nib: UINib {
        get {
            return UINib(nibName: "PlaceTableViewCell", bundle: nil)
        }
    }

}
