//
//  ViewControllerViewModel.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

class DiscoveryViewModel{

    // the meta data assoicated with our network response
    var metaData: ResponseMeta?
    
    // used to check if we are loading data, if we are, this bool prevents from making multiple network calls
    public var isLoading = false
    
    // an array of our featured profiles from our network call
    public var profileArray = [Profile]()

    // an array of users whos feature posts have loaded.
    private var loadedPostsArray = [Profile]()
    
    // a dictionary used to get profiles by post url image.
    private var fetchUserDic = [PostImageUrlString : Profile] ()
    
    // the api to get our featured profiles and posts from
    private let apiURL = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=10"
    
    
    /// returns an image in a list of loaded images
    func getImage(withIndex indexPath: IndexPath, completion: @escaping (UIImage?)->CGFloat){
        loadedPostsArray[indexPath.row].ltks.first!.getPostImage{ image in
           _ = completion(image)
        }
    }
    
    
    
    /// returns the count of our images
    func getLoadedPostsCount() -> Int{
        return loadedPostsArray.count
    }
    
    /// used to get a user from a list of loaded images
    func getUser(withIndex indexPath: IndexPath) -> Profile{
        return  loadedPostsArray[indexPath.row]
    }
    
    // creates a dictionary for fetching user with post image url. once an image has loaded, the dic us used to update the users post
    private func createUserFetchDic(){
        for profile in profileArray{
            guard let post = profile.ltks.first else{
                return
            }
            fetchUserDic[post.heroImageUrl] = profile
        }
    }
    
    // once an image has been downloaded, add it to the users post, then allow it to be shown in our collection view
    func downloadPostImages(completion: @escaping ()->Void){
        NetworkManager.shared.downloadMultipleImages(profileArray.map{$0.ltks.first!.heroImageUrl}, completion: { test in
            let user = self.fetchUserDic[test.url]!
            user.ltks.first!.getPostImage{image in
                self.loadedPostsArray.append(user)
                completion()
            }
          
        })
    }
    
    /// fetches for a list of featured users and their featured posts.
    func getPostData(completion: @escaping ()->()){
        isLoading = true
        var url = apiURL
        
        // if we have meta data, we want to load the posts from it's 'next url'. this gives us oir continuos scroll
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
                    self?.profileArray = response.profiles
                    self?.metaData = response.meta
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