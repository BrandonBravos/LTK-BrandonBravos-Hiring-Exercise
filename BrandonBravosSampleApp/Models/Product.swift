//
//  ProductObject.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation
import UIKit

struct Product: Decodable{
   

    
    // MARK: Codable Data From Get Request

        /// product unique id
        var id: String
    
        /// ltk id
        var ltkId: String
    
        /// external web link
        var hyperlink: String?
    
        /// url used to retrieve  data
        var imageUrl: String
    
        /// varying links for different devices and routing
        var links: ProductLinks
    
        /// unknown
        var matching: String?
    
        /// unknown
        var productDetailsId: String?
    
        /// id for retailer
        var retailerId: String?
    
        /// returns the retailer for the product
        var retailerDisplayNamelet: String?
        
    //  convert API's snake case to iOS camel case

        private enum CodingKeys : String, CodingKey {
               case id = "id",
                    ltkId = "ltk_id",
                    hyperlink = "hyperlink",
                    imageUrl = "image_url",
                    links = "links",
                    matching = "matching",
                    productDetailsId = "product_details_id",
                    retailerId = "retailer_id",
                    retailerDisplayNamelet = "retailer_display_namelet"
           }
    
    public func getProductImage(completion: @escaping(UIImage?)->()){
        NetworkManager.shared.downloadImage(imageUrl, completion: { result in
            switch result{
            case.success(let img):
                return completion(img.image)
            case .failure(let err):
                print("Unable to get profile image, Error: \(err)")
                return completion(nil)
            }
            
        })
    }
}

 class ProductLinks: Decodable{
     let ANDROID_CONSUMER_APP: String?
     let ANDROID_CONSUMER_APP_SS: String?
     let IOS_CONSUMER_APP: String?
     let IOS_CONSUMER_APP_SS: String?
     let LTK_EMAIL: String?
     let LTK_WEB: String?
     let LTK_WIDGET: String?
     let TAILORED_EMAIL: String?
 }

 
