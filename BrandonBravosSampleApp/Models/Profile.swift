//
//  ProfileObject.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit

class Profile: Decodable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// an array of user posts. Post should not be added unless their images have been loaded
    var ltks: [LtkPost] = []

    /// this is used to get a used to get a users post based on a url string.
    var ltksDicStore: [PostImageUrlString: LtkPost] = [:]
    
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
    private enum CodingKeys: String, CodingKey {
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

    public func getProfileImage(completion: @escaping(UIImage?) -> Void) {
        NetworkManager.shared.downloadImage(avatarUrl) { result in
            switch result {
            case.success(let img):
                return completion(img.image)
            case .failure(let err):
                print("Unable to get profile image, Error: \(err)")
                return completion(nil)
            }
        }
    }
}
