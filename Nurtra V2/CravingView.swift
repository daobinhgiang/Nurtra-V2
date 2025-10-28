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
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                // Camera preview widget
                CameraView()
                    .frame(width: geometry.size.width * 0.8)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
