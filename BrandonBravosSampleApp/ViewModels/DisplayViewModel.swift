//
//  DisplayViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DisplayViewModel{
    
    /// the user profile related to this display
    private var user: Profile?
    
    /// products related to this post
    private var products: [Product]?
    
    /// main  media for post
    private var postPicture: UIImage? = UIImage()
    
    /// an array of (url, images) of the products related to this post, this is downloaded once displayed
    private var productImages = UrlImageTupleArray()
    
    /// the users profile image, this begins download with post
    private var profileImage = UrlImageTupleArray()
    
    /// a dictionary of strings used to help correct any misaligned links on the collection view
    private var productLinkDic = [String : String]()
    
    
    /// returns the posts user
    public func getUser() -> Profile{
        return user!
    }
    
    public func getCount() -> Int{
        return productImages.count
    }
    
    /// IMPORTANT: use this for initialization of the display view.
    public func setUser(user: Profile){
        self.user = user
        self.products = user.ltks?.first?.products
        
        for product in products!{
            productLinkDic[product.imageUrl] = product.hyperlink
        }
    }
    
    public func getProductImage(withIndex indexPath: IndexPath) -> UIImage{
        return productImages[indexPath.row].image
    }
    
    public func getPostImage() -> UIImage{
        return postPicture!
    }
    
    public func getProfilePicture ()-> UIImage?{
        return user?.profileImage.first?.image
    }
    
    public func getProductUrl(withIndexPath indexPath: IndexPath)-> String?{
       
        return productLinkDic[productImages[indexPath.row].url]
    }
    
    /// gets the post pictures and product images
    public func fetchData(completion: @escaping ()->()){
        NetworkManager.shared.downloadImages(from: [user!.ltks![0].heroImageUrl!], completed: { result in
            self.postPicture = result.first?.image
            DispatchQueue.global(qos: .userInitiated).async {
            self.fetchImages{ [weak self] result in
                self?.productImages = result
                completion()
            }
        }
        
    })
        

    }
    
    /// grabs all images from an array of urls
    private func fetchImages(completion: @escaping (UrlImageTupleArray) -> ()){
        var urls = [String]()
        for product in products!{urls.append(product.imageUrl)}
        NetworkManager.shared.downloadImages(from: urls, completed: completion)
    }
    
    private func fetchProfileImage(completion: @escaping (UrlImageTupleArray) -> ()){
        NetworkManager.shared.downloadImages(from: [user!.avatarUrl], completed: completion)
    }
}
