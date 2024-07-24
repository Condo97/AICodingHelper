//
//  OpenAIKeyEntryView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/17/24.
//

import SwiftUI

struct OpenAIKeyEntryView: View {
    
    @Binding var isPresented: Bool
    
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    @State private var openAIKeyEntryText: String = ""
    
    @State private var alertShowingInvalidOpenAIKey: Bool = false
    
    @State private var isLoadingValidation: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Enter OpenAI API Key")
            
            HStack {
                TextField("OpenAI API Key", text: $openAIKeyEntryText)
                    .disabled(isLoadingValidation)
                
                Button("\(Image(systemName: "xmark.circle"))") {
                    activeSubscriptionUpdater.openAIKey = nil
                }
                .disabled(activeSubscriptionUpdater.openAIKey == nil)
                .disabled(isLoadingValidation)
            }
            
            HStack {
                Spacer()
                
                Button("Close") {
                    isPresented = false
                }
                .disabled(isLoadingValidation)
                
                Button("Save") {
                    Task {
                        isLoadingValidation = true
                        await validateAndSaveKey()
                        isLoadingValidation = false
                    }
                }
                .disabled(openAIKeyEntryText.isEmpty)
                .disabled(isLoadingValidation)
            }
        }
        .frame(minWidth: 250.0)
        .padding()
        .onAppear {
            openAIKeyEntryText = activeSubscriptionUpdater.openAIKey ?? ""
        }
        .onChange(of: activeSubscriptionUpdater.openAIKey) { newValue in
            openAIKeyEntryText = newValue ?? ""
        }
        .alert("Invalid OpenAI Key", isPresented: $alertShowingInvalidOpenAIKey, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Your OpenAI Key is invalid. Please watch the tutorial or message me for help! :)")
        })
    }
    
    
    func validateAndSaveKey() async {
        // Ensure authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in OpenAIKeyEntryView... \(error)")
            return
        }
        
        // Validate OpenAI API Key
        let openAIKeyEntryText = openAIKeyEntryText // Bring locally since it's async I guess right lol
        let authRequest = AuthRequest(
            authToken: authToken,
            openAIKey: openAIKeyEntryText)
        
        let validateOpenAIKeyResponse: ValidateOpenAIKeyResponse
        do {
            validateOpenAIKeyResponse = try await AICodingHelperHTTPSConnector().validateOpenAIKey(request: authRequest)
        } catch {
            // TODO: Handle Errors
            print("Error validating OpenAIKey in UltraView... \(error)")
            return
        }
        
        if validateOpenAIKeyResponse.body.valid {
            // If valid, save and close
            activeSubscriptionUpdater.openAIKeyIsValid = true
            activeSubscriptionUpdater.openAIKey = openAIKeyEntryText
            
            isPresented = false
        } else {
            // If invalid, show alert
            alertShowingInvalidOpenAIKey = true
        }
    }
    
}

#Preview {
    
    OpenAIKeyEntryView(isPresented: .constant(true))
        .environmentObject(ActiveSubscriptionUpdater())
    
}
