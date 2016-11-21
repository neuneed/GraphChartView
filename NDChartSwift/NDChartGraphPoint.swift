//
//  NDChartGraphPoint.swift
//  NDChartSwift
//
//  Created by neuneed on 2016/11/17.
//  Copyright © 2016 dotc. All rights reserved.
//

import Foundation
import UIKit

class NDChartGraphPoint: UIView {
    
    var strokeColor = UIColor()
    var fillColor = UIColor()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let strokeColor = self.strokeColor
        let fillColor = self.fillColor

        
        let path = UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 5, height: 5))
        fillColor.setFill()
        path.fill()
        strokeColor.setStroke()

        path.lineWidth = 1
        path.stroke()  
    }
}
