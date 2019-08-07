//
//  WTCustomAnnotationView.swift
//  WhereTo
//
//  Created by Prateek Kansara on 07/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import MapKit

/// Custom class for annotations view
class WTCustomAnnotationView : MKMarkerAnnotationView{
    override var annotation: MKAnnotation?{
        willSet{
            if let _ = newValue as? WTCustomPointAnnotation{
                self.displayPriority = .required
            }
        }
    }
}
