//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 11/04/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
    
    private  struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map({ $0.local })
        }
    }
    
    private struct CodableFeedImage: Codable {
        private var id : UUID
        private var description : String?
        private var location : String?
        private var url : URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    //make queue to run task concurrently but allow some tasks to run in serial order by using .barrier flag
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    //retrieve has no seide effects(we proved in test cases) so it should run concurrently and (insert & delete serially)
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        //async - without blocking the thread
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.feed.map({ $0.local }), timestamp: cache.timestamp))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        //async - without blocking the thread
        
        //'barrier' flag will keep the queue on hold untill(deleteCachedFeed: :) method is done executing - deleteCachedFeed method has side effects so we allow this to be run serially by using .barrier flag on concurrent queue
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(feed: [LocalFeedImage] , timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        //async - without blocking the thread
        
        //'barrier' flag will keep the queue on hold untill(insert(: :) method) is done executing - insert method has side effects so we allow this to be run serially by using .barrier flag on concurrent queue
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

