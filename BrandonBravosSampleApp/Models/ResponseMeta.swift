//
//  Meta.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/16/22.
//

import Foundation

class ResponseMeta: Decodable{
    var lastId: String
    var numberOfResults: Int
    var totalResults: Int
    var limit: Int
    var nextURL: String
    
    //  convert API's snake case to iOS camel case
    private enum CodingKeys : String, CodingKey {
           case lastId = "last_id",
                numberOfResults = "num_results",
                totalResults = "total_results",
                limit = "limit",
                nextURL = "next_url"
       }
}
