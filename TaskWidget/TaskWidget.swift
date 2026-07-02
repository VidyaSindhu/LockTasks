// TARGET: TaskWidgetExtension (Widget Extension)

import WidgetKit
import SwiftUI

struct TaskWidget: Widget {

    let kind = "com.vsd-local.LockTasks.TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskWidgetProvider()) { entry in
            TaskWidgetView(entry: entry)
                .containerBackground(entry.noteColor.opacity(0.25), for: .widget)
                .widgetURL(entry.noteLaunchURL)
        }
        .configurationDisplayName("Lock Tasks")
        .description("View your next task and cycle notes — right from the Lock Screen.")
        .supportedFamilies([WidgetFamily.accessoryRectangular])
    }
}
