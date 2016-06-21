//
//  PlacesPopoverTableViewController.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlacesPopoverTableViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    let viewModel = PlacesViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchPlaces()
        
        viewModel.places.asObservable().bindTo(tableView.rx_itemsWithCellFactory) { tableView, row, place in
            let cell = tableView.dequeueReusableCellWithIdentifier(PlaceTableViewCell.reuseIdentifier) as! PlaceTableViewCell
            cell.placeTitleLabel.text = place.title
            return cell
            }.addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected.subscribeNext() { [unowned self] indexPath in
            if let placesMapVC = self.popoverPresentationController?.delegate as? PlacesMapViewController {
                placesMapVC.viewModel.selectedTargetPlace = self.viewModel.places.value[indexPath.row]
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.BuildRoute.rawValue, object: nil)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            }.addDisposableTo(disposeBag)
    }
}
