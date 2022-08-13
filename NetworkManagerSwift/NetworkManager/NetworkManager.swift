//  Created by Santhosh K

import Foundation
import UIKit


typealias CallCompletionDataHandler = ([String:Any],Bool,String,Int) ->Void

class Requester: Operation {
    
    static var _requester: Requester?
    var response:URLResponse?
    var session:URLSession?
    var getRequest : URLRequest?
    var getResponseData: Data?
    var callForCompletiondander : CallCompletionDataHandler?
    var forTokenEnabled:Bool?
    
    class func sharedHelper() -> Requester? {
        _requester = Requester()
        return _requester
    }
    
    var operationQueueNM: OperationQueue? {
        var operationQueue: OperationQueue? = nil
        var onceToken: Int = 0
        if (onceToken == 0) {
            operationQueue = OperationQueue()
            operationQueue?.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        }
        onceToken = 1
        return operationQueue
    }
    
    func setSession() -> URLSession? {
        let tokenKey = UserDefaults.standard.loginToken
        let sessionConfiguration = URLSessionConfiguration.default
        if let tokenV = tokenKey{
            sessionConfiguration.httpAdditionalHeaders = ["authorization":"Bareer \(tokenV)"]
        }
        
        // disable the caching
        sessionConfiguration.urlCache = nil
        // initialize the URLSession
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue:nil)
        return self.session
    }
    
}

extension Requester  {
    
    func callGetWebService(_ url: String, withHttpType: String, withParams:[String:Any], isTokenEnabled: Bool, withCompletionHandler:@escaping CallCompletionDataHandler) {
        
        //Check Internet - Condition
        callForCompletiondander = withCompletionHandler
        //     dataTask = true
        
        // create a URLRequest with the given URL and initialize a URLSessionDataTask
        //assign isTokenEnabled or Not
        let completionURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        forTokenEnabled = isTokenEnabled
        
        // url validating
        if let url = URL(string:completionURL!){
            getRequest = URLRequest(url: url)
            getRequest?.httpMethod = withHttpType // GET or POST - Required
            getRequest?.timeoutInterval = 120
            if withParams.count != 0 {
                let postData = try? JSONSerialization.data(withJSONObject:withParams, options: .init(rawValue: 0))
                if postData != nil {
                    getRequest?.httpBody = postData
                }
            }
            // Adding url request in queue then calling start() function based on queue
            operationQueueNM?.addOperation(self)
        }
    }
    
    //MARK:- Start NSOperation
    override func start() {
        if (!self.isCancelled) {
            if (!self.isExecuting) {
                getResponseData = nil
                getResponseData = Data()
                // Calling Normal POST and Get DataTask API
                if let task = self.setSession()?.dataTask(with: getRequest!){
                    // start the task, tasks are not started by default
                    task.resume() }
            }
        }
        else {
            callForCompletiondander?([:],true,"Web Service Call operation canceled", 0)
        }
    }
}


//MARK:- DelegateMethods
extension Requester:URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        // The task became a stream task - start the task
        streamTask.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        // The task became a download task - start the task
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Void) {
        // The original request was redirected to somewhere else.
        // We create a new dataTask with the given redirection request and we start it.
        if let urlString = request.url?.absoluteString {
            print("willPerformHTTPRedirection to \(urlString)")
        } else {
            print("willPerformHTTPRedirection")
        }
        if let task = self.session?.dataTask(with: request) {
            task.resume()
        }
    }
    
    // MARK:- Webservice Main Delagates
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        // We've got the response headers from the server.
        getResponseData?.count = 0
        self.response = response
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        getResponseData?.append(data)
    }
    
    // URLSession DidCompletion errror
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // We've got an error
        if error == nil && getResponseData != nil{
            let httpResponse = self.response as? HTTPURLResponse
            let code = httpResponse?.statusCode
            // Token invalid ,Re- Start
            if code == 401 {
                DispatchQueue.main.async {
                    //refreshTokenStuff { (Status) in
                    // if Status == true {
                    //   self.start()
                    // }
                    // }
                }
            }
            else {
                // if Data is Success Convert Data to JSON
                do {
                    let json = try JSONSerialization.jsonObject(with:getResponseData!, options: .mutableContainers)
                    print(json)
                    if code == 200 || code == 449 {
                        callForCompletiondander?(json as! [String : Any],true,"success", code ?? 0)
                    } else {
                        let msg = "\(code ?? 0)"
                        callForCompletiondander?(json as! [String : Any],false,msg, code ?? 0)
                    }
                } catch let error as NSError {
                    callForCompletiondander?([:],false,error.localizedDescription, code ?? 0)
                }
            }
        }
        else{
            callForCompletiondander?([:],false,"Sorry, something went wrong. Please try again", 0)
        }}
}

