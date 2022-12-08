//
//  LTKObject.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import Foundation
import UIKit

class LtkPost: Decodable{
    
    /// an array of posts related products
    var products: [Product]?
    
    /// returns an [(url, uiimage)] of the posts main image
    var heroImage = UrlImageTupleArray()
    
    /// url that returns post image
    var heroImageUrl: String?
    
    /// main images width
    var heroWidth: Int?
    
    /// main images height
    var heroImageHeight: Int?
    
    /// unique id for post
    var id: String?
    
    /// unknown: do not use
    var profileId: String?
    
    /// the parent creator id related to the post
    var profileUserId: String?
    
    /// unknown
    var videoMediaId: String?
    
    var status: String?
    
    /// the date in which the post was created
    var dateCreated: String?
    
    /// the date in which the post was last updated
    var dateUpdated: String?
    
    /// release time for post
    var dateScheduled: String?
    
    /// the published date for which the post was shared
    var datePublished: String?
    
    /// caption related to post
    var caption: String?
    
    ///url for deep sharing
    var shareUrl: String?
    
    /// an array of products related to this post
    var productIds: [String]?
    
    //  convert API's snake case to iOS camel case
    private enum CodingKeys : String, CodingKey {
           case heroImageUrl = "hero_image",
                heroWidth = "hero_width",
                heroImageHeight = "hero_image_height",
                id = "id",
                profileId = "profile_id",
                profileUserId = "profile_user_id",
                videoMediaId = "video_media_id",
                status = "status",
                dateCreated = "date_created",
                dateUpdated = "date_updated",
                dateScheduled = "date_scheduled",
                datePublished = "date_published",
                caption = "caption",
                shareUrl = "share_url",
                productIds = "product_ids"
       }

}



