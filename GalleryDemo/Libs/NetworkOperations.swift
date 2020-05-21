//
//  NetworkOperations.swift
//  GalleryDemo
//
//  Created by SARAT CHANDRA HAZRA on 21/05/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation


class NetworkOperations {
    
    class func getOnlineImageData(_ closure : @escaping (_ responseObject: Any?,_ response: URLResponse?,_ errorDescription: String?)->()){

        let urlPath = "https://pixabay.com/api/?key=10961259-e4e939648ed5abb6879f1fbbc&q=yellow+flowers&image_type=photo"
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        
        var request = URLRequest.init(url: endpoint, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                closure(nil, response , error?.localizedDescription)
            }
            
            guard let responseData = data else {
                closure(nil, response, "unexpected error")
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                print("Serialized response --->> \(jsonData)")
                closure(jsonData, response, nil)
                
            }catch {
                print(error)
                closure(nil, response, "invalid json response")
            }
        }
        
        task.resume()

    }
}
