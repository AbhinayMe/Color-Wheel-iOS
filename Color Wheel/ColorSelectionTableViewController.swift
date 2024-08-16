//
//  ColorSelectionTableViewController.swift
//  Color Wheel
//
//  Created by Abhinay M on 16/08/2024.
//

import UIKit

class ColorSelectionTableViewController: UITableViewController {
    var segmentedControl: UISegmentedControl!
    var colorWheelView:ColorWheelView!
    let segmentedColors:[String] = ["#00c2a3", "#4ba54f", "#ff6100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ColorSelectionCell")
        tableView.rowHeight = UITableView.automaticDimension
        
        segmentedControl = createColorSegmentedControl()
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        colorWheelView = ColorWheelView()
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let selectedColorHex:String = segmentedColors[sender.selectedSegmentIndex]
        if let selectedColor = UIColor(hex: selectedColorHex) {
            colorWheelView.updateHandlePosition(with: selectedColor)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        } else if indexPath.row == 1 {
            return UITableView.automaticDimension
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorSelectionCell", for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.contentView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        
        if indexPath.row == 0 {
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.removeFromSuperview()
            cell.contentView.addSubview(segmentedControl)
            NSLayoutConstraint.activate([
                segmentedControl.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                segmentedControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                segmentedControl.widthAnchor.constraint(equalToConstant: 240),
                segmentedControl.heightAnchor.constraint(equalToConstant: 80),
            ])
        } else if indexPath.row == 1 {
            colorWheelView.translatesAutoresizingMaskIntoConstraints = false
            colorWheelView.removeFromSuperview()
            cell.contentView.addSubview(colorWheelView)
            NSLayoutConstraint.activate([
                // The element should be centered with 16pt margin to either side
                colorWheelView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                colorWheelView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                colorWheelView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
                colorWheelView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16),
                colorWheelView.heightAnchor.constraint(equalTo: colorWheelView.widthAnchor).withPriority(.defaultLow)
            ])
        }
        
        return cell
    }
    
    private func createColorSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl()
        
        for (index, colorHex) in segmentedColors.enumerated() {
            if let image = createCircleImage(with: UIColor(hex: colorHex)) {
                let originalImage = image.withRenderingMode(.alwaysOriginal)
                segmentedControl.insertSegment(with: originalImage, at: index, animated: false)
                segmentedControl.setWidth(80, forSegmentAt: index) // Set width of each segment to 80 points
            }
        }
        
        // Set element background color #2c2c2c, selected #3b3b3b
        segmentedControl.backgroundColor = UIColor(hex: "#2c2c2c")
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "#3b3b3b")
        
        return segmentedControl
    }
    
    private func createCircleImage(with color: UIColor?) -> UIImage? {
        guard let color = color else {
            return nil
        }
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
