//
//  Annotation.swift
//  TripMaker
//
//  Created by Megan Lin on 3/28/24.
//

import Foundation
import SpriteKit
import SwiftUI

// Custom annotation node representing a pin on the map
class AnnotationNode: SKNode {
    var selected = false
    var scale = 0.05

    var relativePosition: (x: CGFloat, y: CGFloat)!
    
    init(imageNamed: String, routeName: String, pos: (CGFloat, CGFloat)) {
        super.init()
        name = routeName
        relativePosition = pos
        
        // Create a container node for the pin and tag
        let container = SKNode()
        
        let pinSprite = SKSpriteNode(imageNamed: imageNamed)
        container.addChild(pinSprite)
        
        // Offset the pin so it points to the correct position
        pinSprite.position = CGPoint(x: 0, y: 10)
        
        // Create tag label
        let tagLabel = SKLabelNode(text: routeName)
        tagLabel.fontName = "Bradley Hand"
        tagLabel.fontSize = 280
        tagLabel.fontColor = .black
        tagLabel.position = CGPoint(x: 0, y: 420) // Position above the pin
        
        // Create a rectangle frame behind the tag label
        let frameSize = CGSize(width: tagLabel.frame.width + 200, height: tagLabel.frame.height + 150)
        let frameRect = CGRect(origin: CGPoint(x: -frameSize.width / 2, y: -(frameSize.height - tagLabel.frame.height) / 2), size: frameSize)
        let frameNode = SKShapeNode(rect: frameRect, cornerRadius: 5)
        frameNode.fillColor = .white
        frameNode.strokeColor = .black
        frameNode.zPosition = -1
        tagLabel.addChild(frameNode)
        
        container.addChild(tagLabel)
                
        // Add the container node to the annotation node
        addChild(container)
        
        pinSprite.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Define the function to handle the tap event
    func annotationTapped() {
        // Handle the tap event here
        print("Annotation tapped!")
        let scale = SKAction.scale(to: min(self.scale * 1.7, 0.13), duration: 0.2)
        self.run(scale)
    }
    
    func annotationUntapped() {
        // Handle the tap event here
        print("Annotation untapped!")
        selected = false
        let scale = SKAction.scale(to: self.scale, duration: 0.2)
        self.run(scale)
    }
}

extension MapScene {
    func addAnnotations() {
        // Create and add annotation nodes
        let annotation1 = AnnotationNode(imageNamed: "pin.jpg", routeName: "Canada", pos: (65 - frame.size.width / 2, 230 - frame.size.height / 2))
        annotation1.setScale(0.05)
        annotation1.position = CGPoint(x: 65, y: 230)
        addChild(annotation1)
        annotation1.isUserInteractionEnabled = true
        annotations.append(annotation1)
        
        let annotation2 = AnnotationNode(imageNamed: "pin.jpg", routeName: "Taiwan", pos: (335 - frame.size.width / 2, 170 - frame.size.height / 2))
        annotation2.setScale(0.05)
        annotation2.position = CGPoint(x: 335, y: 170)
        addChild(annotation2)
        annotation2.isUserInteractionEnabled = true
        annotations.append(annotation2)
        
        let annotation3 = AnnotationNode(imageNamed: "pin.jpg", routeName: "South Korea", pos: (350 - frame.size.width / 2, 220 - frame.size.height / 2))
        annotation3.setScale(0.05)
        annotation3.position = CGPoint(x: 350, y: 220)
        addChild(annotation3)
        annotation3.isUserInteractionEnabled = true
        annotations.append(annotation3)
        
    }
}
