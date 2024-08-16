//
//  ColorWheelView.swift
//  Color Wheel
//
//  Created by Abhinay M on 16/08/2024.
//

import UIKit

class ColorWheelView: UIView {
    
    var handlePosition: CGPoint = .zero
    var selectedColor: UIColor = .white
    var colorChanged: ((UIColor) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        // Set the handler position to the center by default
        handlePosition = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the handler stays centered when the view's bounds change
        handlePosition = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    
    func updateHandlePosition(with color: UIColor) {
        // Convert the color to a point on the color wheel
        let point = point(for: color)
        handlePosition = point
        selectedColor = color
        setNeedsDisplay()
    }
    
    private func point(for color: UIColor) -> CGPoint {
        // Logic to convert color to point on the color wheel
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let radius = min(bounds.width, bounds.height) / 2
        let angle = hue * 2 * .pi
        let distance = saturation * radius
        
        let x = bounds.midX + distance * cos(angle)
        let y = bounds.midY + distance * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Clear the context
        context.clear(rect)
        
        let radius = min(bounds.width, bounds.height) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        for angle in stride(from: 0, to: 360, by: 1) {
            let hue = CGFloat(angle) / 360.0
            let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            context.setFillColor(color.cgColor)
            
            let startAngle = CGFloat(angle) * .pi / 180
            let endAngle = CGFloat(angle + 1) * .pi / 180
            
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
        }
        
        let gradientColors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: gradientLocations) {
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
        }
        
        let handleSize: CGFloat = 35
        let handleOffset: CGFloat = 4
        let handleRadius = handleSize / 2
        let handleRect = CGRect(x: handlePosition.x - handleRadius, y: handlePosition.y - handleRadius, width: handleSize, height: handleSize)
        
        context.setShadow(offset: CGSize(width: handleOffset, height: handleOffset), blur: 23, color: UIColor.black.withAlphaComponent(0.5).cgColor)
        context.setFillColor(selectedColor.cgColor)
        context.fillEllipse(in: handleRect)
        
        context.setShadow(offset: .zero, blur: 0, color: nil)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: handleRect)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(touches)
    }
    
    private func handleTouch(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handlePosition = location
        selectedColor = color(at: location)
        colorChanged?(selectedColor)
        setNeedsDisplay()
    }
    
    private func color(at point: CGPoint) -> UIColor {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angle = atan2(dy, dx)
        let hue = (angle < 0 ? angle + 2 * .pi : angle) / (2 * .pi)
        let distance = sqrt(dx * dx + dy * dy)
        let radius = min(bounds.width, bounds.height) / 2
        // Calculate the saturation based on the distance from the center
        let saturation = min(distance / radius, 1.0)
        let brightness: CGFloat = 1.0
        
        // Return white color if the distance is less than 1.0
        if distance < 1.0 {
            return UIColor(white: 1.0, alpha: 1.0)
        }
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}
