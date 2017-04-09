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

    @IBOutlet fileprivate weak var centerOnMapButton: UIButton!
    @IBOutlet fileprivate weak var buildRouteButton: UIButton!
    @IBOutlet fileprivate weak var loadNearbyPlacesButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var trashBarButtonItem: UIBarButtonItem!

    let viewModel =  PlaceDetailsViewModel()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PlaceTableViewCell.nib,
                           forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)

        viewModel.place?.rx.observe(String.self, PlaceAttributes.title.rawValue).bindNext { [unowned self] newValue in
            self.navigationItem.title = newValue
            self.viewModel.savePlaceTitle()
        }.addDisposableTo(disposeBag)

        loadNearbyPlacesButton.rx.tap.bindNext {[unowned self] in
            HUD.show(.progress)
            self.viewModel.fetchNearbyPlaces {
                HUD.flash(.success, delay: 1.0)
            }
        }.addDisposableTo(disposeBag)

        centerOnMapButton.rx.tap.bindNext { [unowned self] in
            NotificationCenter.default.post(name: .centerPlaceOnMap, object: self.viewModel.place)
            self.navigationController?.popToRootViewController(animated: true)
        }.addDisposableTo(disposeBag)

        buildRouteButton.rx.tap.bindNext {[unowned self] in
            if let mapViewController = self.navigationController?.viewControllers.first as? PlacesMapViewController {
                mapViewController.viewModel.selectedTargetPlace = self.viewModel.place
                NotificationCenter.default.post(name: .buildRoute, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }.addDisposableTo(disposeBag)

        trashBarButtonItem.rx.tap.bindNext { [unowned self] _ in
            let alertController = UIAlertController(title: "", message: "Delete this place?", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            }
            alertController.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
                NotificationCenter.default.post(name: .placeDeleted, object: self.viewModel.place)
                self.viewModel.deletePlace()
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)

        viewModel.nearbyVenues.asDriver()
                .drive(tableView.rx.items(cellIdentifier: PlaceTableViewCell.reuseIdentifier,
                                          cellType: PlaceTableViewCell.self)) { (_, venue, cell) in
                    cell.placeTitleLabel.text = venue.name
                }.disposed(by: disposeBag)

        tableView.rx.itemSelected.bindNext { [unowned self] selectedIndexPath in
            let selectedNearbyVenue = self.viewModel.nearbyVenues.value[selectedIndexPath.row]
            self.viewModel.place?.title = selectedNearbyVenue.name
        }.addDisposableTo(disposeBag)

    }

}
