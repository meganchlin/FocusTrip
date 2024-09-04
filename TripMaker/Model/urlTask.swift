//
//  urlTask.swift
//  TripMaker
//
//  Created by Megan Lin on 3/19/24.
//

import Foundation
import UIKit

struct ImageInfo: Codable {
    let urls: Urls
}

struct Urls: Codable {
    let raw: String
    var rawUrl: URL {
        return URL(string: raw)!
    }
}

struct WikipediaResponse: Decodable {
    let extract: String
}

class urlTask {
    var finished = false
    let db: DBManager
    //var image: [String: String] = [:]
    
//    var httpString = "https://api.unsplash.com/photos/random?query=taipei/600x600"
    let baseURL = "https://api.unsplash.com/photos/"
    let imageSize = "/300x400"
    
    let photoId: [String: [String: String]] = [
        "Taiwan": ["Bangka Lungshan Temple": "krPkCYVahXc", "National Taichung Theater": "31UvcGZKgS8", "Jiufen": "UDv1n0xIpU8", "Taipei 101": "qhu2nFWqVEU", "Formosa Boulevard metro station": "4SD7fsm4NRQ", "Fo Guang Shan Buddha Museum": "sxXm1_Jf-ns", "Yehliu": "_Rh5TxWLjF4", "Chiang Kai-shek Memorial Hall": "K-29Bnhke_E"],
        "South Korea": ["Gyeongbokgung Palace": "dQytkIHYzYQ", "Myeong-dong": "nq4tcJz77r0", "N Seoul Tower": "zwi5M-SA77I", "Bukchon Hanok Village": "-e6Xu27_T50", "Cheonggyecheon": "wNWxhHjdl6Q", "Haedong Yonggungsa": "kO0w49YXfSY", "Gamcheon Culture Village": "mLKkqlqFiZ4"],
        "Canada": ["Niagara Falls": "Gcc3c6MfSM0", "Notre-Dame Basilica": "iJuzlfA8LxE", "Old Quebec": "mSVRrKEZAH8", "Butchart Gardens": "Ahj_8PUivJI", "CN Tower": "6wVqCeK030Y", "Granville Island": "0UqEQDNJcUw", "Old Montreal": "PT3QQdjhMzw", "Canadian Parliament Buildings": "ReUoz0CwfGo", "Capilano Suspension Bridge Park": "YHXs0hKaeok"]
    ]
        
    
    let wikiBaseURL = "https://en.wikipedia.org/api/rest_v1/page/summary/"
    
    //var locationDescription: [String: String] = [:]
    
    
    let authString = "" //fill in with unsplash auth
    
    func httpString(route: String, locationName: String) -> String {
        return baseURL + (photoId[route]?[locationName] ?? "random")// + imageSize
    }
    
    init() {
        db = DBManager.shared
    }
    
    func fetchLocationPicture(route: String, for title: String) {
        
        do {
            let detail = try db.fetchLocationDetails(name: title)
            if detail.realPicture != "" {
                return
            }
        } catch{
            print("picture already in the database")
        }
        
            
        download(urlString: httpString(route: route, locationName: title)) { imageString in
//            print(String(describing: imageString))
            guard let imageString = imageString else {
                print("Failed to download image.")
                return
            }
                
            DispatchQueue.main.async {
                //print(imageString)
                    
                do {
                    try self.db.updateLocatioPicture(name: title, newRealPicture: imageString)
                        
                    //print("Location added with name: \(self.locationName)")
                } catch {
                    print("Database operation error: \(error)")
                }
                    
                self.finished = true
            }
        }
    }

    func download(urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(authString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred during download: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server.")
//                print(response.debugDescription)
                print(String(describing: response))
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from server.")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let picInfo = try decoder.decode(ImageInfo.self, from: data)
                URLSession.shared.dataTask(with: picInfo.urls.rawUrl) { locData, locResponse, locError in
                    if let locError = locError {
                        print("Error occurred during image download: \(locError.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    guard let locData = locData, let image = UIImage(data: locData) else {
                        print("Failed to convert image data.")
                        completion(nil)
                        return
                    }
                    
                    let imageString = stringFromImage(image)
                    completion(imageString)
                }.resume()
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchLocationDescription(for title: String) {
        
        do {
            let detail = try db.fetchLocationDetails(name: title)
            if detail.description != "" {
                return
            }
        } catch{
            print("description already in the database")
        }
        
        let formattedTitle = title.replacingOccurrences(of: " ", with: "_")
        let entireUrl = wikiBaseURL + formattedTitle
        
        guard let url = URL(string: entireUrl) else {
            print("Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error occurred during download: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Description Invalid response from server.")
                return
            }
            
            guard let data = data else {
                print("No data received from server.")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let wikiResponse = try decoder.decode(WikipediaResponse.self, from: data)
                let sentencesArray = wikiResponse.extract.components(separatedBy: ". ").prefix(3)
                var sentences = sentencesArray.joined(separator: ". ")
                if let lastSentence = sentencesArray.last, !lastSentence.hasSuffix(".") {
                    sentences += "."
                }
                
                //self.locationDescription[title] = sentences
                try self.db.updateLocatioDescription(name: title, newDescription: sentences)
                
                print("\nDescription for \(title):")
                print(sentences)
            } catch {
                print("Error during decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
