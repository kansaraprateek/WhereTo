//
//  WTVenueBaseCollectionHeader.swift
//  WhereTo
//
//  Created by Prateek Kansara on 05/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import UIKit

class WTVenueBaseCollectionHeader : UICollectionReusableView{
    
    static let identifier = "venueHeader"
    
    @IBOutlet private var headerLabel : UILabel!
    
    func setup(header title : String){
        self.headerLabel.text = title
        self.updateHeader()
    }
    
    func updateHeader(){}
}
