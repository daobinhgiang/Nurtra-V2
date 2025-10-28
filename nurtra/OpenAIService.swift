//
//  OpenAIService.swift
//  Nurtra V2
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation

@MainActor
class OpenAIService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // Read API key from Secrets.swift
        let key = Secrets.openAIAPIKey
        
        if !key.isEmpty && !key.hasPrefix("sk-proj-REPLACE") && !key.contains("your-api-key") {
            self.apiKey = key
        } else {
            self.apiKey = ""
            print("⚠️ Warning: OpenAI API key not configured. Please set your key in Secrets.swift")
        }
    }
    
    // MARK: - Generate Motivational Quotes
    
    func generateMotivationalQuotes(from responses: OnboardingSurveyResponses) async throws -> [String] {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        let prompt = buildPrompt(from: responses)
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a compassionate therapist specializing in eating disorder recovery. Generate personalized, empowering motivational quotes."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.9,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let quotes = try parseQuotes(from: data)
        return quotes
    }
    
    // MARK: - Helper Methods
    
    private func buildPrompt(from responses: OnboardingSurveyResponses) -> String {
        let struggleDuration = responses.struggleDuration.joined(separator: ", ")
        let bingeFrequency = responses.bingeFrequency.joined(separator: ", ")
        let importanceReason = responses.importanceReason.joined(separator: ", ")
        let lifeWithoutBinge = responses.lifeWithoutBinge.joined(separator: ", ")
        let bingeThoughts = responses.bingeThoughts.joined(separator: ", ")
        let bingeTriggers = responses.bingeTriggers.joined(separator: ", ")
        let whatMattersMost = responses.whatMattersMost.joined(separator: ", ")
        let recoveryValues = responses.recoveryValues.joined(separator: ", ")
        
        return """
        Based on the following information about a person's binge eating recovery journey, generate exactly 10 personalized, empowering motivational quotes. Make each quote unique, authentic, and deeply connected to their specific situation and values.
        
        Their Journey:
        - Duration of struggle: \(struggleDuration)
        - Frequency of binges: \(bingeFrequency)
        - Why recovery matters to them: \(importanceReason)
        - Their vision without binge eating: \(lifeWithoutBinge)
        - Common thoughts during binges: \(bingeThoughts)
        - Triggers: \(bingeTriggers)
        - What matters most to them: \(whatMattersMost)
        - Recovery values: \(recoveryValues)
        
        Requirements:
        1. Generate exactly 10 quotes
        2. Each quote should be 1-2 sentences
        3. Make them personal to their specific struggles and values
        4. Focus on hope, strength, growth, and their unique vision
        5. Avoid clichés; make each quote feel authentic and tailored
        6. Use compassionate, non-judgmental language
        7. Format as a numbered list (1. Quote 1\n2. Quote 2\n...)
        
        Generate the 10 quotes now:
        """
    }
    
    private func parseQuotes(from data: Data) throws -> [String] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.parseError
        }
        
        // Parse numbered list format (1. Quote\n2. Quote\n...)
        let quotes = content
            .components(separatedBy: .newlines)
            .compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                // Match lines starting with numbers like "1.", "2.", etc.
                if let range = trimmed.range(of: "^\\d+\\.\\s*", options: .regularExpression) {
                    let quote = String(trimmed[range.upperBound...])
                        .trimmingCharacters(in: .whitespaces)
                    return quote.isEmpty ? nil : quote
                }
                return nil
            }
        
        // Ensure we have exactly 10 quotes
        guard quotes.count >= 10 else {
            print("Warning: Only received \(quotes.count) quotes from OpenAI")
            throw OpenAIError.insufficientQuotes
        }
        
        // Return first 10 quotes
        return Array(quotes.prefix(10))
    }
}

// MARK: - Error Handling

enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parseError
    case insufficientQuotes
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is not configured"
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let statusCode, let message):
            return "OpenAI API error (\(statusCode)): \(message)"
        case .parseError:
            return "Failed to parse OpenAI response"
        case .insufficientQuotes:
            return "Did not receive enough quotes from OpenAI"
        }
    }
}

