//
//  Flicker_API.swift
//  Virtual Tourist
//
//  Created by Mawhiba Al-Jishi on 16/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

// API Key :
// a72f3dc708c41c39ae7f4f4adb680e48
// secret :
// 419bea593aac3620

import Foundation
import MapKit

struct Flicker_API {

    static func photosURL(with coordinates: CLLocationCoordinate2D, pageNo: Int, completion: @escaping ([URL]? , Error? , String?) -> ()){
        
        //MARK: get bbox :
        let minLatitude = max((coordinates.latitude) - 1.0 , -90.0)
        let maxLatitude = min((coordinates.latitude) + 1.0 , 90.0)
        let minLogitude = max((coordinates.longitude) - 1.0 , -180)
        let maxLongitude = min((coordinates.longitude) + 1.0 , 180)
        let bbox = "\(minLogitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
        
        //MARK: URL Parameters :
        let parameters = [
            "method" : "flickr.photos.search",
            "api_key" : "a72f3dc708c41c39ae7f4f4adb680e48",
            "bbox" : bbox ,
            "safe_search" : "1",
            "extras" : "url_m",
            "format" : "json" ,
            "nojsoncallback" : "1",
            "page" : pageNo ,
            "per_page" : 6
            ] as [String : Any]
        
        
        let request = URLRequest(url: formatURLComponent(from: parameters))
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(nil,error,nil)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {return}
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                if data != nil {
                    guard let dataResult = try? JSONSerialization.jsonObject(with: data!, options:[]) as! [String:Any] else {
                        completion(nil, nil, "Faild serialize JSON object")
                        return
                    }
                    guard let resultStatus = dataResult["stat"] as? String , resultStatus == "ok" else {
                        completion(nil,error?.localizedDescription as? Error, nil)
                        return
                    }
                    guard let imgDict = dataResult["photos"] as? [String : Any] else {
                        completion(nil,error?.localizedDescription as? Error, nil)
                        return
                    }
                    guard let imgArray = imgDict["photo"] as? [[String : Any]]  else {
                        completion(nil,error?.localizedDescription as? Error, nil)
                        return
                    }
    
                    var imagesURLS = [URL]()
                    for imgDict in imgArray {
                        guard let stringURLS = imgDict["url_m"] as? String else {return}
                        let URLS = URL(string: stringURLS)
                        imagesURLS.append(URLS!)
                    }
                    completion(imagesURLS, nil, nil)
                }
            } else {
                switch httpStatusCode {
                case 400:
                    completion(nil, nil, "Bad Request")
                    return
                case 401:
                    completion(nil, nil, "Invalid Credentials")
                    return
                case 403:
                    completion(nil, nil, "Unauthorized")
                    return
                case 405:
                    completion(nil, nil, "HttpMethod Not Allowed")
                    return
                case 410:
                    completion(nil, nil, "URL Changed")
                    return
                case 500:
                    completion(nil, nil, "Server Error")
                    return
                default:
                    completion(nil, error?.localizedDescription as? Error, "")
                }
            }
        }
        task.resume()
    
    }

    //MARK: Crete URL Components:
    static func formatURLComponent (from params: [String:Any]) -> URL {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "api.flickr.com"
        urlComponent.path = "/services/rest"
        urlComponent.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let qItem = URLQueryItem(name: key, value: "\(value)")
            urlComponent.queryItems!.append(qItem)
        }
        return urlComponent.url!
    }
    
    
    //End of struct
}



