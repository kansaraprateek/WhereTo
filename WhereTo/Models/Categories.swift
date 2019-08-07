//
//  Categories.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Categories {
    
    var id          : String!
    var name        : String?
    
    var pluralName  : String?
    var shortName   : String?
    
    var primary     : Bool          = false
    
    var icon        : Icon?
}

extension Categories : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Categories.CodingKeys.self)
   
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        
        pluralName = try values.decode(String.self, forKey: .pluralName)
        shortName  = try values.decode(String.self, forKey: .shortName)
        primary = try values.decode(Bool.self, forKey: .primary)
        icon = try values.decode(Icon.self, forKey: .icon)
    }
}
