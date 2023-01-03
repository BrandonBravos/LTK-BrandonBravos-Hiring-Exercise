//
//  ProductObject.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation
import UIKit

struct Product: Decodable {
    /// product unique id
    var id: String
    
    /// ltk id
    var ltkId: String
    
    /// external web link
    var hyperlink: String?

    /// url used to retrieve  data
    var imageUrl: String
    
    /// unknown
    var matching: String?
    
    /// unknown
    var productDetailsId: String?
    
    /// id for retailer
    var retailerId: String?

    /// returns the retailer for the product
    var retailerDisplayNamelet: String?

    //  convert API's snake case to iOS camel case
    private enum CodingKeys: String, CodingKey {
        case id = "id",
             ltkId = "ltk_id",
             hyperlink = "hyperlink",
             imageUrl = "image_url",
             matching = "matching",
             productDetailsId = "product_details_id",
             retailerId = "retailer_id",
             retailerDisplayNamelet = "retailer_display_namelet"
    }

    public func getProductImage(completion: @escaping(UIImage?) -> Void) {
        NetworkManager.shared.downloadImage(imageUrl, completion: { result in
            switch result {
            case.success(let img):
                return completion(img.image)
            case .failure(let err):
                print("Unable to get profile image, Error: \(err)")
                return completion(nil)
            }
        })
    }
}
