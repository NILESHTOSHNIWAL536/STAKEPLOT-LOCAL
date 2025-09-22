import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            totalSpending: "₹0",
            categories: "Categories: None",
            timestamp: "01 Jan - 01 Jan"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            totalSpending: "₹0",
            categories: "Categories: None",
            timestamp: "01 Jan - 01 Jan"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.stakeplot.pfa")
        let totalSpending = defaults?.string(forKey: "total_spending") ?? "₹0"
        let categories = defaults?.string(forKey: "categories") ?? "Categories: None"
        let timestamp = defaults?.string(forKey: "timestamp") ?? "01 Jan - 01 Jan"
        
        let entry = SimpleEntry(
            date: Date(),
            totalSpending: totalSpending,
            categories: categories,
            timestamp: timestamp
        )

        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalSpending: String
    let categories: String
    let timestamp: String
}

struct StakeplotWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Expenses")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: "007AFF"))
                .padding(.bottom, 2)
            
            Text("Total: \(entry.totalSpending)")
                .font(.system(size: 13))
                .foregroundColor(.black)
                .padding(.bottom, 1)
            
            Text(entry.categories)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "666666"))
                .lineLimit(family == .systemSmall ? 3 : 5)
                .padding(.bottom, 1)
            
            Text(entry.timestamp)
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "999999"))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                )
        )
        .widgetURL(URL(string: "stakeplot://open"))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

struct StakeplotWidget: Widget {
    let kind: String = "StakeplotWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StakeplotWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stakeplot Expenses")
        .description("Shows expense overview.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct StakeplotWidgetBundle: WidgetBundle {
    var body: some Widget {
        StakeplotWidget()
    }
}