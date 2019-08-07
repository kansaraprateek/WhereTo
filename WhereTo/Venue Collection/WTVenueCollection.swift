//
//  WTVenueCollection.swift
//  WhereTo
//
//  Created by Prateek Kansara on 05/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import UIKit

class WTVenueCollectionViewController : UIViewController{
    
    @IBOutlet private var venueCollectionView : UICollectionView!
    @IBOutlet private var collectionHeader : UILabel!
    
    var venueLocations : [[String : Any]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.registerCollectionClass()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupUI(){
        self.collectionHeader.set(corner: 5.0)
        self.collectionHeader.backgroundColor = UIColor(number: 108, alpha: 0.6)
        self.collectionHeader.textColor = .white
    }
    
    private func registerCollectionClass(){
        
        self.venueCollectionView.isDirectionalLockEnabled = true
    }
    
    private var groups : [Group]?
    func reloadData(){
        if let response = WTAPIService.shared.response, let groups = response.groups{
            self.groups = groups
        }
        venueLocations = [[String : Any]]()
        if self.groups != nil{
            var section = 0
            for group in self.groups!{
                if group.items != nil{
                    var row = 0
                    for item in group.items!{
                        if let venue = item.venue{
                            self.venueLocations.append([
                                "id"        : venue.id as Any,
                                "lat"       : venue.location?.lat as Any,
                                "lng"       : venue.location?.lng as Any,
                                "name"      : venue.name as Any,
                                "section"   : section,
                                "row"       : row
                            ])
                            row += 1
                        }
                    }
                }
                section += 1
            }
        }
        
        if updateMapToIndex != nil{
            self.updateMapToIndex!(nil)
        }
        
        self.collectionHeader.isHidden = true
        if self.venueLocations.count > 0 {
            self.collectionHeader.isHidden = false
        }
        self.venueCollectionView.reloadData()
    }
    
    fileprivate var isScrolledToCell = false
    func showVenueCellAt(indexPath : IndexPath){
        isScrolledToCell = true
        DispatchQueue.main.async {
            self.venueCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    var updateMapToLocation : ((Location) -> Void)?
    var updateMapToIndex : ((IndexPath?) -> Void)?
}

extension WTVenueCollectionViewController : UICollectionViewDataSource{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let items = groups![section].items{
            return items.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WTVenueBaseCollectionCell.identifier, for: indexPath) as! WTVenueBaseCollectionCell
        if let items = groups![indexPath.section].items, let venue = items[indexPath.row].venue{
            cell.setup(venue: venue)
        }
        cell.set(corner: 5.0)
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var header = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionHeader{
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WTVenueBaseCollectionHeader.identifier, for: indexPath) as! WTVenueBaseCollectionHeader
            headerCell.frame = CGRect(x: 0, y: 0, width: 0.1, height: 0.1)
            let group = groups![indexPath.section]
            self.collectionHeader.text = group.name?.capitalized
            header = headerCell
        }
        return header
    }
}

extension WTVenueCollectionViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0.1, height: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

extension WTVenueCollectionViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isScrolledToCell && updateMapToIndex != nil{
            let index = round(self.venueCollectionView.contentOffset.x) / (UIScreen.main.bounds.width - 20)
            self.updateMapToIndex!(IndexPath(row: Int(index), section: 0))
        }
        isScrolledToCell = false
    }
}
