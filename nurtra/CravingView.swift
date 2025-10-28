//
//  CravingView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/27/25.
//

import SwiftUI
import AVFoundation

struct CravingView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var showSurvey = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Timer display at the top
                VStack(spacing: 8) {
                    Text("Binge-free Time")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(timerManager.timeString(from: timerManager.elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(timerManager.isTimerRunning ? .green : .primary)
                        .monospacedDigit()
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, geometry.size.width * 0.03)
                
                // Camera preview, expanding vertically as much as possible
                CameraView()
                    .frame(width: geometry.size.width * 0.94) // near full width, keep some side padding
                    .frame(maxHeight: .infinity, alignment: .top) // let it expand vertically
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 10)

                // Bottom buttons in one row
                HStack(spacing: 12) {
                    // Left: I just binged (red)
                    Button(action: {
                        // Stop the timer if it's running
                        if timerManager.isTimerRunning {
                            timerManager.stopTimer()
                        }
                        showSurvey = true
                    }) {
                        Text("I just binged")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Right: I overcame it (blue)
                    Button(action: {
                        // TODO: Handle "I overcame it"
                    }) {
                        Text("I overcame it")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.03) // aligns with camera side padding (approx)
                .padding(.bottom) // safe area-friendly bottom padding

                // Invisible navigation trigger
                NavigationLink(isActive: $showSurvey) {
                    BingeSurveyView()
                } label: {
                    EmptyView()
                }
                .hidden()
                .frame(width: 0, height: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top)
        }
    }
}

#Preview {
    NavigationStack {
        CravingView()
            .environmentObject(TimerManager())
    }
}
