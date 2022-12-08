//
//  File.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation

class LtkResponse: Decodable{
    var ltks: [LtkPost]
    var profiles: [Profile]
    var products: [Product]
    
    
    /// creates an array of user profiles from the network call
    func createProfiles() ->[Profile]{
        
        // allows searching for profile with user id
        var profileDic: [ProfileIDString: Profile] = [:]

        // create a dictionary of profiles
        for profile in profiles {
            profileDic[profile.id] = profile
            profile.ltks = []
        }
        
        // add ltks to profiles
        for ltk in ltks {
            
            // add ltk to profile
            let id = ltk.profileId!
            let profile = profileDic[id]
            
            if profile?.ltks == nil{
                profile?.ltks = []
            }
            
            // add the ltk to our profile object
            profile?.ltks!.append(ltk)
            
        }
        
        // dictionary of products so they can be found by their product id
        var productDic: [ProductIdString : Product] = [:]
        
        for product in products {
            productDic[product.id] = product
        }
        
        // sort through our ltks product ids, use our product Dic to check out products
        for ltk in ltks {
            for product in ltk.productIds! {
                if ltk.products == nil{
                    ltk.products = []
                }
                ltk.products?.append(productDic[product]!)
            }
        }
        
        // flatten our user dictionary into an array
        var userArray: [Profile] = []
        for (_, value) in profileDic{
            userArray.append(value)
        }
        
        return userArray
    }
}
