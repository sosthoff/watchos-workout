//
//  ElapsedTimeView.swift
//  workout WatchKit Extension
//
//  Created by Osthoff, Sebastian on 10.06.21.
//

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    @State private var timeFormatter = ElapsedTimeFormatter()
    
    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) { newValue in
                timeFormatter.showSubseconds = newValue
            }.foregroundColor(Color.yellow)
    }
}

struct ElapsedTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ElapsedTimeView()
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true
    
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }
        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }
        if showSubseconds {
            let hundedths =
            Int((time.truncatingRemainder(dividingBy: 1))
                * 10)
            let decimalSeperator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.1d",
                          formattedString, decimalSeperator, hundedths)
        }
        return formattedString
    }
}
