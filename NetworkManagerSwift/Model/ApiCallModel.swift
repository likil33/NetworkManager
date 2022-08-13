//
//  ApiCallModel.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 12/08/22.
//

import Foundation
import UIKit


struct CountryCodeStruct {
    var body:[CountryCodeDataStruct]
    var httpStatusCode:Int
    
    init(with Dic:[String:Any]?) {
        let bodyArr =  Dic?["result"] as? [[String:Any]] ?? []
        self.body =  bodyArr.compactMap { (v: [String:Any]) -> CountryCodeDataStruct? in
            if v.count != 0 {return CountryCodeDataStruct(with: v) } else {return nil }
        }
        self.httpStatusCode = Dic?["httpStatusCode"] as? Int ?? 0
    }
}




struct CountryCodeDataStruct {
    
    var id:Int
    var country_name:String
    var iso_code:String
    var country_code:String
    var flag:String
    
    init(with Dic:[String:Any]?) {
        self.id = Dic?["id"] as? Int ?? 0
        self.country_name = Dic?["country_name"] as? String ?? ""
        self.iso_code = Dic?["iso_code"] as? String ?? ""
        self.country_code = Dic?["country_code"] as? String ?? ""
        self.flag = Dic?["flag"] as? String ?? ""
    }
}

struct OTPStruct {
    var body:OTPDataStruct
    var httpStatusCode:Int
    
    init(with Dic:[String:Any]?) {
        self.body = OTPDataStruct(with: Dic?["result"] as? [String:Any] ?? [:])
        self.httpStatusCode = Dic?["httpStatusCode"] as? Int ?? 0
    }
}
struct OTPDataStruct {
    var token:TokenDateStruct
    var user:UserDataStruct
    init(with Dic:[String:Any]?) {
        self.token = TokenDateStruct(with: Dic?["token"] as? [String:Any] ?? [:])
        self.user = UserDataStruct(with: Dic?["user"] as? [String:Any] ?? [:])
    }
}
struct TokenDateStruct
{
    var access:AccessTokenData
    var refreshToken: RefreshTokenData
    init(with Dic:[String:Any]?) {
        self.access = AccessTokenData(with: Dic?["access"] as? [String:Any] ?? [:])
        self.refreshToken = RefreshTokenData(with: Dic?["refresh"] as? [String:Any] ?? [:])
    }
}
struct AccessTokenData {
    var token:String
    init(with Dic:[String:Any]?) {
        self.token = Dic?["token"] as? String ?? ""
    }
}

struct RefreshTokenData {
    var token:String
    init(with Dic:[String:Any]?) {
        self.token = Dic?["token"] as? String ?? ""
    }
}


struct  UserDataStruct
{
    var id:Int
    var mobile_numberl:String
    var country_id:Int
    var user_name:String
    var email:String
    var is_active:Int
    init(with Dic:[String:Any]?) {
        self.id = Dic?["id"] as? Int ?? 0
        self.mobile_numberl = Dic?["mobile_numberl"] as? String ?? ""
        self.country_id = Dic?["country_id"] as? Int ?? 0
        self.user_name = Dic?["user_name"] as? String ?? ""
        self.email = Dic?["email"] as? String ?? ""
        self.is_active = Dic?["is_active"] as? Int ?? 0
    }
}





struct RefreshTokenStruct {
    var result:TokenDateStruct
    var httpStatusCode:Int
    
    init(with Dic:[String:Any]?) {
        self.result = TokenDateStruct(with: Dic?["result"] as? [String:Any] ?? [:])
        self.httpStatusCode = Dic?["httpStatusCode"] as? Int ?? 0
    }
}