//Video upload
extension Requester {
    // Upload image and Video and content
    func callImageVideoUpload(mainUrl:String,withHttpType:String,mediaParams:[[String:Any]],withParams:[String:Any],isTokenEnabled:Bool,withCompletionHandler:@escaping CallCompletionDataHandler){
        print("URL:- \(mainUrl)")
        print("Params:- \(withParams)")
        
        callForCompletiondander = withCompletionHandler
        let completionURL = mainUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        forTokenEnabled = isTokenEnabled
        // url validating
        if let url = URL(string:completionURL!){
            // UIImagePNGRepresentation(image)
            getRequest = URLRequest(url: url)
            getRequest?.httpMethod = withHttpType // GET or POST - Required
            // Multi part image upload
            getRequest?.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            getRequest?.httpShouldHandleCookies = false
            getRequest?.timeoutInterval = 60
            let boundary = "------VohpleBoundary4QuqLuM1cE5lMwCy"
            let contentType = String.init(format: "multipart/form-data; boundary=%@", boundary)
            getRequest?.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            getRequest?.httpBody  = createMediaBody(with: withParams, boundary: boundary, mediaParams)
            operationQueueNM?.addOperation(self)
        }
    }
    
    
    // Creating param and image are converting to data
    func createMediaBody(with parameters: [String: Any]?, boundary: String,_ mediaParam: [[String: Any]])-> Data {
        var setData = Data()
        if parameters != nil {
            print("Parammmmmm")
            for (key, value) in parameters! {
                setData.appendString("--\(boundary)\r\n")
                setData.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                setData.appendString("\(value)\r\n")
            }
        }
        
        
        if mediaParam.count != 0 {
            for (_, paramR) in mediaParam.enumerated() {
                
                let mediaKey = paramR["key"] as? String
                let mediaMimeType = paramR["type"] as? String
                let mediaFileName = paramR["fileName"] as? String
                
                var mediaData: Data?
                
                if mediaMimeType == "video/mov" {
                    let mediaValue = paramR["value"] as? URL
                    do {
                        mediaData = try Data(contentsOf:mediaValue!, options: Data.ReadingOptions.alwaysMapped)
                    } catch {
                        print("mediaError")
                    }
                }
                else if mediaMimeType == "image/jpg" {
                    let mediaValue = paramR["value"] as? UIImage
                    if let imageData = mediaValue?.jpegData(compressionQuality: 0.2) {
                        mediaData = imageData
                    }
                }
                
                if let data = mediaData {
                    setData.appendString("--\(boundary)\r\n")
                    setData.appendString("Content-Disposition: form-data; name=\"\(mediaKey ?? "")\"; filename=\"\(mediaFileName ?? "")\"\r\n")
                    setData.appendString("Content-Type: \(mediaMimeType ?? "")\r\n\r\n")
                    setData.append(data)
                    setData.appendString("\r\n")
                }
            }
        }
        
        setData.appendString("--".appending(boundary.appending("--\r\n")))
        return setData
    }
}



extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

extension UInt8 {
  public static var random: UInt8 {
    var number: UInt8 = 0
    _ = SecRandomCopyBytes(kSecRandomDefault, 1, &number)
    return number
  }
}













/*
 func callImageUploadWebservice(_ url: String, withHttpType: String, withImage: UIImage!, withParams: [String:Any], isTokenEnabled: Bool, withCompletionHandler:@escaping CallCompletionDataHandler) {
     callForCompletiondander = withCompletionHandler
     // UploadDataTask = true
     
     let completionURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
     
     forTokenEnabled = isTokenEnabled
     // url validating
     if let url = URL(string:completionURL!){
         let imageData = withImage.jpegData(compressionQuality: 0.5)
         getRequest = URLRequest(url: url)
         getRequest?.httpMethod = withHttpType // GET or POST - Required
         // Multi part image upload
         getRequest?.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
         getRequest?.httpShouldHandleCookies = false
         getRequest?.timeoutInterval = 60
         let boundary = "------VohpleBoundary4QuqLuM1cE5lMwCy"
         let contentType = String.init(format: "multipart/form-data; boundary=%@", boundary)
         getRequest?.setValue(contentType, forHTTPHeaderField: "Content-Type")
         getRequest?.httpBody =  createBody(withParams, boundary: boundary, data: imageData!, mimeType: "image/jpg")
         // Adding url request in queue then calling start() function based on queue
         operationQueueNM?.addOperation(self)
     }
 }
 
 // Creating param and image are converting to data
 func createBody(_ parameters: [String: Any]?, boundary: String, data:Data, mimeType: String)-> Data {
     var setData = Data()
     if parameters != nil {
         for (key, value) in parameters! {
             setData.appendString("--\(boundary)\r\n")
             setData.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
             setData.appendString("\(value)\r\n")
         }
     }
     
     setData.appendString("--\(boundary)\r\n")
     setData.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
     setData.appendString("Content-Type: image/jpg\r\n\r\n")
     setData.append(data)
     setData.appendString("\r\n")
     
     setData.appendString("--".appending(boundary.appending("--\r\n")))
     return setData
 }
 
 */
