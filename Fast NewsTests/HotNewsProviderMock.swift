//
//  HotNewsProviderMock.swift
//  Fast NewsTests
//
//  Created by Fábio França on 07/09/20.
//  Copyright © 2020 Lucas Moreton. All rights reserved.
//

import UIKit
@testable import Fast_News

enum Status {
       case isInvalidUrl
       case sucess
       case failure
   }

class HotNewsProviderMock: ProviderProtocol {
    let status: Status
    
    let new = HotNews(id: "teste", title: "teste", preview: Preview(), url: "teste", created: 0, ups: 0, downs: 0, score: 0, authorFullname: "teste", numComments: 0)
    var news = [HotNews]()
    
    init(status: Status) {
        self.status = status
        news.append(new)
    }
    
    func hotNews(kAfterValue: String,completion: @escaping HotNewsCallback){
        switch status {
        case .isInvalidUrl:
            completion{ throw HotNewsError.isInvalidUrl }
        case .sucess:
            completion{return (news,"Next Page")}
            break
        case .failure:
            completion{ throw HotNewsError.failure }
        }
    }
    
    func hotNewsComments(id: String, completion: @escaping HotNewsCommentsCallback){
        
    }
}
