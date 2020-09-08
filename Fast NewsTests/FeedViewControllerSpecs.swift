//
//  FeedViewsControllerSpecs.swift
//  Fast NewsTests
//
//  Created by Fábio França on 07/09/20.
//  Copyright © 2020 Lucas Moreton. All rights reserved.
//

@testable import Fast_News
import Quick
import Nimble

@available(iOS 13.0, *)
class FeedViewControllerSpecs: QuickSpec{
    override func spec() {
        describe("FeedViewController") {
            var sut: FeedViewController!
            
            beforeEach {
                sut = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(identifier: "FeedViewController")
            }
            
            context("getHotNews"){
                it("With invalid Url") {
                    sut.getHotNews(provider: HotNewsProviderMock(status: .isInvalidUrl))
                    expect(sut.after) != "Next Page"
                }
                
                it("Sucess") {
                    sut.getHotNews(provider: HotNewsProviderMock(status: .sucess))
                    expect(sut.after) == "Next Page"
                }
                
                it("Failure") {
                    sut.getHotNews(provider: HotNewsProviderMock(status: .failure))
                    expect(sut.after) != "Next Page"
                }
            }
        }
    }
}
