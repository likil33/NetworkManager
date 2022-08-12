//
//  URLConstants.swift
//  NetworkManagerSwift
//
//  Created by Santhosh K on 12/08/22.
//

import Foundation


// Application used urls
struct APPURL {
    
    private struct Domains {
        static let Dev = ""
        static let Prod = ""
        static let cms = ""
    }
    
    //Auth Route of Url
    private  struct Routes {
        static let user = ""
        static let Live = ""
    }
    
    private  static let Domain = Domains.Dev
    private  static let baseRoute = Routes.user
    private  static let BaseURL = Domain //+ without user
    private  static let BaseURLWithRoute = Domain + baseRoute
    private static let cmsPages = Domains.cms
    
    // User
    static var userPhotoVideo:String {return BaseURL + "userPhotoVideo/signup/"}
    static var heightRange:String {return BaseURLWithRoute + "cms/heightRange"}

}


