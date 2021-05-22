//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 21/02/21.
//

import Foundation

public class URLSessionHTTPClient : HTTPClient {
    private let session : URLSession
    
    public init(session : URLSession = .shared) {
        self.session = session
    }
    
    private struct UnExpectedValuesRepresentation : Error {}
    
    public func get(from url : URL, completion : @escaping (HTTPClient.Result) -> Void) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnExpectedValuesRepresentation()))
            }
        }).resume()
    }
}
