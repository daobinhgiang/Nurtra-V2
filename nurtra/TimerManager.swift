//
//  TimerManager.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/28/25.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var isTimerRunning = false
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    
    func startTimer() {
        isTimerRunning = true
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.01
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        let centiseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
        } else {
            return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
        }
    }
}

