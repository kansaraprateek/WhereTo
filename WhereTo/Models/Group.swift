//
//  Group.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Group {
    
    var type         : String?
    var name         : String?
    
    var items        : [Item]?
}

extension Group : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Group.CodingKeys.self)
        type = try values.decode(String.self, forKey: .type)
        name = try values.decode(String.self, forKey: .name)
        
        items = try values.decode([Item].self, forKey: .items)
    }
}
