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
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjI3NTcsInVzZXJfaWQiOjI3NTcsImVtYWlsIjoic3dpZnRlbi5zdmNAZ21haWwuY29tIiwiZm9yZXZlciI6ZmFsc2UsImlzcyI6Imh0dHA6XC9cL29tMi5kZmUub25lbWFwLnNnXC9hcGlcL3YyXC91c2VyXC9zZXNzaW9uIiwiaWF0IjoxNTYwOTU1MjgwLCJleHAiOjE1NjEzODcyODAsIm5iZiI6MTU2MDk1NTI4MCwianRpIjoiODc3OTk2N2UwOTNkNWFjMzQ4YTUwZTdmMWEwNzUyYjQifQ.bWZJDMhlJQ0w_WdKysx1A-gqB_oll9Hzc72XcfYS_1U
""")
    ]
    
    return self.urlSession.rx.json(url: components.url!)
      .map({($0 as? [String : Any])?["route_instructions"] as? [[Any]]})
      .map({try $0.getOrThrow("")})
      .map({$0.compactMap({($0[1] as? String).zipWith($0[3] as? String, {
        return RouteInstruction(street: $0, coordinate: .fromString($1), icon: nil)
      })})})
      .asSingle()
  }
  
  public func routeIcon(streetName: String) -> URL? {
    switch streetName.lowercased() {
    case "marina way":
      return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Marina_One.jpg/480px-Marina_One.jpg")
      
    case "central boulevard":
      return URL(string: "https://www.99.co/blog/singapore/wp-content/uploads/2016/08/marina-bay.jpeg")
      
    case "cross street":
      return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Cross_Street%2C_Oct_06.JPG/300px-Cross_Street%2C_Oct_06.JPG")
      
    case "telok ayer street":
      return URL(string: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Telok_Ayer_Street%2C_Dec_05.JPG")
      
    case "mccallum street":
      return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/McCallum_Street.JPG/280px-McCallum_Street.JPG")
      
    case "stanley street":
      return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Stanley_Street%2C_Oct_06.JPG/300px-Stanley_Street%2C_Oct_06.JPG")
      
    default:
      return nil
    }
  }
}
