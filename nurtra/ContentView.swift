//
//  ContentView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/27/25.
//

import FirebaseAuth
enum Screen {
    case home
    case profile
    case settings
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if authManager.needsOnboarding {
                    OnboardingSurveyView()
                } else {
                    MainAppView()
                }
            } else {
                LoginView()
            }
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var timerManager: TimerManager
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var navigationPath = NavigationPath()
    @State private var recentPeriods: [BingeFreePeriod] = []
    @State private var isLoadingNotification = false
    @State private var notificationMessage = ""
    @State private var showNotificationAlert = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
            VStack {                
                // Display overcome count
                VStack(spacing: 8) {
                    Text("Urge Overcame count")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(authManager.overcomeCount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Timer Display - Centered in the middle of the screen
                VStack(spacing: 20) {
                    Text(timerManager.timeString(from: timerManager.elapsedTime))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(timerManager.isTimerRunning ? .green : .primary)
                        .monospacedDigit()
                    
                    // Only show button when timer is not running
                    if !timerManager.isTimerRunning {
                        Button(action: {
                            Task {
                                await timerManager.startTimer()
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Binge-free Timer")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Recent Binge-Free Periods Section
                if !recentPeriods.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Binge-Free Periods")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(recentPeriods) { period in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(timerManager.timeString(from: period.duration))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(formatDate(period.endTime))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                Spacer()
                
                NavigationLink(destination: CravingView()) {
                    Text("Craving!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: BlockAppsView()) {
                    Text("Block Apps")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Test Motivational Notification Button
                Button(action: {
                    Task {
                        await sendTestNotification()
                    }
                }) {
                    HStack {
                        if isLoadingNotification {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                        }
                        Text(isLoadingNotification ? "Sending..." : "Test Motivational Push")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoadingNotification ? Color.gray : Color.orange)
                    .cornerRadius(10)
                }
                .disabled(isLoadingNotification)
                .padding(.horizontal)
                .alert("Notification Sent! 🎉", isPresented: $showNotificationAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(notificationMessage)
                }
                
                Button(action: {
                    do {
                        try authManager.signOut()
                    } catch {
                        print("Sign out error: \(error)")
                    }
                }) {
                    Text("Sign Out")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding()
            }
            .refreshable {
                // Allow pull-to-refresh
                await fetchRecentPeriods()
                await authManager.fetchOvercomeCount()
            }
            .task {
                // Backup fetch in case the initial fetch in AuthenticationManager failed
                await authManager.fetchOvercomeCount()
                // Fetch timer from Firestore on view load
                await timerManager.fetchTimerFromFirestore()
                // Fetch recent binge-free periods
                await fetchRecentPeriods()
            }
            .onAppear {
                // Refresh periods when view appears (e.g., after coming back from survey)
                Task {
                    await fetchRecentPeriods()
                }
            }
        }
    }
    
    private func fetchRecentPeriods() async {
        do {
            recentPeriods = try await firestoreManager.fetchRecentBingeFreePeriods(limit: 3)
        } catch {
            print("Error fetching recent periods: \(error.localizedDescription)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func sendTestNotification() async {
        isLoadingNotification = true
        
        do {
            let message = try await firestoreManager.sendMotivationalNotification()
            notificationMessage = "✅ Push notification sent successfully!\n\nMessage: \"\(message)\"\n\nCheck your notification tray to see it."
            showNotificationAlert = true
        } catch {
            notificationMessage = "❌ Failed to send notification: \(error.localizedDescription)\n\nMake sure:\n1. Cloud function is deployed\n2. OpenAI API key is configured\n3. Notifications are enabled"
            showNotificationAlert = true
        }
        
        isLoadingNotification = false
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(TimerManager())
}
