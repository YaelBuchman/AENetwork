/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class CacheTests: XCTestCase, NetworkCacheDelegate {

    let cache = Cache(storage: URLCache())
    let request = URLRequest(url: URL(string: "https://httpbin.org/get")!)

    var useCache = false
    var validateCache = false

    override func setUp() {
        cache.delegate = self
    }

    func shouldCacheResponse(from request: URLRequest) -> Bool {
        return useCache
    }

    func isValidCache(_ cache: CachedURLResponse) -> Bool {
        return validateCache
    }

    func testCache() {
        performRequest { [weak self] (data, response, error) in
            if let response = response as? HTTPURLResponse, let data = data, error == nil {
                self?.validateNotSavingResponse(response: response, withData: data)
                self?.validateSavingResponse(response: response, withData: data)
                self?.validateLoadingFromCache()
                self?.validateNotLoadingFromCache()
            } else {
                XCTAssert(false, "Should be able to perform a request.")
            }
        }
    }

    private func validateNotSavingResponse(response: HTTPURLResponse, withData data: Data) {
        useCache = false
        cache.saveResponse(response, with: data, from: request)

        let ignoredResponse = cache.storage.cachedResponse(for: request)
        XCTAssertNil(ignoredResponse, "Should be able to store response to cache.")
    }

    private func validateSavingResponse(response: HTTPURLResponse, withData data: Data) {
        useCache = true
        cache.saveResponse(response, with: data, from: request)

        let savedResponse = cache.storage.cachedResponse(for: request)
        XCTAssertNotNil(savedResponse, "Should be able to store response to cache.")
    }

    private func validateLoadingFromCache() {
        validateCache = true
        let cachedResponse = cache.loadResponse(for: request)
        XCTAssertNotNil(cachedResponse, "Should be able to load valid response from cache.")
    }

    private func validateNotLoadingFromCache() {
        validateCache = false
        let invalidCachedResponse = cache.loadResponse(for: request)
        XCTAssertNil(invalidCachedResponse, "Should return nil if cache is not valid.")
    }

    private func performRequest(with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let requestExpectation = expectation(description: "Request")

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
            requestExpectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 5, handler: nil)
    }

}
