//
//  FlickrAPI.swift
//  Annotate
//
//  Created by David Lang on 7/1/19.
//  Copyright © 2019 David Lang. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let latKey = "lat"
    static let lonKey = "lon"
    static let placeholderKey = "placeholder"
    static let pin = "pin"
    static let perPage = "12"
    static let responseFormat = "json"
    static let albumSegue = "albumSegue"
    static let flickerCell = "flickrCell"
    static let apiKey = "e79e37db8c17fb8f7b009ea28a20cb4c"
    
    struct Segues {
        static let flickrSearchSegue = "flickrSearchSegue"
        static let editorSegue = "editorSegue"
    }
}

struct FlickrSearchResult: Codable {
    let photos: FlickrPagesResult?
    let stat: String
}

struct FlickrPagesResult: Codable {
    let photo: [FlickrUrl]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
}

struct FlickrUrl: Codable {
    let id: String
    let farm: Int
    let owner: String
    let secret: String
    let server: String
    let title: String
}

class Flickr {
    
    var session: URLSession?
    
    class func buildDataTask( url: URL, completion: @escaping (Any?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil, response, error)
                return
            }
            completion(data, response, nil)
        })
    }
    
    /// Create a URLComponent and array of query items and return URL from the component as an optional
    class func buildTagQuery(_ tag: String, pageNumber: Int = 0) -> URL? {
        let queryItemTag = URLQueryItem(name: "tag", value: tag)
        let queryItemPerPage = URLQueryItem(name: "per_page", value: Constants.perPage)
        let queryItemPage = URLQueryItem(name: "page", value: "\(pageNumber)")
        let queryItemMethod = URLQueryItem(name: "method", value: "flickr.photos.getRecent")
        let queryItemAPIKey = URLQueryItem(name: "api_key", value: Constants.apiKey)
        let queryItemFormat = URLQueryItem(name: "format", value: Constants.responseFormat)
        let queryItemCallback = URLQueryItem(name: "nojsoncallback", value: "1")
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [queryItemMethod, queryItemAPIKey, queryItemTag, queryItemFormat, queryItemPerPage, queryItemPage, queryItemCallback]
        print(components.string)
        return components.url
    }
    
    /// Given a tag, request data on the associated images,
    /// this data is then used to build queries for single images
    ///
    /// - Parameters:
    ///   - coord: latitude and longitude as double
    ///   - pageNumber: for refreshing data with a randomized page number
    ///   - completion: FlickrSearchResults or error as optionals
    class func requestImageResources(tag: String, pageNumber: Int = 0, completion: @escaping ((FlickrSearchResult?, Error?) -> Void)) {
        let success = 200...299
        guard let url = buildTagQuery(tag, pageNumber: pageNumber) else {return}
        let task = buildDataTask(url: url) { (data, response, error) in
            guard error == nil, let data = data else {
                completion(nil, error!)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, success.contains(statusCode) else {
                completion(nil, ConnectionError.connectionFailure)
                return
            }
            let flickrSearchDecoder = JSONDecoder()
            do {
                let flickrResponseData = try flickrSearchDecoder.decode(FlickrSearchResult.self, from: data as! Data)
                completion(flickrResponseData, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    /// Create the URL for the specific image request
    ///
    /// - Parameter flickrUrl: Flickrpageresult has an array of these omponents of the URLs
    /// - Returns: provide the URL
    class func buildImageUrlString(_ flickrUrl: FlickrUrl) -> URL? {
        var components = URLComponents()
        let host = "farm" + String(flickrUrl.farm) + ".staticflickr.com"
        let path = "/\(flickrUrl.server)/\(flickrUrl.id)_\(flickrUrl.secret)_m.jpg"
        components.scheme = "https"
        components.host = host
        components.path = path
        return components.url
    }
    
    /// Send requests for images
    ///
    /// - Parameters:
    ///   - urlString: the urls are determined by informattion provided by the request images locaation function
    ///   - completion: Provide UIImage or error as optionals
    class func requestImage(urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let success = 200...299
        guard let url = URL(string: urlString) else {return}
        let task = buildDataTask(url: url) { (data, response, error) in
            guard error == nil, let data = data else {
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, success.contains(statusCode) else {
                completion(nil, ConnectionError.connectionFailure)
                return
            }
            guard let flickrImage = UIImage(data: data as! Data) else {
                completion(nil, error)
                return
            }
            completion(flickrImage, nil)
        }
        task.resume()
    }
}
