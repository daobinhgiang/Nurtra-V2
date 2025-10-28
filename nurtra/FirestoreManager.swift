//
//  FirestoreManager.swift
//  Nurtra V2
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Onboarding Survey Methods
    
    func saveOnboardingSurvey(responses: OnboardingSurveyResponses) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirestoreError.noAuthenticatedUser
        }
        
        let userData: [String: Any] = [
            "onboardingCompleted": true,
            "onboardingCompletedAt": Timestamp(date: Date()),
            "onboardingResponses": [
                "struggleDuration": responses.struggleDuration,
                "bingeFrequency": responses.bingeFrequency,
                "importanceReason": responses.importanceReason,
                "lifeWithoutBinge": responses.lifeWithoutBinge,
                "bingeThoughts": responses.bingeThoughts,
                "bingeTriggers": responses.bingeTriggers,
                "whatMattersMost": responses.whatMattersMost,
                "recoveryValues": responses.recoveryValues
            ]
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    func checkOnboardingCompletion() async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirestoreError.noAuthenticatedUser
        }
        
        let document = try await db.collection("users").document(userId).getDocument()
        
        if document.exists {
            let data = document.data()
            return data?["onboardingCompleted"] as? Bool ?? false
        } else {
            return false
        }
    }
    
    func markOnboardingComplete() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirestoreError.noAuthenticatedUser
        }
        
        let userData: [String: Any] = [
            "onboardingCompleted": true,
            "onboardingCompletedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    // MARK: - Motivational Quotes Methods
    
    func saveMotivationalQuotes(quotes: [String]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirestoreError.noAuthenticatedUser
        }
        
        // Create a dictionary with numbered fields (quote1, quote2, etc.)
        var quotesData: [String: Any] = [:]
        for (index, quote) in quotes.enumerated() {
            quotesData["quote\(index + 1)"] = quote
        }
        
        let userData: [String: Any] = [
            "motivationalQuotes": quotesData,
            "motivationalQuotesGeneratedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
        
        print("✅ Successfully saved \(quotes.count) motivational quotes to Firestore")
    }
    
    func fetchMotivationalQuotes() async throws -> [MotivationalQuote] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirestoreError.noAuthenticatedUser
        }
        
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard document.exists,
              let data = document.data(),
              let quotesData = data["motivationalQuotes"] as? [String: String],
              let generatedAt = data["motivationalQuotesGeneratedAt"] as? Timestamp else {
            return []
        }
        
        // Extract quotes in order (quote1, quote2, etc.)
        var quotes: [MotivationalQuote] = []
        for i in 1...10 {
            if let text = quotesData["quote\(i)"] {
                quotes.append(MotivationalQuote(
                    id: "quote\(i)",
                    text: text,
                    order: i,
                    createdAt: generatedAt.dateValue()
                ))
            }
        }
        
        return quotes
    }
}

// MARK: - Data Models

struct OnboardingSurveyResponses {
    let struggleDuration: [String]
    let bingeFrequency: [String]
    let importanceReason: [String]
    let lifeWithoutBinge: [String]
    let bingeThoughts: [String]
    let bingeTriggers: [String]
    let whatMattersMost: [String]
    let recoveryValues: [String]
}

struct MotivationalQuote: Identifiable {
    let id: String
    let text: String
    let order: Int
    let createdAt: Date
}

// MARK: - Error Handling

enum FirestoreError: LocalizedError {
    case noAuthenticatedUser
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found"
        case .saveFailed:
            return "Failed to save data to Firestore"
        case .fetchFailed:
            return "Failed to fetch data from Firestore"
        }
    }
}
