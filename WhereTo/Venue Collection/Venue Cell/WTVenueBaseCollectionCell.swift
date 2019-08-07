//
//  WTVenueBaseCollectionCell.swift
//  WhereTo
//
//  Created by Prateek Kansara on 05/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import UIKit

class WTVenueBaseCollectionCell: UICollectionViewCell {
    
    static let identifier = "venueCell"
    
    @IBOutlet var dataLabel : UILabel!
    @IBOutlet var imageView : UIImageView!
    
    var venue : Venue!
    func setup(venue : Venue){
        self.venue = venue
        var categoryName = ""
        if let category = self.venue.categories?.first{
            categoryName = category.name ?? ""
        }
        self.dataLabel.text = (self.venue.name ?? "") + (categoryName.isEmpty ? "" : "\n\(categoryName)")
        self.dataLabel.textColor = .black
        
        if let category = self.venue.categories?.first, let icon = category.icon, let url = icon.url{
            self.imageView.downloadedFrom(url: url + authentication, placeholderImage: UIImage(named: "photo"))
        }
        
        self.setupUI()
        updateCell()
    }
    
    func setupUI(){
        self.dataLabel.layer.cornerRadius = 5.0
    }

    func updateCell(){}
}
