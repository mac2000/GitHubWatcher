import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, review: 20, dependabot: 5, my: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, review: 20, dependabot: 5, my: 1)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [SimpleEntry] = []
            
            let review = try await GitHub.shared.humanPullRequestsWaitingMyReview()
            let bot = try await GitHub.shared.botPullRequestsWaitingMyReview()
            let my = try await GitHub.shared.myPullRequestsReadyToBeMerged()
            
            let currentDate = Date()
            for hourOffset in 0 ..< 3 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset * 5, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, review: review.totalCount, dependabot: bot.totalCount, my: my.totalCount)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let review: Int
    let dependabot: Int
    let my: Int
}

struct PullRequestsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        VStack(alignment:.leading) {
            HStack{
                Text("review").foregroundStyle(.secondary)
                Spacer()
            }
            HStack{
                Link(destination:URL(string:"ua.org.mac-blog.GitHubWatcher://review")!) {
                    Text("\(entry.review)").font(.largeTitle)
                }
            }
            
            Spacer()
            Grid(alignment:.leading){
                if (entry.my > 0) {
                    GridRow(alignment:.bottom){
                        Link(destination:URL(string:"ua.org.mac-blog.GitHubWatcher://my")!) {
                            Text("\(entry.my)").font(.callout)
                        }
                        Text("ready").font(.caption).foregroundStyle(.secondary)
                    }
                }
                if (entry.dependabot > 0) {
                    GridRow(alignment:.bottom){
                        Link(destination:URL(string:"ua.org.mac-blog.GitHubWatcher://dependabot")!) {
                            Text("\(entry.dependabot)").font(.callout)
                        }
                        Text("dependabot").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        //.widgetURL(URL(string:"ua.org.mac-blog.GitHubWatcher://widget")!)
    }
}

struct PullRequestsWidget: Widget {
    let kind: String = "PullRequestsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                PullRequestsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PullRequestsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("GitHub")
        .description("Pull Requests Watcher")
    }
}

#Preview(as: .systemSmall) {
    PullRequestsWidget()
} timeline: {
    SimpleEntry(date: .now, review: 20, dependabot: 5, my: 1)
    SimpleEntry(date: .now, review: 5, dependabot: 1, my: 0)
    SimpleEntry(date: .now, review: 3, dependabot: 0, my: 0)
}
