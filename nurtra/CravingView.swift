//
//  CravingView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/27/25.
//

import SwiftUI
import AVFoundation

struct CravingView: View {
    @State private var showSurvey = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Camera preview at the top, expanding vertically as much as possible
                CameraView()
                    .frame(width: geometry.size.width * 0.94) // near full width, keep some side padding
                    .frame(maxHeight: .infinity, alignment: .top) // let it expand vertically
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 10)

                // Bottom buttons in one row
                HStack(spacing: 12) {
                    // Left: I just binged (red)
                    Button(action: {
                        showSurvey = true
                    }) {
                        Text("I just binged")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Right: I overcame it (blue)
                    Button(action: {
                        // TODO: Handle "I overcame it"
                    }) {
                        Text("I overcame it")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.03) // aligns with camera side padding (approx)
                .padding(.bottom) // safe area-friendly bottom padding

                // Invisible navigation trigger
                NavigationLink(isActive: $showSurvey) {
                    BingeSurveyView()
                } label: {
                    EmptyView()
                }
                .hidden()
                .frame(width: 0, height: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top)
        }
    }
}

#Preview {
    NavigationStack {
        CravingView()
    }
}
