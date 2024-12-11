/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A simple cartoon character animated using ARKit blend shapes.
*/

import Foundation
import SceneKit
import ARKit

/// - Tag: BlendShapeCharacter
class BlendShapeCharacter: NSObject, VirtualContentController {

    var contentNode: SCNNode?
    private var jumpscareNode: SCNNode?
    private let baseScale: Float = 0.07 // Adjust this value to change the overall size
    // Add color properties
    private let monochromeColor = UIColor.orange
    private let colorfulColor = UIColor.gray // You can change this to any vibrant color
    private let minDistance: Float = 0.3 // Minimum distance for color change
    private let maxDistance: Float = 2.0 // Maximum distance for color change
    private let jumpscareDistance: Float = 0.2 // Distance at which the jumpscare is visible
    // Add a property to store the text node
    private var textNode: SCNNode?
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else { return nil }

        // Load the reference node for the character
        contentNode = SCNReferenceNode(named: "Pumpkinhead2")
        
        // Apply initial scale
        contentNode?.scale = SCNVector3(baseScale, baseScale, baseScale)
        
        // Shift the model down and back
        contentNode?.position = SCNVector3(0, -0.08, 0)
        
        // Enable depth testing for occlusion
        contentNode?.renderingOrder = -1
        contentNode?.opacity = 0.99999 // Slightly less than 1 to enable depth testing

        // Load the jumpscare model
        jumpscareNode = SCNReferenceNode(named: "jumpscare")
        jumpscareNode?.isHidden = true
        contentNode?.addChildNode(jumpscareNode!)

        return contentNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        let distance = calculateDistanceToCamera(faceAnchor: faceAnchor)
        updateColorBasedOnDistance(distance)
        updateJumpscareVisibility(distance)
        // Handle blend shapes if needed
    }

    private func calculateDistanceToCamera(faceAnchor: ARFaceAnchor) -> Float {
        // The position of the face anchor is relative to the camera
        let facePosition = faceAnchor.transform.columns.3
        
        // Calculate the distance using the x, y, and z components
        let distance = sqrt(
            facePosition.x * facePosition.x +
            facePosition.y * facePosition.y +
            facePosition.z * facePosition.z
        )
        
        return distance
    }
    private func updateColorBasedOnDistance(_ distance: Float) {
        // Clamp the distance between minDistance and maxDistance
        let clampedDistance = max(minDistance, min(maxDistance, distance))
        
        // Calculate the interpolation factor
        let factor = (clampedDistance - minDistance) / (maxDistance - minDistance)
        
        // Interpolate between monochromeColor and colorfulColor
        let newColor = interpolateColor(from: monochromeColor, to: colorfulColor, with: CGFloat(factor))
        
        // Apply the new color to all child nodes
        contentNode?.enumerateHierarchy { (node, _) in
            if let geometry = node.geometry {
                geometry.materials.forEach { material in
                    material.diffuse.contents = newColor
                }
            }
        }
    }

    private func interpolateColor(from: UIColor, to: UIColor, with factor: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + factor * (toRed - fromRed)
        let green = fromGreen + factor * (toGreen - fromGreen)
        let blue = fromBlue + factor * (toBlue - fromBlue)
        let alpha = fromAlpha + factor * (toAlpha - fromAlpha)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    private func updateJumpscareVisibility(_ distance: Float) {
        print(distance)
        
        
    }
}
