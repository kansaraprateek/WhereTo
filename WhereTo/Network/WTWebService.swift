//
//  WTWebService.swift
//  WhereTo
//
//  Created by Prateek Kansara on 04/08/19.
//  Copyright © 2019 Prateek. All rights reserved.
//

import Foundation

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


public enum HTTPMethod: Int {
    case get
    case post
    case put
    case delete
};

public let urlconfig = URLSessionConfiguration.default

private let kAFCharactersToBeEscapedInQueryString : CharacterSet = CharacterSet(charactersIn : ":/?&=;+!@#$()',*")

private func PercentEscapedQueryKeyFromStringWithEncoding(_ lString : NSString) -> NSString {
    
    return lString.addingPercentEncoding(withAllowedCharacters: kAFCharactersToBeEscapedInQueryString)! as NSString
}

class HTTPHeaders: NSObject {
    
    fileprivate var defaultHTTPHeaders : NSMutableDictionary!
    
    fileprivate var defaultDocumentHTTPHeaders : NSMutableDictionary!
    
    class var sharedInstance: HTTPHeaders {
        struct Singleton {
            
            static let instance = HTTPHeaders.init()
        }
        return Singleton.instance
    }
    
    func setDefaultHttpHeadears (_ headers : NSMutableDictionary){
        defaultHTTPHeaders = headers
    }
    
    func getHTTPHeaders() -> NSDictionary?{
        return defaultHTTPHeaders
    }
    
    func setDefaultDocumentHeaders(_ headers : NSMutableDictionary)  {
        defaultDocumentHTTPHeaders = headers
    }
    
    func getDocumentHeaders() -> NSDictionary? {
        return defaultDocumentHTTPHeaders
    }
}

open class WTWebService: NSObject {
    
    fileprivate var gURLString : NSString!
    
    open
    
    func setDefaultHeaders(_ headers : NSMutableDictionary) {
        let headersClass = HTTPHeaders.sharedInstance
        headersClass.setDefaultHttpHeadears(headers)
    }
    
    open
    var httpHeaders : NSDictionary?
    
    /**
     Sending request to url provided with type and block methods to handle response or error
     
     - parameter lUrl:        service url of String type
     - parameter parameters:  dictionary object with required params for service
     - parameter requestType: RequestType parameter with enum value
     - parameter success:     success block on successful service call
     - parameter failed:      failed block when service fails
     - parameter encoded:     bool value to determine parameter to be encoded within the url or not
     */
    
    open
    func sendRequest(_ lUrl : String, parameters : AnyObject?, requestType : HTTPMethod, success : @escaping (HTTPURLResponse?, Any) -> Void, failed : @escaping (HTTPURLResponse?, Any?) -> Void, encoded : Bool) {
        let webSessionObject : WTWebServiceSession = WTWebServiceSession()
        webSessionObject.headerValues = httpHeaders
        webSessionObject.sendHTTPRequestWithURL(lUrl as NSString, requestType: requestType, parameters: parameters, success: success, failed: failed, lEncoded: encoded)
    }
}

/// Web service handlers

class WTWebServiceSession: NSObject {
    
    fileprivate var onSuccess :  ((HTTPURLResponse?, Any) -> Void)?
    fileprivate var onError :  ((HTTPURLResponse?, Any?) -> Void)?
    
    fileprivate var gURLString : NSString = ""
    fileprivate var gRequestType : HTTPMethod = .get
    
    fileprivate var recievedData : Data!
    
    fileprivate var gResponse : URLResponse!
    fileprivate var gParameters : AnyObject?
    
    fileprivate var encoded : Bool!
    
    fileprivate var dataTask : URLSessionDataTask!
    
    
    /// Mutable Request
    
    fileprivate var headerValues : NSDictionary?
    
    fileprivate var mutableRequest : URLRequest! {
        set{
            self.mutableRequest = newValue
        }
        get {
            
            var lMutableRequest : URLRequest = URLRequest(url: URL(string: self.gURLString as String)!)
            lMutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            lMutableRequest.httpMethod = self.getRequestType()
            let httpHeaderClass = HTTPHeaders.sharedInstance
            if headerValues == nil {
                headerValues = httpHeaderClass.getHTTPHeaders()
            }
            
            headerValues?.enumerateKeysAndObjects({
                (key : Any, val : Any, stop :UnsafeMutablePointer<ObjCBool>) in
                lMutableRequest.setValue(val as? String, forHTTPHeaderField: key as! String)
            } )
            
            if gParameters?.count > 0 && !encoded{
                do{
                    lMutableRequest.httpBody = try JSONSerialization.data(withJSONObject: gParameters!, options: JSONSerialization.WritingOptions())
                    
                    if let paramASDict = gParameters as? [String : Any]{
                        let params = (paramASDict.flatMap({ (key, value) -> String in
                            return "\(key)=\(value)"
                        }) as Array).joined(separator: "&")
                        
                        lMutableRequest.httpBody = params.data(using: String.Encoding.ascii, allowLossyConversion: true)
                    }else{
                        
                    }
                }
                catch{
                    print("error in parameters")
                }
            }else if let paramString = gParameters as? String{
                lMutableRequest.httpBody = paramString.data(using: String.Encoding.ascii, allowLossyConversion: true)
            }
            
            return lMutableRequest
        }
    }
    
