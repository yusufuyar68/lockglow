import SwiftUI
import WidgetKit

@main
struct LockglowWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WordWidget()
        ProgressWidget()
        // iOS 18 controls (Controls.swift); iOS 17 keeps the widget buttons only.
        if #available(iOS 18.0, *) {
            SpeakWordControl()
            NextWordControl()
            OpenReviewControl()
        }
    }
}
