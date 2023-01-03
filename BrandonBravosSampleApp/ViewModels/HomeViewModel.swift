//
//  DiscoverViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

class HomeViewModel {
    // the meta data assoicated with our network response
    var metaData: ResponseMeta?

    // used to check if we are loading data, if we are, this bool prevents from making multiple network calls
    public var isLoading = false

    // an array of our featured profiles from our network call
    public var profileArray = [Profile]()

    // a dictionary used to get profiles by post url image.
    private var fetchUserDic = [PostImageUrlString: Profile]()

    // the api to get our featured profiles and posts from
    private let apiURL = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=10"

    // creates a dictionary for fetching user with post image url. once an image has loaded,
    // the dic is used to update the users post
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
        NetworkManager.shared.downloadMultipleImages(profileArray.map {$0.ltks.first!.heroImageUrl}) { [self] result in
            let user = self.fetchUserDic[result.url]!
            user.ltks.first!.getPostImage { _ in
                user.getProfileImage { _ in
                    self.downloadProductImages(post: user.ltks.first!) {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            completion(user)
                        }
                    }
                }
            }
        }
    }
    
    // downloads our posts products, and only updates when all product images are loaded
    private func downloadProductImages(post: LtkPost, completion: @escaping () -> Void) {
        let count = post.products.count
        var index = 0
        for product in post.products {
            product.getProductImage { _ in
                index += 1
                if index == count {
                    completion()
                }
            }
        }
    }

    /** fetches for a list of featured users and their featured posts.
        only returns a fully loaded profile when the profiles featured post is loaded, along with its product images
     */
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

        NetworkManager.shared.fetchData(withUrl: url) { [weak self] result in
            switch result {
            case .success(let response):
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
