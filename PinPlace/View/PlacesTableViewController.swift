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

class PlacesTableViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    var viewModel: PlacesViewModel?
    let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.places.asObservable().bindTo(tableView.rx_itemsWithCellFactory) { tableView, row, place in
            let cell = tableView.dequeueReusableCellWithIdentifier(PlaceTableViewCell.reuseIdentifier) as! PlaceTableViewCell
            cell.placeTitleLabel.text = place.title
            return cell
            }.addDisposableTo(disposeBag)
    }
}
