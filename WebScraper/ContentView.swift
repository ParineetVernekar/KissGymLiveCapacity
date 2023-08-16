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
    
    var body: some View {
        VStack {
            
            HStack{
                Button("Get data for"){
                    print("FETCHING..")
                    controller.fetchData()
                    WidgetCenter.shared.reloadAllTimelines()

                }
                Picker("Choose gym", selection: $gym){
                    ForEach(Gyms.allCases){option in
                        Text(String(describing: option))
                    }
                }.onChange(of: gym, perform: {(value) in
                    controller.gym = value
                    controller.fetchData()
                })
            }
            Text(controller.capacity.value ?? "Loading..")
                .padding()
        }.onAppear(perform: controller.fetchData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
