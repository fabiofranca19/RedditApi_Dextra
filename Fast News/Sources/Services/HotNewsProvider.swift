//
//  HotNewsProvider.swift
//  Fast News
//
//  Copyright © 2019 Lucas Moreton. All rights reserved.
//

import Foundation
import Alamofire

//MARK: - HotNewsError
enum HotNewsError: Error {
    case isInvalidUrl
    case failure
}

//MARK: - Provider Protocol
protocol ProviderProtocol {
    func hotNews(kAfterValue: String,completion: @escaping HotNewsCallback)
    func hotNewsComments(id: String, completion: @escaping HotNewsCommentsCallback)
}

//MARK: - Type alias
typealias HotNewsCallback = ( () throws -> ([HotNews],String)) -> Void
typealias HotNewsCommentsCallback = ( () throws -> [Comment]) -> Void

class HotNewsProvider: ProviderProtocol {
    
    //MARK: - Constants
    
    // Hot News endpoint
    private let kHotNewsEndpoint = "/r/ios/hot/.json"
    // Comments endpoint
    private let kCommentsEndpoint = "/r/ios/comments/@.json"
    
    // Hot News key/value parameters
    private let kLimitKey = "limit"
    private let kLimitValue = 5
    private let kAfterKey = "after"
    //private var kAfterValue = ""
    
    //MARK: - Singleton
    
    static let shared: HotNewsProvider = HotNewsProvider()
    
    //MARK: - Pagination Sets
    
    var isPaginating = false
    
    //MARK: - Public Methods
    
    func hotNews(kAfterValue: String,completion: @escaping HotNewsCallback) {
        let alamofire = APIProvider.shared.sessionManager
        let requestString = APIProvider.shared.baseURL() + kHotNewsEndpoint
        
        let parameters: Parameters = [ kLimitKey : kLimitValue,
                                       kAfterKey : kAfterValue]
        
        if !kAfterValue.isEmpty {
            isPaginating = true
        }
        
        do {
            let requestURL = try requestString.asURL()
            
            let headers: HTTPHeaders = APIProvider.shared.baseHeader()
            
            alamofire.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    
                    guard let hotNewsDict = response.result.value as? [String: AnyObject],let after = hotNewsDict["data"]?["after"] as? String,
                          let dictArray = hotNewsDict["data"]?["children"] as? [[String: AnyObject]] else {
                        completion { return ([HotNews](),"") }
                        return
                    }
                    
                    print(after)
                    var hotNewsArray: [HotNews] = [HotNews]()
                    
                    for hotNews in dictArray {
                        let data = hotNews["data"]
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data as Any, options: .prettyPrinted),
                              let hotNews = try? JSONDecoder().decode(HotNews.self, from: jsonData) else {
                            completion { return ([HotNews](),"") }
                            return
                        }
                        
                        hotNewsArray.append(hotNews)
                    }
                    
                    completion { return (hotNewsArray,after) }
                    if !kAfterValue.isEmpty {
                        self.isPaginating = false
                    }
                    break
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    completion { throw HotNewsError.failure }
                    break
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
            completion { throw HotNewsError.isInvalidUrl }
        }
    }
    
    func hotNewsComments(id: String, completion: @escaping HotNewsCommentsCallback) {
        let alamofire = APIProvider.shared.sessionManager
        let endpoint = kCommentsEndpoint.replacingOccurrences(of: "@", with: id)
        let requestString = APIProvider.shared.baseURL() + endpoint
        
        do {
            let requestURL = try requestString.asURL()
            
            let headers: HTTPHeaders = APIProvider.shared.baseHeader()
            
            alamofire.request(requestURL, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    
                    guard let hotNewsDict = response.result.value as? [[String: AnyObject]],
                        let dictArray = hotNewsDict.last?["data"]?["children"] as? [[String: AnyObject]] else {
                            completion { return [Comment]() }
                            return
                    }
                    
                    var commentsArray: [Comment] = [Comment]()
                    
                    for comment in dictArray {
                        let data = comment["data"]
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data as Any, options: .prettyPrinted),
                            let comment = try? JSONDecoder().decode(Comment.self, from: jsonData) else {
                                completion { return [Comment]() }
                                return
                        }
                        
                        if !comment.isEmpty() {
                            commentsArray.append(comment)
                        }
                    }
                    
                    completion { return commentsArray }
                    break
                case .failure(let error):
                    completion { throw HotNewsError.failure }
                    break
                }
            }
        } catch {
            completion { throw HotNewsError.isInvalidUrl }
        }
    }
}
