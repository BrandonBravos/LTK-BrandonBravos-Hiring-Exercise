//
//  DisplayViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewModel {
    // the user profile related to this display
    private var user: Profile!

    // the post that is being shared
    public var ltk: LtkPost!

    var metaData: ResponseMeta?
    public var isLoading = false

    // the api used to get other posts from the same user
    let apiUrl = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?profile_id="
    let apiUrlEndLimit = "&limit=4"

    // products related to this post
    private var products: [Product] = []

    // an array of (url, images) of the products related to this post, this is updated once a products image has been downloaded
    private var loadedProducts = [Product]()

    // a dictionary of strings used to update our product when an image has finished downloading
    private var productLinkDic = [ProductImageUrlString: Product]()

    // this dictionary is used to connect posts that have loaded their image to the users ltk
    private var ltkLinkDic = [PostImageUrlString: LtkPost]()

    // an array of posts that have loaded
    public var loadedPostsArray = [LtkPost]()

    init(user: Profile, ltk: LtkPost) {
        self.user = user
        self.ltk = ltk
        self.products = ltk.products

        for product in products {
            productLinkDic[product.imageUrl] = product
        }

        // add our users already loaded ltks to prevent showing a post twice
        for post in user.ltks {
            ltkLinkDic[post.heroImageUrl] = post
        }
    }

    /// gets the post pictures and product images
    public func fetchProductData(completion: @escaping () -> Void) {
        let productImageUrls = products.map {$0.imageUrl}
        downloadProductImages(urls: productImageUrls) { [weak self] result in
            let product = self?.productLinkDic[result.url]
            product?.getProductImage { _ in
                DispatchQueue.main.async {
                    self?.loadedProducts.append(product!)
                    completion()
                }
            }
        }
    }

    // gets our users post data, checks if that post has been loaded,
        // and if it hasnt, adds it to our users dicStore and ltk list
    func getUserPostData(completion: @escaping () -> Void) {
        isLoading = true
        var url = apiUrl + user.id + apiUrlEndLimit

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
                self?.isLoading = false
                self?.loadedPostsArray = response.profiles.first!.ltks
                self?.metaData = response.meta
                self?.createUserFetchDic()
                var postImagesToDownload = [String]()
                guard let postArray = self?.loadedPostsArray else {
                    return
                }
                for post in postArray where self?.user.ltksDicStore[post.heroImageUrl] == nil {
                        postImagesToDownload.append(post.heroImageUrl)
                }

                self?.downloadProductImages(urls: postImagesToDownload) { response in
                    guard let post = self?.ltkLinkDic[response.url] else {
                        return
                    }
                    post.getPostImage { _ in
                        DispatchQueue.main.async {
                            self?.user.ltks.append(post)
                            self?.user.ltksDicStore[response.url] = post
                            completion()
                        }
                    }
                }

            case.failure(let error):
                print("something went wrong \(error)")
            }
        }
    }

    func createUserFetchDic() {
        for ltk in loadedPostsArray {
            ltkLinkDic[ltk.heroImageUrl] = ltk
        }
    }

    func downloadProductImages(urls: [String], completion: @escaping (UrlImageTuple) -> Void) {
        NetworkManager.shared.downloadMultipleImages(urls, completion: { result in
            completion(result)
        })
    }

    public func getUser() -> Profile {
        return user
    }

    public func getLoadedProductsCount() -> Int {
        return loadedProducts.count
    }

    public func getProductImage(withIndex indexPath: IndexPath, completion: @escaping(UIImage?) -> Void) {
        loadedProducts[indexPath.row].getProductImage(completion: { image in
            completion(image)
        })
    }

    public func getPostImage(completion: @escaping(UIImage?) -> Void) {
        ltk.getPostImage { image in
            completion(image)
        }
    }

    public func getProfilePicture(completion: @escaping(UIImage?) -> Void) {
        user.getProfileImage { result in
            return completion(result)
        }
    }

    public func getProductUrl(withIndexPath indexPath: IndexPath) -> String? {
        return loadedProducts[indexPath.row].hyperlink
    }
}
