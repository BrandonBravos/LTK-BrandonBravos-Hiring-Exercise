//
//  NetworkManager.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit
import AVFoundation

enum NetworkError: Error{
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}



class NetworkManager{
    
    /// the shared instance of this Network manager
    static let shared = NetworkManager()
    private let apiURL = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=20"

    
    
    /// gets LTKS, Profiles and Products.
    func fetchData(completed: @escaping NetworkResult){
        
        guard let url = URL(string: apiURL) else {
            completed(.failure(.invalidURL))
            return
        }
               
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            if let _ =  error {
                completed(.failure(.unableToComplete))
                return
            }
                        
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                
               // self.printJsonData(with: data)  // used for debugging
                
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(LtkResponse.self, from: data)
                completed(.success(decodedResponse.createProfiles()))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
 
    
    /// creates a temporary folder for caching
     func storeImage(urlString: String, img: UIImage){
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        
        let data = img.jpegData(compressionQuality: 0.5)
        try? data?.write(to: url)
        
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]
       
         if dict == nil{
            dict = [String:String]()
        }
         
        dict![urlString] = path
        UserDefaults.standard.set(dict, forKey: "ImageCache")
        
    }
    
    /// downloads and returns a dictionary of UIImages? with their url being the key
    func downloadAllImages(_ urls: [String], completion: @escaping ([UrlImageTuple]) -> ()) {
        var images = [UrlImageTuple]()
        
        
        for urlString in urls {
           // let cacheKey = NSString(string: urlString)
            
            if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]{
                if let path = dict[urlString]{
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                        let img = UIImage(data: data)
                        images.append((urlString, img!))
                        print("using cached image")
                        completion(images)
                        continue
                    }
                }
            }

            
            guard let url = URL(string: urlString) else {
                completion([])
                return
            }
            
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let image = UIImage(data: data) else {
                    completion([])
                    return
                }
                
                //TODO: reduce imageQuality based on device width
                let imageQuality: CGFloat = 2 // 2 is a good medium for smooth scrolling on both iPad and iPhone
                let width = UIScreen.main.bounds.width * imageQuality
               
                // resize the image, resizing is needed to keep frame rate low while scrolling
                let finalImage = image.resizeImage(toSize: CGSize(width: width, height: image.getHeightAspectRatio(withWidth: width)))
                self.storeImage(urlString: urlString, img: finalImage)
                images.append((urlString, finalImage))
                completion(images)
            }
            
            task.resume()
        }

    }
   
    
    
    func downloadImage(_ urlString: String, completion: @escaping (Result<UrlImageTuple, NetworkError>) -> Void) {
            var returnImage: UrlImageTuple = ("" ,UIImage())
        
            if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]{
                if let path = dict[urlString]{
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                        returnImage = (urlString, UIImage(data: data)!)
                        print("downloadImage(): using cached image")
                        completion(.success(returnImage))
                    }
                }
            }

            
            guard let url = URL(string: urlString) else {
                completion(.failure(.invalidURL))
                return
            }
            
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(.invalidData))
                    return
                }
                
                //TODO: reduce imageQuality based on device width
                let imageQuality: CGFloat = 2 // 2 is a good medium for smooth scrolling on both iPad and iPhone
                let width = UIScreen.main.bounds.width * imageQuality
               
                // resize the image, resizing is needed to keep frame rate low while scrolling
                let finalImage = image.resizeImage(toSize: CGSize(width: width, height: image.getHeightAspectRatio(withWidth: width)))
                self.storeImage(urlString: urlString, img: finalImage)
                returnImage = (urlString, finalImage)
                completion(.success(returnImage))
            }
            
            task.resume()
        
        
    }
    
        
    /// a function used for debugging, prints out a json object
    private func printJsonData(with data: Data){
        let serialize = try? JSONSerialization.jsonObject(with: data)
        print(serialize ?? "json error")
    }
        
        
}
