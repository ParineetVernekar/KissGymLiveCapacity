//
//  GymCapacityWidget.swift
//  GymCapacityWidget
//
//  Created by Parineet Vernekar on 15/08/2023.
//

import WidgetKit
import SwiftUI
import Intents
import SwiftSoup


struct Provider: IntentTimelineProvider {
    
    func convertToLocation(location:Location) -> String{
        switch location{
        case .milton_Keynes:
            return "Milton Keynes"
        case .unknown:
            return "ERROR"
        case .swindon:
            return "Swindon"
        case .acton:
            return "Acton"
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), capacity: Capacity(value: "52%"), location: convertToLocation(location: Location.milton_Keynes))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, capacity: Capacity(value: "52%"), location: convertToLocation(location: Location.milton_Keynes))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        DataProvider.getImageFromApi(completion: { response in
            var entries: [SimpleEntry] = []
            var policy: TimelineReloadPolicy
            var entry: SimpleEntry
            
            switch response{
            case .Failure:
                entry = SimpleEntry(date: Date(), configuration: configuration, capacity: Capacity(value: "ERROR"), location: convertToLocation(location: Location.milton_Keynes))
                policy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
                break
            case .Success(let capacity):
                entry = SimpleEntry(date: Date(), configuration: configuration, capacity: Capacity(value: capacity), location: "Milton Keynes")
                
                policy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
                break
            }
            
            entries.append(entry)
                       let timeline = Timeline(entries: entries, policy: policy)
                       completion(timeline)
        }, configuration: configuration)
      
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    
    }
}

class DataProvider {
    static func convertToLocation(location:Location) -> String{
        switch location{
        case .milton_Keynes:
            return "Milton Keynes"
        case .unknown:
            return "ERROR"
        case .swindon:
            return "Swindon"
        case .acton:
            return "Acton"
        }
    }
    
     static func getImageFromApi(completion: ((DataResponse) -> Void)?, configuration:ConfigurationIntent) {
          
            let urlString = "https://www.kissgyms.com/headcount.php"
            
            let url = URL(string: urlString)!
            let urlRequest = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
                print(data)
                var capacity = ""
                
                guard let data = data else{
                    print("DATA NOT RIGHT")
                    print(data)
                    return
                }
                
                print("LOCATION")
                print(configuration.GymLocation)
                print(convertToLocation(location: configuration.GymLocation))
                print("h2:contains(\(self.convertToLocation(location: configuration.GymLocation)) + h1.text-center")
                guard let htmlString = String(data: data, encoding: .utf8) else{
                    print("DATA NOT CONVERTING")
                    return
                }
                do {
                    let doc = try SwiftSoup.parse(htmlString)
                    // Find the latest headlines
                    let headlines = try doc.select("h2:contains(\(self.convertToLocation(location: configuration.GymLocation))) + h1.text-center")
                    
                    // Print out the headlines
                    for headline in headlines {
                        print(try headline.text())
                        capacity = try headline.text()
                        let wordToRemove = " Capacity"
                        
                        
                        if let range = capacity.range(of: wordToRemove) {
                            capacity.removeSubrange(range)
                        }
                    }
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
                let response = DataResponse.Success(data: capacity)
                completion?(response)
            }
            task.resume()
        }
}

enum DataResponse{
    case Success(data:String)
    case Failure
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let capacity: Capacity
    let location : String
}

struct GymCapacityWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    func convertToLocation(location:Location) -> String{
        switch location{
        case .milton_Keynes:
            return "Milton Keynes"
        case .unknown:
            return "ERROR"
        case .swindon:
            return "Swindon"
        case .acton:
            return "Acton"
        }
    }
    

    var body: some View {
        switch family{
        case .accessoryCircular:
            Gauge(value: Double(entry.capacity.value?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0, in:0...100) {
                Text("Gym")
            } currentValueLabel: {
                Text(entry.capacity.value ?? "...")
            }
            .gaugeStyle(.accessoryCircular)
        case .systemSmall:
            ZStack {
                Styles.background
                VStack(alignment: .leading){
                    HStack {
                        Image(systemName: "dumbbell")
                        Text("Kiss Gym Live")
                            .font(.caption)
                    }
                        HStack {
                            Text(entry.capacity.value ?? "...")
                                .font(.largeTitle)
                                .foregroundColor(Styles.textColor)
                            Gauge(value: Double(entry.capacity.value?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0, in:0...100) {
                            }.gaugeStyle(.accessoryCircularCapacity)
                                .scaleEffect(0.7).foregroundColor(Styles.textColor).tint(Styles.textColor)
                        }
                        Text(convertToLocation(location:entry.configuration.GymLocation))
                            .font(.callout)
                        Text(entry.date, style: .time)
                            .font(.caption2)
                        
                }.foregroundColor(Styles.textColor)
            }
        case .accessoryRectangular:
            HStack {
                Gauge(value: Double(entry.capacity.value?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0, in:0...100) {
                    
                } currentValueLabel: {
                    Text(entry.capacity.value ?? "...")
                }
                .gaugeStyle(.accessoryCircular)
                Spacer()
                VStack {
                    Text(convertToLocation(location:entry.configuration.GymLocation))
                        .font(.footnote)
                    
                    Text("Kiss Gyms")
                        .font(.caption2)
                }
            }
        default:
            ZStack {
                VStack(alignment: .leading){
                    HStack {
                        Text(entry.capacity.value ?? "...")
                            .font(.largeTitle)
                        Gauge(value: Double(entry.capacity.value?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0, in:0...100) {
                        }.gaugeStyle(.accessoryCircularCapacity)
                    }
                    Text(convertToLocation(location:entry.configuration.GymLocation))
                        .font(.callout)
                    Text(entry.date, style: .time)
                        .font(.caption2)
                    
                }
                .padding()
            }
        }
        
        
    }
}

struct GymCapacityWidget: Widget {
    let kind: String = "GymCapacityWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            GymCapacityWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kiss Gyms Live capacity")
        .description("See live capacity for your local Kiss Gym, updated every 15 minutes")
        .supportedFamilies([
           .systemSmall,
           .accessoryCircular,
           .accessoryRectangular
       ])
    }
}

struct GymCapacityWidget_Previews: PreviewProvider {
    static var previews: some View {
        GymCapacityWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), capacity: Capacity(value:"52%"), location: "Milton Keynes"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
