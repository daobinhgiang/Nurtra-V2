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
        ZStack {
            // Full-screen camera preview as base layer
            CameraView()
                .ignoresSafeArea(.all)
            
            // Overlay UI elements
            VStack {
                // Timer display at the top center
                VStack(spacing: 8) {
                    Text("Binge-free Time")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(timerManager.timeString(from: timerManager.elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(timerManager.isTimerRunning ? .green : .white)
                        .monospacedDigit()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.black.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.top, 20) // Reduced padding to move higher
                
                Spacer()
                
                // Bottom buttons in one row with semi-transparent background
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 50) // Safe area padding
            }
            
            // Invisible navigation trigger
            NavigationLink(isActive: $showSurvey) {
                BingeSurveyView()
            } label: {
                EmptyView()
            }
            .hidden()
            .frame(width: 0, height: 0)
        }
    }
}

#Preview {
    NavigationStack {
        CravingView()
            .environmentObject(TimerManager())
    }
}
