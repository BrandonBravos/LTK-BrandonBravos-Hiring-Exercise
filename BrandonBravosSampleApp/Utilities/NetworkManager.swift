//
//  NetworkManager.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/6/22.
//

import UIKit
import AVFoundation

enum NetworkError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}

class NetworkManager {
    /// the shared instance of this Network manager
    static let shared = NetworkManager()
    
    // the maximum amount of images we want to download at once.
    private let maxDownloadThreads = 8
    private let operationQueue = OperationQueue()

    /// gets LTKS, Profiles and Products. Returns a Result<(profiles: [Profile], meta: MetaResponse), NetworkError>
    func fetchProfilesAndMeta(withUrl urlStr:String, completed: @escaping NetworkResult) {
        guard let url = URL(string: urlStr) else {
            completed(.failure(.invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if error != nil {
                completed(.failure(.unableToComplete))
                print("NetworkManager: Error")
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                print("NetworkManager: Invalid Response")
                return
            }
            guard let data = data else {
                completed(.failure(.invalidData))
                print("NetworkManager: Invalid Data")
                return
            }
            do {
                // self.printJsonData(with: data)  // used for debugging
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(LtkResponse.self, from: data)
                completed(.success((decodedResponse.meta, decodedResponse.createFeaturedProfiles())))

            } catch {
                print("NetworkManager: UnableToDecode")
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }

    /// creates a temporary folder for caching
    func storeImage(urlString: String, image: UIImage) {
        // create a temporary path
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)

        // not needed, since we already reize image to be smaller, but may be useful for further implementaitons
        let data = image.jpegData(compressionQuality: 0.7)

        // write data to our temp folder
        try? data?.write(to: url)

        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]
        if dict == nil {
            dict = [String:String]()
        }

        dict![urlString] = path
        UserDefaults.standard.set(dict, forKey: "ImageCache")
    }

    // returns a result with a succesful image tuple (url, tuple)
    func downloadImage(_ urlString: String, completion: @escaping (Result<UrlImageTuple, NetworkError>) -> Void) {
        var returnImage: UrlImageTuple = ("" ,UIImage())
        // check to see if we have image saved in cache
        if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
            if let path = dict[urlString] {
                // unwrap the data
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    returnImage = (urlString, UIImage(data: data)!)
                    completion(.success(returnImage))
                    return
                }
            }
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // do our network call
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }

            let imageQuality: CGFloat = 1.5 // 2 is a good medium for smooth scrolling on both iPad and iPhone
            let width = UIScreen.main.bounds.width * imageQuality

            // resize the image, resizing is needed to keep frame rate low while scrolling
            let finalImage = image.resizeImage(toSize: CGSize(width: width, height: image.getHeightAspectRatio(withWidth: width)))
            self.storeImage(urlString: urlString, image: finalImage)
            returnImage = (urlString, finalImage)
            completion(.success(returnImage))
        }
        task.resume()
    }

    // downloads multiple images at once
    func downloadMultipleImages(_ urls: [String], completion:  @escaping (UrlImageTuple) -> Void) {
        operationQueue.maxConcurrentOperationCount = maxDownloadThreads
        operationQueue.qualityOfService = .userInitiated
        for url in urls {
            // add block operations, each one downoads an image to our queue
            let operation = BlockOperation()
            operation.addExecutionBlock {
                self.downloadImage(url, completion: { result in
                    switch result {
                    case .success(let tuple):
                        let result: UrlImageTuple = ( tuple.url, tuple.image)
                        completion(result)
                    case.failure(let error):
                        print("error downloading image \(error)")
                        let result: UrlImageTuple = ("", UIImage(named: "heart_icon_selected")!)
                        completion(result)
                    }
                })
            }
            operationQueue.addOperation(operation)
        }
    }

    /// a function used for debugging, prints out a json object
    private func printJsonData(with data: Data) {
        let serialize = try? JSONSerialization.jsonObject(with: data)
        print(serialize ?? "json error")
    }
}
