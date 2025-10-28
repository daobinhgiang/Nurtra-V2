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
                MainAppView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, \(authManager.user?.email ?? "User")!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
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
            .navigationTitle("Nurtra V2")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
