//
//  GymDataFetcher.swift
//  WebScraper
//
//  Created by Parineet Vernekar on 15/08/2023.
//

import Foundation
import SwiftSoup
struct Capacity : Codable{
    var value : String?
}

@MainActor
class FetchCapacity: ObservableObject{
    @Published var gym : Gyms = .Milton_Keynes
    @Published var isLoading : Bool = false
    func fetchData(completionHandler: @escaping (String?)->Void){
        self.isLoading = true
        guard let url = URL(string: "https://www.kissgyms.com/headcount.php") else {
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url){data, response, error in
            if let error = error{
                print(error)
                return
            }
            
            guard let data = data else{
                print("DATA NOT RIGHT")
                return
            }
            
            guard let htmlString = String(data: data, encoding: .utf8) else{
                print("DATA NOT CONVERTING")
                return
            }
            
            print("h2:contains(\(self.$gym)) + h1.text-center")
            do {
                let doc = try SwiftSoup.parse(htmlString)
                // Find the latest headlines
                let headlines = try doc.select("h2:contains(\(self.gym)) + h1.text-center")
                
                // Print out the headlines
                for headline in headlines {
                    print(try headline.text())
                    let cap = try headline.text()
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completionHandler(cap)
                    }
                    
                }
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
}
