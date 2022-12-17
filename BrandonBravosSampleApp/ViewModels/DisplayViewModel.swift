//
//  DisplayViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewModel{
    // the user profile related to this display
    private var user: Profile!
    
    // the post that is being shared
    private var ltk: LtkPost!
    
    var metaData: ResponseMeta?
    public var isLoading = false

    // the api used to get other posts from the same user
    let apiUrl = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?profile_id="
    let apiUrlEndLimit = "&limit=10"

    // main media for currently displayed post
    private var postPicture: UIImage = UIImage()
    
    // products related to this post
    private var products: [Product] = []
    
    // an array of (url, images) of the products related to this post, this is downloaded once displayed
    private var loadedProducts = [Product]()
    
    // the users profile image, this begins download with post
    private var profileImage: UIImage?
    
    // a dictionary of strings used to update our product when an image has finished downloading
    private var productLinkDic = [ProductImageUrlString : Product]()
    
    // this dictionary is used to connect posts that have loaded their image to the users ltk
    private var ltkLinkDic = [PostImageUrlString : LtkPost]()
    
    // an array of posts that have loaded
    public var loadedPostsArray = [LtkPost]()
    
    
    init(user: Profile, ltk: LtkPost){
        self.user = user
        self.ltk = ltk
        self.products = ltk.products
        
        for product in products{
            productLinkDic[product.imageUrl] = product
        }
        
        // add our users already loaded ltks to prevent showing a post twice
        for post in user.ltks{
            ltkLinkDic[post.heroImageUrl] = post
        }
    }
    
    /// gets the post pictures and product images
    public func fetchProductData(completion: @escaping ()->()){
        guard let user = user else {
            print("error finding user")
            return
        }
       
        self.profileImage = user.profileImage
        self.postPicture = ltk.heroImage!
   
        var productImageUrls = [String]()
        for product in products{ productImageUrls.append(product.imageUrl) }
        
        downloadProductImages(urls: productImageUrls){[weak self] result in
            DispatchQueue.main.async {
                let product = self?.productLinkDic[result.url]
                product?.productImage = result.image
                self?.loadedProducts.append(product!)
                completion()
            }
        }
    }
    
    // gets our users post data, checks if that post has been loaded, and if it hasnt, adds it to our users dicStore and ltk list
    func getUserPostData(completion: @escaping ()->()){
        isLoading = true
        var url = apiUrl + user.id + apiUrlEndLimit
                
        if let meta = metaData{
            guard let nextUrl = meta.nextURL else {
                print("metaData: No more Posts")
                return
            }
                url = nextUrl
        }
        
        NetworkManager.shared.fetchData(withUrl: url){ [weak self] result in
                switch result{
                    case .success(let response):
                    self?.isLoading = false
                    self?.loadedPostsArray = response.profiles.first!.ltks
                    self?.metaData = response.meta
                    self?.createUserFetchDic()

                    var postImagesToDownload = [String]()
                    for post in self!.loadedPostsArray{
                        // if our user doesnt have this post, add it to our toDownload array
                        if self?.user.ltksDicStore[post.heroImageUrl] == nil{
                            postImagesToDownload.append(post.heroImageUrl)
                        }
                    }

                    self?.downloadProductImages(urls: postImagesToDownload, completion: { response in
                        // set the posts image
                        let post = self?.ltkLinkDic[response.url]
                        post?.heroImage = response.image
                        // add the post to our users loaded post
                        self?.user.ltks.append(post!)
                        
                        // add the post to our users ltk dictionary storage
                        self?.user.ltksDicStore[response.url] = post
                        
                       //  print("loadedLtks = \(self!.user.ltks.count) MaxPost: \(self!.metaData!.totalResults)")
                        completion()
                    })
                    
                case.failure(let error):
                    //TODO: Handle Error
                    print("something went wrong \(error)")
                }
        }
    }
    
    func createUserFetchDic(){
        for ltk in loadedPostsArray{
            ltkLinkDic[ltk.heroImageUrl] = ltk
        }
    }
    
    func downloadProductImages(urls: [String], completion: @escaping (UrlImageTuple) -> ()){
        NetworkManager.shared.downloadMultipleImages(urls, completion: {result in
            completion(result)
        })
    }
    
    public func getUser() -> Profile{
        return user
    }
    
    public func getLoadedProductsCount() -> Int{
        return loadedProducts.count
    }
    
    public func getProductImage(withIndex indexPath: IndexPath) -> UIImage{
        return loadedProducts[indexPath.row].productImage ?? UIImage()
    }
    
    public func getPostImage() -> UIImage{
        return postPicture
    }
    
    public func getProfilePicture ()-> UIImage?{
        return user?.profileImage
    }
    
    public func getProductUrl(withIndexPath indexPath: IndexPath)-> String?{
        return loadedProducts[indexPath.row].hyperlink
    }
}
