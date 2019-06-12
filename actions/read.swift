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
        let id = args["id"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]
    }
    
    return get(url: baseURL, database: database, docId: id)
}

/// Read an entry in the database
func get(url: String, database: String, docId: String) -> [String: Any] {
    
    var result: [String: Any] = ["ok": false]
    let semaphore = DispatchSemaphore(value: 0)
    
    /// Create URL object from url
    guard let endpoint = URL(string: url + "/" + database + "/" + docId) else {
        print("Error: Failed to create a URL object")
        return result
    }
    
    /// Construct HTTP Request
    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
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
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            if let error = json["error"] as? String {
                print("Error: \(error)")
                result = ["ok": false, "error": error]
                return
            }
            
            result = ["document": json]
        } catch let error {
            print("Error: Failed to load: \(error.localizedDescription)")
            return
        }
        
    }.resume()
    
    semaphore.wait(timeout: .distantFuture)
    return result
}
