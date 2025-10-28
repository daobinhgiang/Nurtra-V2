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
