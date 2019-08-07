//
//  Icon.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

struct Icon{
    var prefix      : String?
    var suffix      : String?
    
    var url : String?{
        return  "\(prefix ?? "")bg_\(88)\(suffix ?? "")"
    }
}

extension Icon : Codable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Icon.CodingKeys.self)
        
        prefix = try values.decode(String.self, forKey: .prefix)
        suffix = try values.decode(String.self, forKey: .suffix)
    }
}
