//
//  WTAPIService.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import SVProgressHUD

/// Class to handle foresquare API network calls
class WTAPIService : NSObject{
    
    static let shared = WTAPIService()
    
    var response : Response?
    
    private var serviceObj = WTWebService()
    
    var reloadUI : ((Bool) -> Void)?
    
    fileprivate var isRequested = false
    
    private func showLoader(){
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    /// Method to fetch venues with a given location and radius
    ///
    /// - Parameters:
    ///   - location: Locaton model type object
    ///   - radius: Radius of selected region
    func fetchVenues(location : Location, radius : Double){
        
        if !UtilityMethods.isInternetAvailable(){
            DispatchQueue.main.async {
                SVProgressHUD.showInfo(withStatus: "No Internet Available")
            }
            return
        }
        
        if !isRequested{
            isRequested = true
            showLoader()
            let venueURL = venueExplore + "?ll=\(location.lat ?? 0.0),\(location.lng ?? 0.0)&client_id=\(client_id)&client_secret=\(client_secret)&v=20190804&radius=\(radius)"
            serviceObj.sendRequest(venueURL, parameters: nil, requestType: .get, success: {httpresponse, data in
                var isSucccess = false
                if let dataAsDict = data as? [String : Any]{
                    if let  meta = dataAsDict["meta"] as? [String : Any], let code = meta["code"] as? Int, code == 200, let response = dataAsDict["response"] as? [String : Any]{
                        if let encodedData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted){
                            do {
                                let responseObject = try JSONDecoder().decode(Response.self, from: encodedData)
                                self.response = responseObject
                                isSucccess = true
                            }catch{
                                print(error)
                            }
                        }
                    }
                }
                
                if self.reloadUI != nil{
                    self.reloadUI!(isSucccess)
                }
                self.isRequested = false
                SVProgressHUD.dismiss()
                
            }, failed: {
                response, error in
                if self.reloadUI != nil{
                    self.reloadUI!(false)
                }
                self.isRequested = false
                SVProgressHUD.dismiss()
            }, encoded: false)
        }
    }
}
