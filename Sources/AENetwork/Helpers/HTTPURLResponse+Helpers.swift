/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

// MARK: - Headers

public extension HTTPURLResponse {
    func headerValue(forKey key: String) -> Any? {
        let foundKey: String = allHeaderFields.keys.first {
            "\($0)".caseInsensitiveCompare(key) == .orderedSame
            } as? String ?? key
        return allHeaderFields[foundKey]
    }
}

// MARK: - Description

public extension HTTPURLResponse {
    var shortDescription: String {
        let code = statusCode
        let status = HTTPURLResponse.localizedString(forStatusCode: code).capitalized
        return "\(code) \(status)"
    }
    var fullDescription: String {
        let headers = "\(allHeaderFields as? [String : Any] ?? [String : String]())"
        return """
        - Response: \(shortDescription)
        - Headers: \(headers)
        """
    }
}
