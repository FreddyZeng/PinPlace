//
//  PlacesPopoverTableViewController.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import RxSwift

class PlacesPopoverTableViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    let viewModel = PlacesViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchPlaces()
        
        viewModel.places
            .asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: PlaceTableViewCell.reuseIdentifier)) { row, place, cell in
                guard let cell = cell as? PlaceTableViewCell else { return }
                cell.placeTitleLabel.text = place.title
            }.addDisposableTo(disposeBag)

        
        tableView.rx.itemSelected.bindNext() { [unowned self] indexPath in
            if let placesMapVC = self.popoverPresentationController?.delegate as? PlacesMapViewController {
                placesMapVC.viewModel.selectedTargetPlace = self.viewModel.places.value[indexPath.row]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.BuildRoute.rawValue), object: nil)
            }
            self.dismiss(animated: true, completion: nil)
            }.addDisposableTo(disposeBag)
    }
}
