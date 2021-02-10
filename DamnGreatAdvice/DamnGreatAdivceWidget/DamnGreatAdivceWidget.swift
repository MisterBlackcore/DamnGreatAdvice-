import WidgetKit
import SwiftUI
import UIKit

struct AdviceEntry: TimelineEntry {
    var date = Date()
    var advice: String
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> AdviceEntry {
        return AdviceEntry(advice: "Damn great advice for you!")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AdviceEntry) -> Void) {
        let adviceEntry = AdviceEntry(advice: "Damn great advice for you!")
        completion(adviceEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AdviceEntry>) -> Void) {
        fetchAdvice { (advice) in
            let date = Date()
            let widgetAdvice = AdviceEntry(date: date, advice: advice)
            let updateTime = Calendar.current.date(byAdding: .minute, value: 15, to: date)
            let timeline = Timeline(entries: [widgetAdvice], policy: .after(updateTime!))
            completion(timeline)
        }
    }
}

struct WidgetAdvice: Codable {
    var text:String?
}

func fetchAdvice(completion: @escaping (String) -> Void) {
    let urlString = "https://fucking-great-advice.ru/api/random"
    guard let url = URL(string: urlString) else {
        return
    }
    let session = URLSession.shared
    let request = URLRequest(url: url)
    session.dataTask(with: request) { (data, response, error) in
        if let data = data {
            if let advice = try? JSONDecoder().decode(WidgetAdvice.self, from: data) {
                if let adviceText = advice.text {
                    completion(adviceText)
                }
            }
        }
    }.resume()
}

struct AdviceView: View {
    let advice:Advice
    var body: some View {
        Text(advice.text ?? "Damn great Advice!")
            .font(.largeTitle)
            .foregroundColor(.white)
    }
}

struct WidgetEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        let advice = Advice(text: entry.advice, html: "")
        switch family {
        case .systemMedium:
            AdviceView(advice: advice)
        default:
            AdviceView(advice: advice)
        }
    }
}

@main
struct AdviceWidget: Widget {
    private let kind = "Advice_Widget"
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            WidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .supportedFamilies([.systemMedium])
    }
}
