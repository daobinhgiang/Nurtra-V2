//
//  CravingView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/27/25.
//

import SwiftUI
import AVFoundation

struct CravingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Craving Page")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Camera preview widget
            CameraView()
                .frame(width: 350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            
            Text("This is an empty page for cravings")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
        }
        .navigationTitle("Craving")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CravingView()
    }
}
