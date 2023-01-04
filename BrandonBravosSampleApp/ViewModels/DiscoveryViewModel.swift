//
//  ViewControllerViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DiscoveryViewModel {
    // the meta data assoicated with our network response
    var metaData: ResponseMeta?

    // used to check if we are loading data, if we are, this bool prevents from making multiple network calls
    public var isLoading = false

    // this sees if the view has been loaded, if it has then we do not download data agin
    public var hasInitialized = false

    // an array of our featured profiles from our network call
    public var profileArray = [Profile]()

    // a dictionary used to get profiles by post url image.
    private var fetchUserDic = [PostImageUrlString:Profile]()

    // the api to get our featured profiles and posts from
    private let apiURL = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=10"

    // creates a dictionary for fetching user with post image url.
    // once an image has loaded, the dic us used to update the users post
    private func createUserFetchDic() {
        for profile in profileArray {
            guard let post = profile.ltks.first else {
                return
            }
            fetchUserDic[post.heroImageUrl] = profile
        }
    }

    // once an image has been downloaded, add it to the users post, then allow it to be shown in our collection view
    func downloadPostImages(completion: @escaping (Profile) -> Void) {
        NetworkManager.shared.downloadMultipleImages(profileArray.map {$0.ltks.first!.heroImageUrl}) { result in
            guard let user = self.fetchUserDic[result.url] else {
                print("Error fetching user")
                return
            }
            user.ltks.first!.getPostImage { _ in
                completion(user)
            }
        }
    }

    /// fetches for a list of featured users and their featured posts.
    func getPostData(completion: @escaping (Profile) -> Void) {
        isLoading = true
        var url = apiURL

        // if we have meta data, we want to load the posts from it's 'next url'. this gives us oir continuos scroll
        if let meta = metaData {
            guard let nextUrl = meta.nextURL else {
                print("metaData: No more Posts")
                return
            }
            url = nextUrl
        }
        NetworkManager.shared.fetchProfilesAndMeta(withUrl: url) { [weak self] result in
            switch result {
            case .success(let response):
                self?.isLoading = false
                self?.profileArray = response.profiles
                self?.metaData = response.meta
                self?.createUserFetchDic()
                self?.downloadPostImages { profile in
                    completion(profile)
                }
            case.failure(let error):
                print("something went wrong \(error)")
            }
        }
    }
}
