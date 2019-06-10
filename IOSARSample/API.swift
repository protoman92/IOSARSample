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
  public struct ReverseGeocoded: Decodable {
    public struct Result: Decodable {
      public let LATITUDE: String
      public let LONGITUDE: String
    }
    
    public let found: Int
    public let pageNum: Int
    public let results: [Result]
  }
  
  private let jsonDecoder: JSONDecoder
  private let urlSession: URLSession
  
  public init(jsonDecoder: JSONDecoder, urlSession: URLSession) {
    self.jsonDecoder = jsonDecoder
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
    
    let jsonDecoder = self.jsonDecoder
    
    return urlSession.rx.json(url: components.url!)
      .map({try JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)})
      .map({try jsonDecoder.decode(ReverseGeocoded.self, from: $0)})
      .asSingle()
  }
}
