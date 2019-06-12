/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the “License”);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an “AS IS” BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

import Dispatch
import Foundation

func main(args: [String: Any]) -> [String: Any] {

    /// Retreive required parameters
    guard let baseURL = args["services.cloudant.url"] as? String,
        let database = args["services.cloudant.database"] as? String,
        let body = args["body"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]
    }

    /// Parse json payload
    guard let data = body.data(using: .utf8), var updatedJSON = parseJson(data: data) else {
        print("Error: unable to serialize body into json")
        return ["ok": false]
    }

    if let error = updatedJSON["error"] as? String {
        print("Error: \(error)")
        return ["ok": false, "error": error]
    }

    /// Ensure an object id has been provided
    guard let id = updatedJSON["id"] as? String else {
        print("Error: No ID provided in json object.")
        return ["ok": false]
    }

    /// Remove the duplicate id value
    updatedJSON.removeValue(forKey: "id")

    /// Endpoint to Cloudant document
    let documentURL = baseURL + "/" + database + "/" + id

    return update(url: documentURL, updatedJSON: updatedJSON)
}

/// Updates a cloudant json object with updated data
func update(url: String, updatedJSON: [String: Any]) -> [String: Any] {

    let errorResult: [String: Any] = ["ok": false]

    /// Retrieve original object from Cloudant
    guard let originalJSON = get(url) else {
        print("Error: Cloudant document does not exist.")
        return errorResult
    }

    /// Updated Cloudant entry
    let mergedJSON = originalJSON.merging(updatedJSON) { (_, new) in new }

    /// Encode JSONPayload as data
    do {
        let data = try JSONSerialization.data(withJSONObject: mergedJSON, options: [])

        guard let jsonString = String(data: data, encoding: .utf8) else {
            print("Error: Could not encode body.")
            return errorResult
        }

        /// Make update request
        guard let docData = request(url, body: data) else {
            print("Error: Invalid or missing response from Cloudant.")
            return errorResult
        }

        /// Parse update request response
        guard let jsonResult = parseJson(data: docData) else {
            return errorResult
        }
        
        if let error = jsonResult["error"] as? String {
            print("Error: \(error)")
            return errorResult
        }

        return ["ok": true, "document": jsonString]
    } catch let error {
        print("Error: Failed to load: \(error.localizedDescription)")
        return errorResult
    }
}

/// Read an entry in the database
func get(_ url: String) -> [String: Any]? {
    /// Make request to retrieve
    guard let responseData = request(url) else {
        return nil
    }

    return parseJson(data: responseData)
}

/// Networking Wrapper Method
func request(_ url: String, body: Data? = nil) -> Data? {
    var result = Data()
    let semaphore = DispatchSemaphore(value: 0)

    guard let endpoint = URL(string: url) else {
        print("Error: Failed to create a URL object")
        return nil
    }

    let method = body == nil ? "GET" : "PUT"

    /// Construct HTTP Request
    var request = URLRequest(url: endpoint)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    if let body = body {
        request.httpBody = body
    }

    URLSession.shared.dataTask(with: request) { (data: Data?, _, error: Error?) in
        defer {
            semaphore.signal()
        }

        if error != nil {
            print("Error: Invalid response from Cloudant")
            return
        }

        guard let data = data else {
            return
        }

        result = data
    }.resume()

    semaphore.wait(timeout: .distantFuture)
    return result.count != 0 ? result : nil
}

/// JSON parsing method
func parseJson(data: Data) -> [String: Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch let error {
        print("Error: Failed to load: \(error.localizedDescription)")
        return nil
    }
}
