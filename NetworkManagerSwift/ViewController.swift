//
//  ViewController.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 11/08/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.callApi()
    }

    func callApi() {
        //smapleAPI
        let urlStr = ""
        let params = [String:Any]()
        Requester.sharedHelper()?.callGetWebService(urlStr, withHttpType: "POST", withParams: params, isTokenEnabled: false, withCompletionHandler: { responseJson, statusRes, messageRes, statusCode in
            print(responseJson)
        })
        
    }
    
}