    fileprivate var session : Foundation.URLSession!
    
    /**
     Request method enum to String
     
     - returns: returns string as request type
     */
    
    fileprivate func getRequestType() -> String {
        
        switch self.gRequestType {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
    
    /**
     Sending request to url provided with type and block methods to handle response or error
     
     - parameter url:         service url of String type
     - parameter requestType: dictionary object with required params for service
     - parameter parameters:  RequestType parameter with enum value
     - parameter success:     success block on successful service call
     - parameter failed:      failed block when service fails
     - parameter lEncoded:    bool value to determine parameter to be encoded within the url or not
     */
    func sendHTTPRequestWithURL(_ url : NSString, requestType: HTTPMethod, parameters: AnyObject?,success : @escaping (HTTPURLResponse?, Any) -> Void, failed : @escaping (HTTPURLResponse?, Any?) -> Void, lEncoded : Bool)  {
        gURLString = url
        gRequestType = requestType
        encoded = lEncoded
        
        
        onSuccess = success
        onError = failed
        
        if lEncoded {
            encodedRequestWithParameters(parameters as AnyObject?)
        }
        else{
            gParameters = parameters
            sendRequest()
        }
    }
    
    /**
     Encoded request with parameters
     
     - parameter params: Any with dictionary of params
     */
    private func encodedRequestWithParameters(_ params : AnyObject?) {
        
        let encodedParamArray : NSMutableArray = NSMutableArray()
        if ((params?.count) != nil) {
            
            params!.enumerateKeysAndObjects({
                (parameterKey : Any, parameterValue : Any, stop : UnsafeMutablePointer<ObjCBool>) in
                
                encodedParamArray.add(NSString(format: "%@=%@", PercentEscapedQueryKeyFromStringWithEncoding(parameterKey as! NSString), PercentEscapedQueryKeyFromStringWithEncoding(parameterValue as! NSString)))
            })
            
            let encodedURL : NSString = NSString(format: "%@?%@", gURLString, encodedParamArray.componentsJoined(by: "&"))
            gURLString = encodedURL
        }
        
        session = Foundation.URLSession(configuration: URLSessionConfiguration.background(withIdentifier: gURLString as String), delegate: self, delegateQueue: OperationQueue.main)
        
        dataTask = session.dataTask(with: mutableRequest)
        WebServiceTaskHandler.shared.appendTask(task: dataTask)
        dataTask.resume()
        
    }
    
    /**
     Request without encoding
     */
    private func sendRequest(){
        
        urlconfig.timeoutIntervalForRequest = 30
        urlconfig.timeoutIntervalForResource = 30
        
        session = Foundation.URLSession(configuration: urlconfig, delegate: self, delegateQueue: OperationQueue.main)
        dataTask = session.dataTask(with: mutableRequest)
        WebServiceTaskHandler.shared.appendTask(task: dataTask)
        dataTask.resume()
    }
}

extension WTWebServiceSession: URLSessionDataDelegate{
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler( .useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        gResponse = response
        recievedData = nil
        recievedData = Data()
        
        completionHandler(.allow);
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        recievedData.append(data)
    }
}

extension WTWebServiceSession : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        session.finishTasksAndInvalidate()
        
        if let dataTask = task as? URLSessionDataTask{
            WebServiceTaskHandler.shared.removeTask(task: dataTask)
        }
        
        let httpResponse = gResponse as? HTTPURLResponse
        if (error == nil) {
            
            let responseDict : Any!
            do{
                responseDict = try JSONSerialization.jsonObject(with: recievedData, options: .allowFragments)
            }
            catch{
                
                
                let error : NSError = NSError.init(domain: "SerializationFailed", code: 0, userInfo: nil)
                if httpResponse!.statusCode == 200 {
                    if (recievedData != nil) {
                        //                            let stringData = String(data: recievedData, encoding: .utf8)
                        //                            do{
                        //                                responseDict = try JSONSerialization.jsonObject(with:  stringData!.data(using: .utf8)!, options: .allowFragments)
                        //                                onSuccess!(httpResponse, responseDict)
                        //                            }catch{}
                        onSuccess!(httpResponse, recievedData)
                    }else{
                        onSuccess!(httpResponse, ["message" : "success"])
                    }
                }
                else{
                    let stringData = String(data: recievedData, encoding: .utf8)
                    if stringData != nil{
                        onError!(httpResponse, stringData)
                    }else{
                        onError!(httpResponse, error)
                    }
                    
                }
                return
            }
            
            if httpResponse!.statusCode == 200 {
                onSuccess!(httpResponse, responseDict)
                
            }
            else{
                onError!(httpResponse, responseDict)
            }
        }
        else{
            onError!(httpResponse, error!)
        }
    }
}

class WebServiceTaskHandler {
    
    static let shared = WebServiceTaskHandler()
    
    private var taskList = [URLSessionDataTask]()
    
    public func appendTask (task : URLSessionDataTask){
        self.taskList.append(task)
    }
    
    public func removeTask (task : URLSessionDataTask){
        for (index, taskObject) in taskList.enumerated(){
            if task == taskObject{
                taskList.remove(at: index)
            }
        }
    }
    
    public func cancelAllTask(){
        for task in taskList{
            task.cancel()
        }
    }
    
}

