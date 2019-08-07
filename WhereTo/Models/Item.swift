//
//  Item.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Item {
    
    var reasons      : Reason?
    var venue        : Venue?
}

extension Item : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Item.CodingKeys.self)
        reasons = try values.decode(Reason.self, forKey: .reasons)
        venue = try values.decode(Venue.self, forKey: .venue)
    }
}
