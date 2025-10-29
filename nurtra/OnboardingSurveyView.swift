//
//  OnboardingSurveyView.swift
//  Nurtra V2
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct OnboardingSurveyView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var step: Int = 0
    @State private var isLoading = false
    
    // Focus for text fields
    private enum FocusedField: Hashable {
        case struggleDurationOther
        case bingeFrequencyOther
        case importanceReasonOther
        case lifeWithoutBingeOther
        case bingeThoughtsOther
        case bingeTriggersOther
        case whatMattersMostOther
        case recoveryValuesOther
    }
    @FocusState private var focusedField: FocusedField?
    
    // Step 1: How long have you struggled with binge eating?
    private let struggleDurationOptions = ["Less than 6 months", "6 months to 1 year", "1-2 years", "2-5 years", "5-10 years", "More than 10 years"]
    @State private var selectedStruggleDuration: Set<String> = []
    @State private var struggleDurationOtherText: String = ""
    
    // Step 2: How often do binges typically happen?
    private let bingeFrequencyOptions = ["Daily", "Several times a week", "Weekly", "Bi-weekly", "Monthly", "Occasionally"]
    @State private var selectedBingeFrequency: Set<String> = []
    @State private var bingeFrequencyOtherText: String = ""
    
    // Step 3: Why is it important for you to overcome binge eating?
    private let importanceReasonOptions = ["Physical health", "Mental well-being", "Self-confidence", "Relationships", "Career goals", "Financial stability"]
    @State private var selectedImportanceReason: Set<String> = []
    @State private var importanceReasonOtherText: String = ""
    
    // Step 4: What would your life look like without binge eating?
    private let lifeWithoutBingeOptions = ["More energy", "Better self-esteem", "Healthier relationships", "Career advancement", "Financial freedom", "Inner peace"]
    @State private var selectedLifeWithoutBinge: Set<String> = []
    @State private var lifeWithoutBingeOtherText: String = ""
    
    // Step 5: What thoughts usually come up before or during a binge?
    private let bingeThoughtsOptions = ["I deserve this", "I'll start fresh tomorrow", "I can't control myself", "This is the last time", "I'm already failing", "Food will make me feel better"]
    @State private var selectedBingeThoughts: Set<String> = []
    @State private var bingeThoughtsOtherText: String = ""
    
    // Step 6: Are there common situations or feelings that trigger it?
    private let bingeTriggersOptions = ["Stress", "Boredom", "Loneliness", "Anger", "Sadness", "Celebration"]
    @State private var selectedBingeTriggers: Set<String> = []
    @State private var bingeTriggersOtherText: String = ""
    
    // Step 7: What matters most to you in life?
    private let whatMattersMostOptions = ["Family", "Health", "Career", "Personal growth", "Relationships", "Helping others"]
    @State private var selectedWhatMattersMost: Set<String> = []
    @State private var whatMattersMostOtherText: String = ""
    
    // Step 8: What personal values would you like your recovery to align with?
    private let recoveryValuesOptions = ["Self-compassion", "Authenticity", "Resilience", "Growth", "Balance", "Integrity"]
    @State private var selectedRecoveryValues: Set<String> = []
    @State private var recoveryValuesOtherText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(titleForStep(step))
                    .font(.title2)
                    .fontWeight(.semibold)
                ProgressView(value: Double(step + 1), total: 8)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture { dismissKeyboard() }
            
            // Content
            TabView(selection: $step) {
                surveySlide(
                    prompt: "How long have you struggled with binge eating?",
                    options: struggleDurationOptions,
                    selections: $selectedStruggleDuration,
                    otherText: $struggleDurationOtherText,
                    focus: .struggleDurationOther
                )
                .tag(0)
                
                surveySlide(
                    prompt: "How often do binges typically happen?",
                    options: bingeFrequencyOptions,
                    selections: $selectedBingeFrequency,
                    otherText: $bingeFrequencyOtherText,
                    focus: .bingeFrequencyOther
                )
                .tag(1)
                
                surveySlide(
                    prompt: "Why is it important for you to overcome binge eating?",
                    options: importanceReasonOptions,
                    selections: $selectedImportanceReason,
                    otherText: $importanceReasonOtherText,
                    focus: .importanceReasonOther
                )
                .tag(2)
                
                surveySlide(
                    prompt: "What would your life look like without binge eating?",
                    options: lifeWithoutBingeOptions,
                    selections: $selectedLifeWithoutBinge,
                    otherText: $lifeWithoutBingeOtherText,
                    focus: .lifeWithoutBingeOther
                )
                .tag(3)
                
                surveySlide(
                    prompt: "What thoughts usually come up before or during a binge?",
                    options: bingeThoughtsOptions,
                    selections: $selectedBingeThoughts,
                    otherText: $bingeThoughtsOtherText,
                    focus: .bingeThoughtsOther
                )
                .tag(4)
                
                surveySlide(
                    prompt: "Are there common situations or feelings that trigger it?",
                    options: bingeTriggersOptions,
                    selections: $selectedBingeTriggers,
                    otherText: $bingeTriggersOtherText,
                    focus: .bingeTriggersOther
                )
                .tag(5)
                
                surveySlide(
                    prompt: "What matters most to you in life?",
                    options: whatMattersMostOptions,
                    selections: $selectedWhatMattersMost,
                    otherText: $whatMattersMostOtherText,
                    focus: .whatMattersMostOther
                )
                .tag(6)
                
                surveySlide(
                    prompt: "What personal values would you like your recovery to align with?",
                    options: recoveryValuesOptions,
                    selections: $selectedRecoveryValues,
                    otherText: $recoveryValuesOtherText,
                    focus: .recoveryValuesOther
                )
                .tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack {
                if step > 0 {
                    Button("Back") {
                        dismissKeyboard()
                        withAnimation { step -= 1 }
                    }
                    .buttonStyle(SecondaryCapsuleStyle())
                }
                
                Spacer()
                
                if step < 7 {
                    Button("Next") {
                        dismissKeyboard()
                        withAnimation { step += 1 }
                    }
                    .buttonStyle(PrimaryCapsuleStyle())
                } else {
                    Button(action: {
                        Task {
                            await submitSurvey()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Finish")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .buttonStyle(PrimaryCapsuleStyle())
                    .disabled(isLoading)
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture { dismissKeyboard() }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Welcome to Nurtra")
        .contentShape(Rectangle())
        .onTapGesture { dismissKeyboard() }
    }
    
    private func titleForStep(_ step: Int) -> String {
        switch step {
        case 0: return "Your Journey"
        case 1: return "Understanding Patterns"
        case 2: return "Your Motivation"
        case 3: return "Your Vision"
        case 4: return "Your Thoughts"
        case 5: return "Your Triggers"
        case 6: return "Your Priorities"
        case 7: return "Your Values"
        default: return "Welcome"
        }
    }
    
    @ViewBuilder
    private func surveySlide(
        prompt: String,
        options: [String],
        selections: Binding<Set<String>>,
        otherText: Binding<String>,
        focus: FocusedField
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(prompt)
                    .font(.headline)
                
                // Vertical full-width option rows
                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        let isSelected = selections.wrappedValue.contains(option)
                        Button {
                            if isSelected {
                                selections.wrappedValue.remove(option)
                            } else {
                                selections.wrappedValue.insert(option)
                            }
                            dismissKeyboard()
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.body)
                                    .foregroundColor(isSelected ? .white : .primary)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isSelected ? Color.blue : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Other free text as the last full-width row
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Other")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Box-styled container for the text field
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.systemGray6))
                            TextField("Type here…", text: otherText, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .focused($focusedField, equals: focus)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            focusedField = focus
                        }
                    }
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture { dismissKeyboard() }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func submitSurvey() async {
        dismissKeyboard()
        isLoading = true
        
        do {
            // Collect all responses
            let responses = OnboardingSurveyResponses(
                struggleDuration: Array(selectedStruggleDuration) + (struggleDurationOtherText.isEmpty ? [] : [struggleDurationOtherText]),
                bingeFrequency: Array(selectedBingeFrequency) + (bingeFrequencyOtherText.isEmpty ? [] : [bingeFrequencyOtherText]),
                importanceReason: Array(selectedImportanceReason) + (importanceReasonOtherText.isEmpty ? [] : [importanceReasonOtherText]),
                lifeWithoutBinge: Array(selectedLifeWithoutBinge) + (lifeWithoutBingeOtherText.isEmpty ? [] : [lifeWithoutBingeOtherText]),
                bingeThoughts: Array(selectedBingeThoughts) + (bingeThoughtsOtherText.isEmpty ? [] : [bingeThoughtsOtherText]),
                bingeTriggers: Array(selectedBingeTriggers) + (bingeTriggersOtherText.isEmpty ? [] : [bingeTriggersOtherText]),
                whatMattersMost: Array(selectedWhatMattersMost) + (whatMattersMostOtherText.isEmpty ? [] : [whatMattersMostOtherText]),
                recoveryValues: Array(selectedRecoveryValues) + (recoveryValuesOtherText.isEmpty ? [] : [recoveryValuesOtherText])
            )
            
            // Save to Firestore
            try await firestoreManager.saveOnboardingSurvey(responses: responses)
            
            // Update auth manager to mark onboarding as complete
            authManager.markOnboardingComplete()
            
            // Generate motivational quotes in background (doesn't block user)
            QuoteGenerationService.generateQuotesInBackground(from: responses, firestoreManager: firestoreManager)
            
        } catch {
            print("Error saving onboarding survey: \(error)")
            // TODO: Show error message to user
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        OnboardingSurveyView()
            .environmentObject(AuthenticationManager())
    }
}
