//
//  BreweryDB.swift
//  Brauhaus Finder
//
//  Created by Rebekah Sippert on 8/7/17.
//
//

import Foundation

/// Class that handles fetching and parsing of location and brewery data
class BreweryDB {
    
    enum DBError : Error {
        case queryNotEncoded
        case couldNotParse
    }
    
    static let baseURL = "https://api.brewerydb.com/v2/"
    static let locationEndpoint = "locations"
    static let apiKey = "c5a5172a55da9928de26c1d10663373d"
    
    // TODO: create loadBreweries function that takes in a page number to load more results on scrolling
    
    /// Fetches list of breweries within the given state
    ///
    /// - Parameters:
    ///   - state: state to use in the locations query
    ///   - completionHandler: called with array of breweries if successful, or an error if unsuccessful
    static func loadBreweries(state: String, completionHandler: @escaping ([Brewery], Error?) -> ()) {
        let urlString = "\(baseURL)\(locationEndpoint)?key=\(apiKey)&region=\(state)&order=breweryName"
    
        guard let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedUrl) else {
            completionHandler([], DBError.queryNotEncoded)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            guard error == nil else {
                completionHandler([], error)
                return
            }
            
            if let data = data {
                var json: [String:Any]
                
                do {
                    json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                } catch {
                    completionHandler([], DBError.couldNotParse)
                    return
                }
                
                let breweries = self.parseBreweries(json: json)
                completionHandler(breweries, nil)
            }

        }).resume()
    }
    
    /// Creates a list of Brewery objects from JSON that is parsed
    ///
    /// - Parameter json: JSON to parse
    /// - Returns: Array of Brewery objects
    static func parseBreweries(json: [String:Any]) -> [Brewery] {
        let locationJson = json["data"] as! [[String:Any]]
            
        var breweries = [Brewery]()
        for location in locationJson {
            let newBrewery = Brewery()
            guard let breweryJson = location["brewery"] as? [String:Any],
                let name = breweryJson["name"] as? String else {
                return []
            }
            
            newBrewery.name = name
            
            if let imagesJson = breweryJson["images"] as? [String:Any],
                let mediumSquareImage = imagesJson["squareMedium"] as? String {
                newBrewery.imageUrl =  URL(string: mediumSquareImage)
            }
            
            if let description = breweryJson["description"] as? String {
                newBrewery.description = description
            }
            
            if let websiteString = breweryJson["website"] as? String {
                newBrewery.websiteUrl = URL(string: websiteString)
            }
            
            breweries.append(newBrewery)
        }
        
        return breweries
    }
    
    /// Gets image data from a URL
    ///
    /// - Parameters:
    ///   - imageUrl: URL to load image data
    ///   - completionHandler: called with Data object on success and an Error on failure
    static func fetchBreweryImageData(imageUrl: URL, completionHandler: @escaping (Data?, Error?)->()) {
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(data, nil)
        }.resume()
    }
}
