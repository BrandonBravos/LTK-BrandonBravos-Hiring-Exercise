//
//  ProfileObject.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit

class Profile: Decodable, HasDownloadableImages{

    /// an array of user posts
    var ltks: [LtkPost] = []
    
    /// the UIImage? heroImage object.
    var profileImage:UIImage?
    
    // MARK: Codable Data From Get Request
        /// the id of a user profile
        var id: String
        
        /// the url of a user profile image
        var avatarUrl: String
        
        /// unknown: url for uploading image?
        var avatarUploadUrl: String?
        
        /// the display name of our user
        var displayName: String
        
        /// full name of user
        var fullName: String?
        
        /// a users instagram username
        var instagramName: String?
        
        /// the blog username of our use
        var blogName: String?
        
        /// external link to blog
        var blogUrl: String?
        
        /// url link to a user profil background image
        var bgImageUrl: String?
        
        /// url link for post request to update profile background
        var bgUploadUrl: String?
        
        /// a short bio for a user profile
        var bio: String?
        
        var rsAccountId: Int?
        var searchable: Bool?
      
        
        //  convert API's snake case to iOS camel case
        private enum CodingKeys : String, CodingKey {
               case id = "id",
                    avatarUrl = "avatar_url",
                    avatarUploadUrl = "avatar_upload_url",
                    displayName = "display_name",
                    fullName = "full_name",
                    instagramName = "instagram_name",
                    blogName = "blog_name",
                    blogUrl = "blog_url",
                    bgImageUrl = "bg_image_url",
                    bgUploadUrl = "bg_upload_url",
                    bio = "bio",
                    rsAccountId = "rs_account_id",
                    searchable = "searchable"
           }
    
    lazy var downloadableImageUrls: [String] = {
        return [avatarUrl]
        }()
    
     func downloadImages(){
        NetworkManager.shared.downloadMultipleImages(downloadableImageUrls, completion: { result in
            self.profileImage = result.image
            })
        }
    }

protocol HasDownloadableImages{
    func downloadImages()
    var downloadableImageUrls: [String] { get }
}


