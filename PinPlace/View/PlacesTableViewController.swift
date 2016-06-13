//
//  PlacesTableViewController.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlacesTableViewController: UITableViewController {
    
    let viewModel = PlacesViewModel()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.places.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->  UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PlaceTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PlaceTableViewCell
        cell.placeTitleLabel?.text = viewModel.places[indexPath.row].title
        return cell
    }

}
