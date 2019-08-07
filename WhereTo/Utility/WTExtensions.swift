//
//  WTExtensions.swift
//  WhereTo
//
//  Created by Prateek Kansara on 06/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    @objc func set(corner radius : CGFloat)  {
        
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
    
    @objc func set(shadow radius : CGFloat) {
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: radius)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
}

/// A protocol used for logging on console
protocol Printable {
    func po()
}

// MARK: - Extension that actually prints
extension Printable{
    func po(){ print(self) }
    func pod(){ print(self as! NSDictionary) }
    func por(){ print(self as! NSArray) }
}


// MARK: - Extnsions of Classes whose objects can print. Only Conforming to the protocol does the beauty
extension String: Printable{}
extension NSObject: Printable{}
extension Dictionary: Printable{}
extension Array: Printable{}
extension CGRect: Printable{}
extension Int: Printable{}
extension CGFloat: Printable{}


private let activityTag = 12011992
private let activitySize : CGFloat = 37
extension UIImageView {
    
    /**
     Extending UIImageView class to handle image downloading
     
     - parameter url:             image URL as String
     - parameter setToItemObject: Item Object to set the downlaoded image data
     */
    
    func downloadedFrom(url: String, placeholderImage : UIImage?) {
        guard let url = URL(string: url) else { return }
        self.image = UIImage(data: Data())
        self.updateConstraintsIfNeeded()
        showAnimating()
        if UtilityMethods.isInternetAvailable(){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let image = UIImage(data: data!)
                    else {
                        self.image = placeholderImage
                        self.endAnimating()
                        return
                }
                DispatchQueue.main.async(execute: {
                    self.endAnimating()
                    if data != nil{
                        self.image = image
                    }else{
                        if placeholderImage != nil{
                            self.image = placeholderImage
                        }
                    }
                })
                }.resume()
        }else{
            self.endAnimating()
            if placeholderImage != nil{
                self.image = placeholderImage
            }
        }
    }
    
    /**
     Custom method to show activity indicator within UIImageView when image is downloaded
     */
    private func showAnimating(){
        let activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView.init(style: .white)
        
        activityIndicator.center = CGPoint.init(x: frame.width/2, y:frame.width/2)
        activityIndicator.layer.position = CGPoint.init(x:frame.width/2, y:frame.width/2)
        activityIndicator.tag = activityTag
        activityIndicator.color = UIColor.lightGray
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
    }
    
    /**
     Custom method to called when image is fully downlaoded.
     */
    private func endAnimating(){
        
        if let activityView = self.viewWithTag(activityTag) as? UIActivityIndicatorView{
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
}

extension UIColor{
    public convenience init?(number: CGFloat, alpha : CGFloat = 1.0) {
        let divider: CGFloat = 255.0
        self.init(red: number/divider, green: number/divider, blue: number/divider, alpha: alpha)
        return
    }
}
