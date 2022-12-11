//
//  File.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation

class LtkResponse: Decodable{
    var profiles: [Profile]
    var ltks: [LtkPost]
    var products: [Product] 
    

    /// creates an array of user profiles from the network call
    func createProfiles() ->[Profile]{
        
        // allows searching for profile with user id
        var profileDic: [ProfileIdString: Profile] = [:]
        
        // dictionary of products so they can be found by their product id
        var productDic: [ProductIdString : Product] = [:]

        // create a dictionary of profiles
        for profile in profiles {
            profileDic[profile.id] = profile
        }
        
        // create a dictionary of products
        for product in products {
            productDic[product.id] = product
        }
        
        // add ltks to profiles
        for ltk in ltks {
            let profile = profileDic[ltk.profileId]
            
            for product in ltk.productIds {
                ltk.products.append(productDic[product]!)
            }
            
            // add the ltk to our profile object
            profile?.ltks = ltk
        }
        
        return  profiles.compactMap { profileDic[$0.id] }
    }
}
