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
    
    // products related to this post
    private var products: [Product] = []
    
    // main  media for post
    private var postPicture: UIImage = UIImage()
    
    // an array of (url, images) of the products related to this post, this is downloaded once displayed
    private var loadedProducts = [Product]()
    
    // the users profile image, this begins download with post
    private var profileImage: UIImage?
    
    // a dictionary of strings used to update our product when an image has finished downloading
    private var productLinkDic = [ProductImageUrlString : Product]()
    
    init(user: Profile){
        self.user = user
        self.products = user.ltks!.products
        for product in products{
            productLinkDic[product.imageUrl] = product
        }
    }
    
    /// gets the post pictures and product images
    public func fetchData(completion: @escaping ()->()){
        guard let user = user else {
            print("error finding user")
            return
        }
        
        guard let post = user.ltks else{
            print("Unable to find post")
            return
        }
       
        self.profileImage = user.profileImage
        self.postPicture = post.heroImage!
   
        downloadProductImages{[weak self] result in
            DispatchQueue.main.async {
                let product = self?.productLinkDic[result.url]
                product?.productImage = result.image
                self?.loadedProducts.append(product!)
                completion()
            }
        }
    }
    
    func downloadProductImages(completion: @escaping (UrlImageTuple) -> ()){
        var urls = [String]()
        for product in products{ urls.append(product.imageUrl) }
        NetworkManager.shared.downloadMultipleImages(urls, completion: {result in
            completion(result)
    
        })
    }
    
    public func getUser() -> Profile{
        return user
    }
    
    public func getCount() -> Int{
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
