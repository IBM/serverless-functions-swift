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

struct DeleteResponse: Codable {
    let ok: Bool
}

func main(args: [String: Any]) -> [String: Any] {
    
    /// Retreive required parameters
    guard let baseURL = args["services.cloudant.url"] as? String,
        let database = args["services.cloudant.database"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]
    }
    
    return delete(url: baseURL, database: database)
}

/// Delete an entry in the database
func delete(url: String, database: String) -> [String: Any] {
    
    let databaseURL = url + "/" + database
    
    // Drop Database
    guard let deleteResponse = request(databaseURL, method: "DELETE"), let json = try? JSONDecoder().decode(DeleteResponse.self, from: deleteResponse), json.ok == true else {
            print("Error: Could not delete database - \(database)")
            return ["ok": false]
    }
    
    // Recreate Database
    guard let createResponse = request(databaseURL, method: "PUT") else {
        print("Error: Could not recreate database - \(database)")
        return ["ok": false]
    }
    
    guard let result = try? JSONDecoder().decode(DeleteResponse.self, from: createResponse) else {
        print("Error: could not decode JSON response from Cloudant.")
        return ["ok": false]
    }
    
    return ["ok": result.ok == true]
}

/// Networking Wrapper Method
func request(_ url: String, method: String = "GET") -> Data? {

    var result: Data?
    let semaphore = DispatchSemaphore(value: 0)

    guard let endpoint = URL(string: url) else {
        print("Error: Failed to create a URL object")
        return nil
    }

    /// Construct HTTP Request
    var request = URLRequest(url: endpoint)
    request.httpMethod = method
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

        result = data
    }.resume()

    semaphore.wait(timeout: .distantFuture)
    return result
}
