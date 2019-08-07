//
//  WTUtilityMethods.swift
//  WhereTo
//
//  Created by Prateek Kansara on 06/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import Reachability

class UtilityMethods{    
    //MARK:- Internet Reachability
    static func isInternetAvailable() -> Bool {        
        let reachability = Reachability.init()!
        return reachability.isReachable
    }
    
}
