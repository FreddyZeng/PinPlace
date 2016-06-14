//
//  PlaceDetailsViewController.swift
//  PinPlace
//
//  Created by Artem on 6/14/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlaceDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var centerOnMapButton: UIButton!
    @IBOutlet weak var buildRouteButton: UIButton!
    @IBOutlet weak var loadNearbyPlacesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: PlaceDetailsViewModel?
    let disposeBag = DisposeBag()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        viewModel?.placeTitle.bindTo(self.navigationItem.rx_title).addDisposableTo(disposeBag)
        
        viewModel?.place?.rx_observe(String.self, "title").subscribeNext() { [unowned self] newValue in
            self.navigationItem.title = newValue
            }.addDisposableTo(disposeBag)
        
        
        loadNearbyPlacesButton.rx_tap.subscribeNext() {
            
        }.addDisposableTo(disposeBag)
        
    }
    
}

// MARK: - UITableViewDelegate

extension PlaceDetailsViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension PlaceDetailsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->  UITableViewCell {
        return UITableViewCell()
    }
    
}

