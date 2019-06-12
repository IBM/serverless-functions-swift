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

struct CreateResponse: Codable {
    let ok: Bool
    let id, rev: String
}

func main(args: [String: Any]) -> [String: Any] {
    
    /// Retreive required parameters
    guard let baseURL = args["services.cloudant.url"] as? String,
        let database = args["services.cloudant.database"] as? String,
        let body = args["body"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]
    }

    return create(url: baseURL, database: database, json: body)
}

/// Networking method to insert entry into the database
func create(url: String, database: String, json: String) -> [String: Any] {

    var result: [String: Any] = ["ok": false]
    let semaphore = DispatchSemaphore(value: 0)
    
    /// Encode JSONPayload as data
    guard let data = String(describing: json).data(using: .utf8, allowLossyConversion: true) else {
        print("Error: Could not encode body as data")
        return result
    }
    
    /// Create URL object from url
    guard let endpoint = URL(string: url + "/" + database) else {
        print("Error: Failed to create a URL object")
        return result
    }
    
    /// Construct HTTP Request
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    URLSession.shared.dataTask(with: request) { (data: Data?, _, error: Error?) in
        defer {
            semaphore.signal()
        }
        
        if error != nil {
            print("Error: Invalid response from Cloudant")
            return
        }
        
        guard let data = data else {
            print("Error: Missing response from Cloudant")
            return
        }
        
        guard let json = try? JSONDecoder().decode(CreateResponse.self, from: data) else {
            print("Error: " + String(data: data, encoding: .utf8)!)
            return
        }
        
        if json.ok {
            result = ["ok": true, "document": json]
        }
    }.resume()
    
    semaphore.wait(timeout: .distantFuture)
    return result
}
