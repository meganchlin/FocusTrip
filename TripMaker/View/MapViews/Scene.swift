//
//  Scene.swift
//  TripMaker
//
//  Created by Megan Lin on 3/28/24.
//

import Foundation
import SwiftUI
import SpriteKit


class MapScene: SKScene {
    var scale = 0.175
    var lastTouchPosition: CGPoint? // Store the last touch position
    var annotations: [AnnotationNode] = []
    @Binding var selectedRoute: String
    //@Binding var currentScale: CGFloat
    
    
    var background: SKSpriteNode!
    var gradientNode: SKSpriteNode!
    
    init(selectedRoute: Binding<String>) {
        self._selectedRoute = selectedRoute // Initialize the binding property
        //self._currentScale = currentScale
        super.init(size: CGSize(width: 400, height: 300))
            
        // Other setup for the SKScene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        // Add background image
        //scene?.size = CGSize(width: 390, height: 310)
        print("init again")
        
        background = SKSpriteNode(imageNamed: "world_map.jpg")
        background.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        //background.scale(to: self.size) // Scale the background to fit the scene
        background.setScale(scale)
        background.zPosition = -1
        addChild(background)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(recognizer)
        
//        print("set background ", background)
        isUserInteractionEnabled = true
        
        // Add annotations
        addAnnotations()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           // Get the first touch
           guard let touch = touches.first else { return }
           
           // Store the touch position
           lastTouchPosition = touch.location(in: self)
            //print("in touches")
       }
       
       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           // Get the first touch
           guard let touch = touches.first, let lastTouchPosition = lastTouchPosition else { return }
           
           // Calculate the change in touch position
           let newTouchPosition = touch.location(in: self)
           let deltaX = newTouchPosition.x - lastTouchPosition.x
           let deltaY = newTouchPosition.y - lastTouchPosition.y
           
           let minX = -background.size.width / 2 + frame.size.width
           let maxX = background.size.width / 2
           let minY = -background.size.height / 2 + frame.size.height
           let maxY = background.size.height / 2
           //let newPosition = CGPoint(x: max(minX, min(maxX, background.position.x + deltaX)), y: max(minY, min(maxY, background.position.y + deltaY)))
           
           //let moveAction = SKAction.move(to: newPosition, duration: 0.1)
           //background.run(moveAction)
           
           background.position.x = max(minX, min(maxX, background.position.x + deltaX))
           background.position.y = max(minY, min(maxY, background.position.y + deltaY))
           
           //print(background.position)
           
           for annot in annotations {
               let newPosX = (background.xScale / scale) * annot.relativePosition.x + background.position.x
               let newPosY = (background.yScale / scale) * annot.relativePosition.y + background.position.y
               let newPosition = CGPoint(x: newPosX, y: newPosY)
               let moveAction = SKAction.move(to: newPosition, duration: 0.01)
               annot.run(moveAction)
           }
           
           // Update the last touch position
           self.lastTouchPosition = newTouchPosition
       }
       
       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           // Reset the last touch position
           lastTouchPosition = nil
       }
    
    func scaleBackground(scale: CGFloat) {
        guard let background = self.background else {
            return
        }
        
        // Set the scale of the background node
        
        let scaleFactor = self.background.xScale * ((scale - 1) * 0.5 + 1)
        
        //print(scaleFactor)
        
        let newScale = max(min(scaleFactor, 1.0), self.scale)
        //currentScale = newScale
        let scaleAction = SKAction.scale(to: newScale, duration: 0.3)
        
        let minX = -(background.texture?.size().width)! * newScale / 2 + frame.size.width
        let maxX = (background.texture?.size().width)! * newScale / 2
        let minY = -(background.texture?.size().height)! * newScale / 2 + frame.size.height
        let maxY = (background.texture?.size().height)! * newScale / 2
        
        let newPosX = max(minX, min(maxX, background.position.x))
        let newPosY = max(minY, min(maxY, background.position.y))
        let newPosition = CGPoint(x: newPosX, y: newPosY)
        //print(background)
        //print("scale: ", newScale)

        // Create the move action to adjust the position
        let moveAction = SKAction.move(to: newPosition, duration: 0.3)
        
        // Group the scaling and moving actions
        let groupAction = SKAction.group([scaleAction, moveAction])

        // Run the group action on the background node
        background.run(groupAction)
        
        
        for annot in annotations {
            let scaleAnnotation = max(min(newScale / self.scale * 0.05, 0.1), 0.05)
            let scaleAction = SKAction.scale(to: scaleAnnotation, duration: 0.3)
            annot.scale = scaleAnnotation
            
            let newPosX_a = (newScale / self.scale) * annot.relativePosition.x + newPosX
            let newPosY_a = (newScale / self.scale) * annot.relativePosition.y + newPosY
            let newPosition = CGPoint(x: newPosX_a, y: newPosY_a)
            let moveAction = SKAction.move(to: newPosition, duration: 0.3)
            
            // Group the scaling and moving actions
            let groupAction = SKAction.group([scaleAction, moveAction])

            // Run the group action on the background node
            annot.run(groupAction)
        }
        
        //print(self.background)
        //print("scale success ", self.background.xScale, self.background.yScale)
    }
    
    @objc func tap(_ recognizer: UIGestureRecognizer) {
        let viewLocation = recognizer.location(in: self.view)
        print(viewLocation)
        let sceneLocation = convertPoint(fromView: viewLocation)
        print(sceneLocation)
            
        for annot in annotations {
            print(annot.frame)
            print(annot)
            if annot.contains(sceneLocation) {
                annot.selected.toggle()
                if annot.selected {
                    dismissPopover()
                    annot.annotationTapped()
                    showPopover(route: annot.name!, node: annot)
                } else {
                    annot.annotationUntapped()
                }
            } else {
                annot.annotationUntapped()
            }
        }
    }
    
    private func showPopover(route: String, node: AnnotationNode) {
        guard let sceneView = self.scene?.view else { return }
        
        let popoverView = RoutePopover(scene: (self.scene as! MapScene), node: node, route: route)
        let popoverSize = CGSize(width: 250, height: 250) // Adjust size as needed
            
                
        // Calculate the popover position
        let popoverOrigin = CGPoint(x: 75, y: 30)
                
        // Present the popover view using a SwiftUI hosting controller
        let hostingController = UIHostingController(rootView: popoverView)
        hostingController.view.frame = CGRect(origin: popoverOrigin, size: popoverSize)
        hostingController.view.tag = 123
        
        sceneView.addSubview(hostingController.view)
    }
    
    func dismissPopover() {
        print("dismiss popover")
        guard let sceneView = self.scene?.view else { return }
        
        // Find the popover view using its unique tag
        if let popoverView = sceneView.viewWithTag(123) {
            print("dismiss ...")
            // Remove the popover view from its superview
            popoverView.removeFromSuperview()
        }
    }
    
    func selectRoute(route: String){
        selectedRoute = route
    }
}
