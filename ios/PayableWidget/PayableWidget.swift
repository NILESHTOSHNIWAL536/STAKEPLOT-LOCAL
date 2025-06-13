// import WidgetKit
// import SwiftUI

// struct PayableProvider: TimelineProvider {
//     func placeholder(in context: Context) -> PayableEntry {
//         PayableEntry(
//             date: Date(),
//             toReceive: "None: ₹0",
//             toPay: "None: ₹0"
//         )
//     }

//     func getSnapshot(in context: Context, completion: @escaping (PayableEntry) -> ()) {
//         let entry = PayableEntry(
//             date: Date(),
//             toReceive: "None: ₹0",
//             toPay: "None: ₹0"
//         )
//         completion(entry)
//     }

//     func getTimeline(in context: Context, completion: @escaping (Timeline<PayableEntry>) -> ()) {
//         let defaults = UserDefaults(suiteName: "group.com.stakeplot.pfa")
//         let toReceive = defaults?.string(forKey: "to_receive") ?? "None: ₹0"
//         let toPay = defaults?.string(forKey: "to_pay") ?? "None: ₹0"

//         let entry = PayableEntry(
//             date: Date(),
//             toReceive: toReceive,
//             toPay: toPay
//         )

//         let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
//         let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
//         completion(timeline)
//     }
// }

// struct PayableEntry: TimelineEntry {
//     let date: Date
//     let toReceive: String
//     let toPay: String
// }

// struct PayableWidgetEntryView: View {
//     var entry: PayableProvider.Entry
//     @Environment(\.widgetFamily) var family

//     var body: some View {
//         HStack(spacing: 0) {
//             // To Receive
//             VStack(alignment: .leading, spacing: 4) {
//                 Text("To Receive")
//                     .font(.system(size: 15, weight: .bold))
//                     .foregroundColor(Color(hex: "007AFF"))
//                 Text(entry.toReceive)
//                     .font(.system(size: 13))
//                     .foregroundColor(.black)
//             }
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .padding(.horizontal, 8)

//             // Divider
//             Rectangle()
//                 .fill(Color(hex: "E0E0E0"))
//                 .frame(width: 1)

//             // To Pay
//             VStack(alignment: .leading, spacing: 4) {
//                 Text("To Pay")
//                     .font(.system(size: 15, weight: .bold))
//                     .foregroundColor(Color(hex: "007AFF"))
//                 Text(entry.toPay)
//                     .font(.system(size: 13))
//                     .foregroundColor(.black)
//             }
//             .frame(maxWidth: .infinity, alignment: .leading)
//             .padding(.horizontal, 8)
//         }
//         .padding(8)
//         .background(
//             RoundedRectangle(cornerRadius: 12)
//                 .fill(Color.white)
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 12)
//                         .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
//                 )
//         )
//         .containerBackground(for: .widget) {
//             Color.white
//         }
//     }
// }

// extension Color {
//     init(hex: String) {
//         let scanner = Scanner(string: hex)
//         var rgbValue: UInt64 = 0
//         scanner.scanHexInt64(&rgbValue)
//         self.init(
//             red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
//             green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
//             blue: Double(rgbValue & 0x0000FF) / 255.0
//         )
//     }
// }

// struct PayableWidget: Widget {
//     let kind: String = "PayableWidget"

//     var body: some WidgetConfiguration {
//         StaticConfiguration(kind: kind, provider: PayableProvider()) { entry in
//             PayableWidgetEntryView(entry: entry)
//         }
//         .configurationDisplayName("Payable Overview")
//         .description("Shows amounts to receive and pay.")
//         .supportedFamilies([.systemSmall, .systemMedium])
//     }
// }

// @main
// struct PayableWidgetBundle: WidgetBundle {
//     var body: some Widget {
//         PayableWidget()
//     }
// }

import WidgetKit
import SwiftUI

struct PayableProvider: TimelineProvider {
    func placeholder(in context: Context) -> PayableEntry {
        PayableEntry(
            date: Date(),
            toReceive: "None: ₹0",
            toPay: "None: ₹0"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PayableEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.stakeplot.pfa")
        let toReceive = defaults?.string(forKey: "to_receive") ?? "None: ₹0"
        let toPay = defaults?.string(forKey: "to_pay") ?? "None: ₹0"

        let entry = PayableEntry(
            date: Date(),
            toReceive: toReceive.isEmpty ? "Error" : toReceive,
            toPay: toPay.isEmpty ? "Error" : toPay
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PayableEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.stakeplot.pfa")
        let toReceive = defaults?.string(forKey: "to_receive") ?? "None: ₹0"
        let toPay = defaults?.string(forKey: "to_pay") ?? "None: ₹0"

        let entry = PayableEntry(
            date: Date(),
            toReceive: toReceive.isEmpty ? "Error" : toReceive,
            toPay: toPay.isEmpty ? "Error" : toPay
        )

        let refreshDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct PayableEntry: TimelineEntry {
    let date: Date
    let toReceive: String
    let toPay: String
}

struct PayableWidgetEntryView: View {
    var entry: PayableProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("To Receive")
                    .font(.system(size: family == .systemSmall ? 13 : 15, weight: .bold))
                    .foregroundColor(Color(hex: "004856"))
                Text(entry.toReceive)
                    .font(.system(size: family == .systemSmall ? 11 : 13))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, family == .systemSmall ? 6 : 8)

            Rectangle()
                .fill(Color(hex: "BDBDBD"))
                .frame(width: 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("To Pay")
                    .font(.system(size: family == .systemSmall ? 13 : 15, weight: .bold))
                    .foregroundColor(Color(hex: "004856"))
                Text(entry.toPay)
                    .font(.system(size: family == .systemSmall ? 11 : 13))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, family == .systemSmall ? 6 : 8)
        }
        .padding(family == .systemSmall ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                )
        )
        .containerBackground(for: .widget) {
            Color.white
        }
        .widgetURL(URL(string: "stakeplot://finance")) // Add tap handler
    }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double(rgb >> 16) / 255.0
        let g = Double(rgb >> 8 & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct PayableWidget: Widget {
    let kind: String = "PayableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PayableProvider()) { entry in
            PayableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Payable Overview")
        .description("Shows amounts to receive and pay.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct PayableWidgetBundle: WidgetBundle {
    var body: some Widget {
        PayableWidget()
    }
}