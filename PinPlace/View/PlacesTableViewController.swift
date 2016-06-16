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
    
    var viewModel: PlacesViewModel?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.places.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->  UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PlaceTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PlaceTableViewCell
        guard let vm = viewModel else { return cell }
        cell.placeTitleLabel?.text = vm.places[indexPath.row].title
        return cell
    }

}
