//
//  nurtra_timer_widgetLiveActivity.swift
//  nurtra_timer_widget
//
//  Created by Giang Michael Dao on 10/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct nurtra_timer_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct nurtra_timer_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: nurtra_timer_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension nurtra_timer_widgetAttributes {
    fileprivate static var preview: nurtra_timer_widgetAttributes {
        nurtra_timer_widgetAttributes(name: "World")
    }
}

extension nurtra_timer_widgetAttributes.ContentState {
    fileprivate static var smiley: nurtra_timer_widgetAttributes.ContentState {
        nurtra_timer_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: nurtra_timer_widgetAttributes.ContentState {
         nurtra_timer_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: nurtra_timer_widgetAttributes.preview) {
   nurtra_timer_widgetLiveActivity()
} contentStates: {
    nurtra_timer_widgetAttributes.ContentState.smiley
    nurtra_timer_widgetAttributes.ContentState.starEyes
}
