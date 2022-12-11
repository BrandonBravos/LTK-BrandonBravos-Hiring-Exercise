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

    // an array of posts that have loaded
    private var loadedPostsArray = [Profile]()
    
    // a dictionary used to get profiles by post url image
    private var fetchUserDic = [PostImageUrlString : Profile] ()
    
    /// returns an image in a list of loaded images
    func getImage(withIndex indexPath: IndexPath) -> UIImage?{
        return loadedPostsArray[indexPath.row].ltks.heroImage
    }
    
    /// returns the count of our images
    func getCount() -> Int{
        return loadedPostsArray.count
    }
    
    /// used to get a user from a list of loaded images
    func getUser(withIndex indexPath: IndexPath) -> Profile{
        return  loadedPostsArray[indexPath.row]
    }
    
    // creates a dictionary for fetching user with post image url
    private func createUserFetchDic(){
        for profile in profileArray{
            guard let post = profile.ltks else{
                return
            }
            fetchUserDic[ post.heroImageUrl] = profile
        }
    }
    
    func downloadPostImages(completion: @escaping ()->Void){
        NetworkManager.shared.downloadMultipleImages(profileArray.map{$0.ltks!.heroImageUrl}, completion: { test in
            let user = self.fetchUserDic[test.url]!
            user.ltks.heroImage = test.image
            user.downloadImages()
            self.loadedPostsArray.append(user)
            completion()
        })
    }
    
    /// fetches for data,
    func getPostData(completion: @escaping ()->()){
        NetworkManager.shared.fetchData{ [weak self] result in
                switch result{
                    case .success(let response):
                        self?.profileArray = response
                        self?.createUserFetchDic()
                    self?.downloadPostImages{
                        completion()
                    }
                    
                case.failure(let error):
                    //TODO: Handle Error
                    print("something went wrong \(error)")
                }
        }
    }
}
