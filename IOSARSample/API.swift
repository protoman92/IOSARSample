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

public final class GeoClient {
  private let jsonDecoder: JSONDecoder
  private let urlSession: URLSession
  
  public init(jsonDecoder: JSONDecoder, urlSession: URLSession) {
    self.jsonDecoder = jsonDecoder
    self.urlSession = urlSession
  }
  
  public func reverseGeocode(query: String) -> Single<ReverseGeocoded> {
    let urlString = "https://developers.onemap.sg/commonapi/search"
    var components = URLComponents(string: urlString)!
    
    components.queryItems = [
      URLQueryItem(name: "searchVal", value: query),
      URLQueryItem(name: "returnGeom", value: "Y"),
      URLQueryItem(name: "getAddrDetails", value: "Y"),
      URLQueryItem(name: "pageNum", value: "1")
    ]
    
    let jsonDecoder = self.jsonDecoder
    
    return self.urlSession.rx.json(url: components.url!)
      .map({try JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)})
      .map({try jsonDecoder.decode(ReverseGeocoded.self, from: $0)})
      .asSingle()
  }
  
  public func route(start: Coordinate, end: Coordinate) -> Single<[RouteInstruction]> {
    let urlString = "https://developers.onemap.sg/privateapi/routingsvc/route"
    var components = URLComponents(string: urlString)!
    
    components.queryItems = [
      URLQueryItem(name: "start", value: start.toString()),
      URLQueryItem(name: "end", value: end.toString()),
      URLQueryItem(name: "routeType", value: "drive"),
      URLQueryItem(name: "token", value: """
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjI3NTcsInVzZXJfaWQiOjI3NTcsImVtYWlsIjoic3dpZnRlbi5zdmNAZ21haWwuY29tIiwiZm9yZXZlciI6ZmFsc2UsImlzcyI6Imh0dHA6XC9cL29tMi5kZmUub25lbWFwLnNnXC9hcGlcL3YyXC91c2VyXC9zZXNzaW9uIiwiaWF0IjoxNTYwMzQzNzYyLCJleHAiOjE1NjA3NzU3NjIsIm5iZiI6MTU2MDM0Mzc2MiwianRpIjoiNDQ3YWJiODU0YjhiNGRhMDNmNDU3MTMyNWViYTdkM2IifQ.WIG2K8RJ-r_F9RGXm4UzfVsKghgDWAlfdotbFrpNMNA
""")
    ]
    
    return self.urlSession.rx.json(url: components.url!)
      .map({($0 as? [String : Any])?["route_instructions"] as? [[Any]]})
      .map({try $0.getOrThrow("")})
      .map({$0.compactMap({($0[1] as? String).zipWith($0[3] as? String, {
        return RouteInstruction(street: $0, coordinate: .fromString($1))
      })})})
      .asSingle()
  }
}
