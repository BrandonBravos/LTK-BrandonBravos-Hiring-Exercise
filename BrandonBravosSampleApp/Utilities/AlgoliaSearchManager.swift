//
//  AlgoliaSearchManager.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/20/22.
//

import Foundation
import AlgoliaSearchClient

final class AlgoliaSearchManager {
    enum LtkSearchAttributes: String {
        case caption, products
    }
    
    static let shared = AlgoliaSearchManager()

    private let appID:ApplicationID = "05QIQA4DU2"
    private let apiKey:APIKey = "81cdfa4e1863a08d85b779c59345305d"
    private let indexName:IndexName = "bravos_tests"
    
    private var index: Index!
    private var client: SearchClient!

    init() {
        client = SearchClient(appID: self.appID , apiKey: self.apiKey)
        index = client.index(withName: self.indexName)
        
        let settings = Settings()
            .set(\.searchableAttributes, to: ["hashtags", "displayName"])
        index.setSettings(settings) { result in
            switch result {
            case .failure(let error):
                print("Error when applying settings: \(error)")
            case .success:
                print("Success applying settings")
            }
        }
    }

    func algoliaSearch(withString searchString: String, completion: @escaping (SearchResponse) -> Void) {
        let query = Query(searchString)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let results = try self.index.search(query: query)
                if results.hits.isEmpty {
                    return
                }
                completion(results)
            } catch(let error) {
                print("we have an error \(error)")
            }
        }
    }
}
