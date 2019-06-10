//
//  API.swift
//  IOSARSample
//
//  Created by Viethai Pham on 11/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import RxCocoa
import RxSwift
import Foundation

public final class OneMapClient {
  private let urlSession: URLSession
  
  public init(urlSession: URLSession) {
    self.urlSession = urlSession
  }
  
  public func reverseGeocode(query: String) -> Single<Any> {
    let urlString = "https://developers.onemap.sg/commonapi/search"
    var components = URLComponents(string: urlString)!
    
    components.queryItems = [
      URLQueryItem(name: "searchVal", value: query),
      URLQueryItem(name: "returnGeom", value: "Y"),
      URLQueryItem(name: "getAddrDetails", value: "Y"),
      URLQueryItem(name: "pageNum", value: "1")
    ]
    
    return urlSession.rx.json(url: components.url!).asSingle()
  }
}
