//
//  ContentView.swift
//  WebScraper
//
//  Created by Parineet Vernekar on 14/08/2023.
//

import SwiftUI
import Foundation
import SwiftSoup
import WidgetKit

struct ContentView: View {
    @State var capacity = "Fetching.."
    @State var gym : Gyms = .Milton_Keynes
    @StateObject var controller = FetchCapacity()
    
  
    
    func fetchAllData(){
        controller.fetchData(completionHandler: {cap in
            self.capacity = cap ?? "Loading..."
        })
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var body: some View {
        ZStack {
           
            VStack {
               
                HStack{
                    Button("Get data for"){
                        print("FETCHING..")
                        fetchAllData()

                    }
                    Picker("Choose gym", selection: $gym){
                        ForEach(Gyms.allCases){option in
                            Text(String(describing: option))
                        }
                    }.onChange(of: gym, perform: {(value) in
                        controller.gym = value
                        fetchAllData()
                    })
                }
                Text(capacity)
                    .padding()
            }.onAppear(perform: fetchAllData)
            if controller.isLoading{
                ProgressView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
