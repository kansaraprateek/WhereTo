//
//  Venue.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Venue{
    
    var id : String!
    var name : String?
    
    var location     : Location?
    var categories   : [Categories]?
}

extension Venue : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Venue.CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        
        location = try values.decode(Location.self, forKey: .location)
        categories = try values.decode([Categories].self, forKey: .categories)
    }
}
