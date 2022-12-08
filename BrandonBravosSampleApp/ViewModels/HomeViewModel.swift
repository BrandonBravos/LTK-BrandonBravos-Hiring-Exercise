//
//  ViewControllerViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class HomeViewModel{
    
    // an array of our profiles
    private var profileArray = [Profile]()

    // an array of a tuple [(url, image)]
    private var urlImageArray: UrlImageTupleArray = []
    
    // a dictionary used to get profiles by post url image
    private var fetchUserDic = [ PostImageUrlString : Profile] ()

  
    /// returns an image in a list of loaded images
    func getImage(withIndex indexPath: IndexPath) -> UIImage?{
        return urlImageArray[indexPath.row].image
    }
    
    /// returns the count of our images
    func getCount() -> Int{
        return urlImageArray.count
    }
    
    /// used to get a user from a list of loaded images
    func getUser(withIndex indexPath: IndexPath) -> Profile{
        return fetchUserDic[urlImageArray[indexPath.row].url]!
    }
    
    // creates a dictionary for fetching user with post image url
    private func createUserFetchDic(){
        for profile in profileArray{
            fetchUserDic[(profile.ltks?.first?.heroImageUrl)!] = profile
        }
    }
    
    /// fetches for data, and only completes after all LTK's images are downloded
    func getPostData(completion: @escaping ()->()){
        NetworkManager.shared.fetchData{ [weak self] result in
            DispatchQueue.global(qos: .userInitiated).async {
                switch result{
                case .success(let response):
                    self?.profileArray = response
                    for profile in response{ profile.downloadImages()}
                    self?.fetchProductImages{ [weak self] result in
                        self?.urlImageArray = result
                        self?.createUserFetchDic()
                        completion()
                    }

                case.failure(let error):
                    //TODO: Handle Error
                    print("something went wrong \(error)")
                }
            }
        }
    }
    
    
    public func downloadExtras(){}
    
    // grabs all images from an array of urls
    private func fetchProductImages(completion: @escaping (UrlImageTupleArray) -> ()){
        let imageUrlArray = profileArray.map{ $0.ltks![0].heroImageUrl! }
        NetworkManager.shared.downloadImages(from: imageUrlArray, completed: completion)
    }
    

    
}
