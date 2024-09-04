//
//  LottieView.swift
//  TripMaker
//
//  Created by Megan Lin on 4/1/24.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    var animationFileName: String
    let loopMode: LottieLoopMode
    var flip = false
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.animationSpeed = 0.5
        animationView.loopMode = loopMode
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        
        if flip {
            animationView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        
        //animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        return animationView
    }
}

#Preview {
    LottieView(animationFileName: "WalkingAnimation", loopMode: .loop)
}
