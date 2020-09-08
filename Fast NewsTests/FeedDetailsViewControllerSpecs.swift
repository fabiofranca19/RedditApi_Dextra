//
//  FeedDetailsViewControllerSpecs.swift
//  Fast NewsTests
//
//  Created by Fábio França on 07/09/20.
//  Copyright © 2020 Lucas Moreton. All rights reserved.
//

import UIKit

@testable import Fast_News
import Quick
import Nimble

@available(iOS 13.0, *)
class FeedDetailsViewControllerSpecs: QuickSpec {
    override func spec() {
        var sut: FeedDetailsViewController!
        
        beforeEach {
            sut = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(identifier: "FeedDetailsViewController")
        }
        
        context("getHotNewsDetails"){
            it("With invalid Url") {
                sut.getHotNewsDetails(provider: HotNewsProviderMock(status: .isInvalidUrl))
                expect(sut.comments.count) == 0
            }
            
            it("Sucess") {
                sut.getHotNewsDetails(provider: HotNewsProviderMock(status: .sucess))
                expect(sut.comments.count) == 1
            }
            
            it("Failure") {
                sut.getHotNewsDetails(provider: HotNewsProviderMock(status: .failure))
                expect(sut.comments.count) == 0
            }
        }
    }
}
