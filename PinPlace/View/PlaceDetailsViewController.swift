//
//  PlaceDetailsViewController.swift
//  PinPlace
//
//  Created by Artem on 6/14/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

class PlaceDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var centerOnMapButton: UIButton!
    @IBOutlet weak var buildRouteButton: UIButton!
    @IBOutlet weak var loadNearbyPlacesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    
    var viewModel: PlaceDetailsViewModel?
    let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.place?.rx_observe(String.self, PlaceAttributes.title.rawValue).subscribeNext() { [unowned self] newValue in
            self.navigationItem.title = newValue
            self.viewModel?.savePlaceTitle()
            }.addDisposableTo(disposeBag)
        
        loadNearbyPlacesButton.rx_tap.subscribeNext() {[unowned self] in
            HUD.show(.Progress)
            self.viewModel?.fetchNearbyPlaces() {
                HUD.flash(.Success, delay: 1.0)
            }
            }.addDisposableTo(disposeBag)
        
        trashBarButtonItem.rx_tap.subscribeNext(){ _ in
            let alertController = UIAlertController(title: "", message: "Delete this place?", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { [unowned self] (action) in
                self.viewModel?.deletePlace()
                self.navigationController?.popViewControllerAnimated(true)
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
        
        viewModel?.nearbyVenues.asObservable().bindTo(tableView.rx_itemsWithCellFactory) { tableView, row, nearbyVenue in
            var cell = tableView.dequeueReusableCellWithIdentifier("FoursquareVenueCellIdentifier")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FoursquareVenueCellIdentifier")
            }
            cell!.textLabel!.text = nearbyVenue.name
            return cell!
            }.addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected.subscribeNext() { [unowned self] selectedIndexPath in
            let selectedNearbyVenue = self.viewModel?.nearbyVenues.value[selectedIndexPath.row]
            self.viewModel?.place?.title = selectedNearbyVenue?.name
            }.addDisposableTo(disposeBag)
        
    }
    
}