//
//  LoginView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/28/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo/Header
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Welcome to Nurtra")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Social Sign-In Buttons
                    VStack(spacing: 12) {
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                                let nonce = authManager.startSignInWithApple()
                                request.nonce = nonce
                            },
                            onCompletion: { result in
                                Task {
                                    isLoading = true
                                    switch result {
                                    case .success(let authorization):
                                        do {
                                            try await authManager.handleSignInWithApple(authorization)
                                        } catch {
                                            print("Apple Sign-In error: \(error)")
                                        }
                                    case .failure(let error):
                                        print("Apple Sign-In failed: \(error)")
                                    }
                                    isLoading = false
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        
                        // Google Sign In
                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    try await authManager.signInWithGoogle()
                                } catch {
                                    print("Google Sign-In error: \(error)")
                                }
                                isLoading = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title3)
                                Text("Continue with Google")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal)
                    
                    // Email/Password Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(.plain)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(.plain)
                                .textContentType(.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Sign In Button
                    Button(action: {
                        Task {
                            isLoading = true
                            do {
                                try await authManager.signIn(email: email, password: password)
                            } catch {
                                print("Sign in error: \(error)")
                            }
                            isLoading = false
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .opacity((email.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1.0)
                    .padding(.horizontal)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Enter your email to receive a password reset link")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.plain)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                if showSuccess {
                    Text("Password reset email sent! Check your inbox.")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            try await authManager.resetPassword(email: email)
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        } catch {
                            print("Password reset error: \(error)")
                        }
                        isLoading = false
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    } else {
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(email.isEmpty || isLoading)
                .opacity((email.isEmpty || isLoading) ? 0.6 : 1.0)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}


