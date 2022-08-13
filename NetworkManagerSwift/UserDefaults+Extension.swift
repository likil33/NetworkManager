//
//  UserDefaults+Extension.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 13/08/22.
//

import Foundation
import UIKit



extension UserDefaults {
    
    var loginToken:String? {
        get {return string(forKey: "loginToken")}
        set { set(newValue, forKey: "loginToken")
            synchronize()
        }
    }
}
