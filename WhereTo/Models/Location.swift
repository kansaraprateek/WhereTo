//
//  Location.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Location {
    
    var address     : String = ""
    
    var lat         : Double!
    var lng         : Double!
    
    var cc          : String?
    var city        : String?
    
    var country     : String?
    
    var formattedAddress     : [String]?
}

extension Location : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Location.CodingKeys.self)
        
//        address = try values.decode(String.self, forKey: .address)
        
        lat = try values.decode(Double.self, forKey: .lat)
        lng = try values.decode(Double.self, forKey: .lng)
        
//        cc = try values.decode(String.self, forKey: .cc)
//        city = try values.decode(String.self, forKey: .city)
        country = try values.decode(String.self, forKey: .country)
        
        formattedAddress = try values.decode([String].self, forKey: .formattedAddress)
    }
}
