//
//  TimerManager.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/28/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class TimerManager: ObservableObject {
    @Published var isTimerRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var timerStartTime: Date?
    
    private var timer: Timer?
    private var firestoreManager: FirestoreManager?
    
    // Dependency injection for FirestoreManager
    func setFirestoreManager(_ manager: FirestoreManager) {
        self.firestoreManager = manager
    }
    
    func startTimer() async {
        let now = Date()
        isTimerRunning = true
        timerStartTime = now
        
        // Save the timer start time to Firestore
        do {
            try await firestoreManager?.saveTimerStart(startTime: now)
        } catch {
            print("Error saving timer start to Firestore: \(error.localizedDescription)")
        }
        
        // Start local timer for display updates
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    // Stop the local timer immediately (synchronous)
    private func stopLocalTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() async {
        // Capture elapsed time before stopping
        let currentElapsedTime = elapsedTime
        
        // Stop local timer immediately
        stopLocalTimer()
        
        // Save the timer stop state to Firestore with elapsed time
        do {
            try await firestoreManager?.stopTimer(elapsedTime: currentElapsedTime)
        } catch {
            print("Error saving timer stop to Firestore: \(error.localizedDescription)")
        }
    }
    
    // Stop timer and log the binge-free period
    func stopTimerAndLogPeriod() async {
        guard let startTime = timerStartTime else {
            await stopTimer()
            return
        }
        
        let endTime = Date()
        let duration = elapsedTime
        
        // Stop the local timer IMMEDIATELY (synchronous) to prevent it from continuing
        stopLocalTimer()
        
        // Now do the async Firestore operations
        do {
            try await firestoreManager?.stopTimer(elapsedTime: duration)
            try await firestoreManager?.logBingeFreePeriod(
                startTime: startTime,
                endTime: endTime,
                duration: duration
            )
        } catch {
            print("Error logging binge-free period: \(error.localizedDescription)")
        }
    }
    
    func resetTimer() async {
        await stopTimer()
        elapsedTime = 0
        timerStartTime = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = timerStartTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    // Fetch timer from Firestore and resume if it was running
    func fetchTimerFromFirestore() async {
        do {
            if let timerData = try await firestoreManager?.fetchTimerStart() {
                timerStartTime = timerData.startTime
                isTimerRunning = timerData.isRunning
                
                // If timer is not running and we have a stored elapsed time, use it
                if !isTimerRunning, let storedElapsedTime = timerData.elapsedTime {
                    elapsedTime = storedElapsedTime
                } else if isTimerRunning {
                    // Only recalculate if timer is running
                    updateElapsedTime()
                    
                    // Resume the timer
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                        self?.updateElapsedTime()
                    }
                }
            }
        } catch {
            print("Error fetching timer from Firestore: \(error.localizedDescription)")
        }
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

