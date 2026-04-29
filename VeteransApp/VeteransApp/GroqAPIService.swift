import Foundation

struct GroqChatMessage: Codable {
    let role: String
    let content: String
}

class GroqAPIService {
    static let shared = GroqAPIService()


    // MARK: - CONFIGURATION
    // USER: PASTE YOUR GROQ API KEY HERE!
    var apiKey: String = "" 
    let endpoint = "https://api.groq.com/openai/v1/chat/completions"
    
    // MARK: - SYSTEM PROMPT
    private let systemPrompt = """
You are a supportive, respectful, and stoic companion designed to check in on military veterans.
Your tone should be direct, grounded, and concise. Avoid overly flowery or overly therapeutic language, as it may feel alienating.
Speak "shoulder-to-shoulder" with the veteran. Keep your responses short—often just one or two sentences.
Ask simple, grounding questions about their day, their state of mind, or if they've had a chance to focus on themselves today.

IMPORTANT APP CONTEXT: You reside within the app named "TroopCompanion". The app has 4 main features you can suggest if appropriate:
1. "Breathing Exercises": Helps them steady their mind (Box Breathing, Deep Breathing, Wim Hof).
2. "Resources": Emergency Hotlines (988, 838255), VA Mental Health Services, and Support networks (Warriors Heart, Boulder Crest).
3. "Notifications": A dashboard to keep track of their schedule and daily tasks.
4. "Daily Check-ins": This current chat interface where you are speaking to them.

If they express distress or anxiety, remain steady and gently encourage them to use the "Breathing Exercises" for immediate calm, or visit the "Resources" page to reach out to their support networks.
"""
    
    func sendMessage(messages: [GroqChatMessage], completion: @escaping (String?) -> Void) {
        guard !apiKey.isEmpty else {
            print("ERROR: Groq API Key is missing. Please add it to GroqAPIService.swift")
            DispatchQueue.main.async {
                completion("API Key Missing! Paste your Groq API key into GroqAPIService.swift.")
            }
            return
        }
        
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Inject system prompt into messages
        var fullMessages = [GroqChatMessage(role: "system", content: systemPrompt)]
        fullMessages.append(contentsOf: messages)
        
        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant", // Updated from decommissioned legacy model
            "messages": fullMessages.map { ["role": $0.role, "content": $0.content] },
            "temperature": 0.5,
            "max_tokens": 150 // Keep responses naturally short
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown")")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let errorObj = json["error"] as? [String: Any] {
                        print("Groq API Error: \(errorObj)")
                    }
                    
                    if let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        DispatchQueue.main.async {
                            completion(content)
                        }
                    } else {
                        print("Failed to parse choices from Groq response.")
                        DispatchQueue.main.async { completion(nil) }
                    }
                } else {
                    print("Failed to cast JSON to dictionary.")
                    DispatchQueue.main.async { completion(nil) }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
}
