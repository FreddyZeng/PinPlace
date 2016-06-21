//
//  PlacesTableViewController.swift
//  PinPlace
//
//  Created by Artem on 6/21/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlacesTableViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let viewModel = PlacesTableViewModel()
    let disposeBag = DisposeBag()
    
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchPlaces()
        
        viewModel.places.asObservable().bindTo(tableView.rx_itemsWithCellFactory) { tableView, row, place in
            var cell = tableView.dequeueReusableCellWithIdentifier("PlaceCellIdentifier")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "PlaceCellIdentifier")
            }
            cell!.textLabel!.text = place.title
            return cell!
            }.addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected.subscribeNext() { [unowned self] indexPath in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.performSegueWithIdentifier(SegueIdentifier.ShowPlaceDetails.rawValue, sender: self.viewModel.places.value[indexPath.row])
            }.addDisposableTo(disposeBag)
        
        tableView.rx_itemDeleted
            .map { [unowned self] indexPath in
                try self.tableView.rx_modelAtIndexPath(indexPath) as Place
            }
            .subscribeNext { [unowned self] place in
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.PlaceDeleted.rawValue, object: place)
                self.viewModel.deletePlace(place)
            }.addDisposableTo(disposeBag)
        
        searchBar
            .rx_text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { [unowned self] (query) in
                self.viewModel.findPlacesByName(query)
            }
            .addDisposableTo(disposeBag)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowPlaceDetails.rawValue {
            guard let place = sender as? Place,
                let destinationViewController = segue.destinationViewController as? PlaceDetailsViewController
                else { return }
            destinationViewController.viewModel = PlaceDetailsViewModel()
            destinationViewController.viewModel?.place = place
        }
    }
}

