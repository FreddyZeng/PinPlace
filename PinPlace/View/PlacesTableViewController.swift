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

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!

    let viewModel = PlacesTableViewModel()
    fileprivate let disposeBag = DisposeBag()


    //MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PlaceTableViewCell.nib,
                           forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)

        viewModel.places
            .asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: PlaceTableViewCell.reuseIdentifier,
                                       cellType: PlaceTableViewCell.self)) { (row, place, cell) in
                                        cell.placeTitleLabel.text = place.title
            }.addDisposableTo(disposeBag)

        tableView.rx.itemSelected.bindNext() { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: SegueIdentifier.ShowPlaceDetails.rawValue,
                              sender: self.viewModel.places.value[indexPath.row])
            }.addDisposableTo(disposeBag)

        tableView.rx.itemDeleted.bindNext() { [unowned self] indexPath in
            if let place = try? self.tableView.rx.model(at: indexPath) as Place {
                NotificationCenter.default.post(name: .placeDeleted, object: place)
                self.viewModel.deletePlace(place)
            }
            }.addDisposableTo(disposeBag)

        searchBar
            .rx.text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bindNext { [unowned self] (query) in
                self.viewModel.findPlacesByName(query!)
            }
            .addDisposableTo(disposeBag)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPlaces()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.ShowPlaceDetails.rawValue {
            guard let place = sender as? Place,
                let destinationViewController = segue.destination as? PlaceDetailsViewController
                else { return }
            destinationViewController.viewModel = PlaceDetailsViewModel()
            destinationViewController.viewModel?.place = place
        }
    }
}

