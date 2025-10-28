//
//  BlockAppsView.swift
//  nurtra
//
//  Created by Nurtra Team on 10/28/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import ManagedSettingsUI

struct BlockAppsView: View {
    @State private var isAuthorized = false
    @State private var authorizationStatus: AuthorizationStatus = .notDetermined
    @State private var isRequestingAuthorization = false
    @State private var selectedApps = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var errorMessage: String?
    @State private var isLocked = false
    
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isRequestingAuthorization {
                ProgressView("Requesting Authorization...")
                    .padding()
            } else {
                switch authorizationStatus {
                case .notDetermined, .denied:
                    authorizationView
                case .authorized:
                    authorizedView
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Block Apps")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            checkAuthorizationStatus()
        }
        .sheet(isPresented: $showAppPicker) {
            NavigationView {
                FamilyActivityPicker(selection: $selectedApps)
                    .navigationTitle("Select Apps to Block")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showAppPicker = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showAppPicker = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
            }
        }
    }
    
    private var authorizationView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Screen Time Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("nurtra needs access to Screen Time to help you block distracting apps during your recovery.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if authorizationStatus == .denied {
                Text("Access was denied. Please enable Screen Time in Settings.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                requestAuthorization()
            }) {
                Text(authorizationStatus == .denied ? "Open Settings" : "Grant Access")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    
    private var authorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Access Granted")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select apps you want to block to help you stay focused on your recovery.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if !selectedApps.applicationTokens.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Selected Apps")
                            .font(.headline)
                        Spacer()
                        Text(isLocked ? "🔒 Locked" : "🔓 Unlocked")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isLocked ? .red : .green)
                    }
                    Text("\(selectedApps.applicationTokens.count) app(s) selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isLocked ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: {
                showAppPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(selectedApps.applicationTokens.isEmpty ? "Select Apps to Block" : "Manage Blocked Apps")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !selectedApps.applicationTokens.isEmpty {
                Button(action: {
                    if isLocked {
                        unlockApps()
                    } else {
                        lockApps()
                    }
                }) {
                    HStack {
                        Image(systemName: isLocked ? "lock.open.fill" : "lock.fill")
                        Text(isLocked ? "Unlock Apps" : "Lock Apps")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLocked ? Color.green : Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private func checkAuthorizationStatus() {
        switch center.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .approved:
            authorizationStatus = .authorized
            isAuthorized = true
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    private func requestAuthorization() {
        if authorizationStatus == .denied {
            // Open Settings app
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            return
        }
        
        isRequestingAuthorization = true
        errorMessage = nil
        
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                await MainActor.run {
                    authorizationStatus = .authorized
                    isAuthorized = true
                    isRequestingAuthorization = false
                }
            } catch {
                await MainActor.run {
                    authorizationStatus = .denied
                    errorMessage = "Authorization failed: \(error.localizedDescription)"
                    isRequestingAuthorization = false
                }
            }
        }
    }
    
    private func lockApps() {
        guard isAuthorized else { return }
        
        // Apply app restrictions
        store.shield.applications = selectedApps.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
        store.shield.webDomains = selectedApps.webDomainTokens
        
        isLocked = true
    }
    
    private func unlockApps() {
        // Clear restrictions but keep the selection
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        isLocked = false
    }
}

#Preview {
    NavigationStack {
        BlockAppsView()
    }
}

