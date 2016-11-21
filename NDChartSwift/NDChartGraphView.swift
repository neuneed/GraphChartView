//
//  NDChartGraphView.swift
//  NDChartSwift
//
//  Created by neuneed on 2016/11/17.
//  Copyright © 2016年 dotc. All rights reserved.
//

import Foundation
import UIKit


let kGapBetweenBackgroundVerticalBars = 4
let kPointLabelOffsetFromPointCenter = 20
let kBarLabelHeight = 20
let kPointLabelHeight = 15


class NDChartGraphView: UIScrollView {
    
    let graphView = UIView()
    
    // Array of NSNumbers used to plot points on graph
    open var graphData : NSArray = NSArray()

    // Labels to match graphData points
//    open var graphDataLabels : NSArray = NSArray()
    
    

    // Colour of the graph line
    open var strokeColor = UIColor(red: 0.71, green: 1.0, blue: 0.196, alpha: 1.0)
    
    // Fill colour for the point on the graph

    open var pointFillColor = UIColor(red: 0.219, green: 0.657, blue: 0, alpha: 1.0)
    
    // Width of the stroke of the graph line
    open var strokeWidth : NSInteger! = 2

    // Choose whether to hide the graph line and just show points
    // defaults to NO
    open var hideLines : Bool = false
    
    // Choose whether to hide the points and just show line
    // defaults to NO
    open var hidePoints : Bool = false
    
    // Choose to show curved line that passes through all points
    // defaults to NO (straight lines between points)
    open var useCurvedLine : Bool = false

    // Choose whether to hide the labels floating above the points
    open var hideLabels : Bool = false

    // Choose how wide in pts the graph should be
    // defaults to width of screen (landscape) x2
    open  var graphWidth : CGFloat!
    
    // Background colour for the scrollView
    open var backgroundViewColor = UIColor.black
    
    // Colour of the vertical bar that defines each x axis values
    
    open var barColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    
    // Font to use on the x and y axis labels
    open var labelFont = UIFont.systemFont(ofSize: 12)
    
    // Font colour of the x and y axis labels
    open var labelFontColor = UIColor.white

    // Font to use only on the x axis labels
    open var labelXFont = UIFont.systemFont(ofSize: 12)

    // Font colour only on the x axis labels
    open var labelXFontColor = UIColor.white


    // Colour of the background for the x and y axis UILabels
    open var labelBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        graphWidth = self.frame.width * 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if graphData.count > 0
        {
            plotGraphData()
        }
        
    }
    
    fileprivate func plotGraphData() {
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = self.backgroundViewColor
        self.contentSize = CGSize.init(width: graphWidth, height: self.frame.height)
        self.addSubview(graphView)
        
        
        let xCoordOffset = (Float(graphWidth) / Float(graphData.count)) / 2.0
        graphView.frame = CGRect(x: CGFloat(-xCoordOffset), y: 0.0 , width: graphWidth, height: self.frame.height)
        
        var pointsCenterLocations : [NSValue?] = Array()
        
    
        let graphRange : NSDictionary! = self.workOutRangeFromArray(array: graphData)
        var range:NSInteger = graphRange.value(forKey: "range") as! NSInteger
        var lowest:NSInteger = graphRange.value(forKey: "lowest") as! NSInteger
        var highest:NSInteger = graphRange.value(forKey: "highest") as! NSInteger
        
        if (range == 0) {
            lowest = 0
            if highest == 0{ highest = 10}
            range = highest * 2
        }
        var lastPoint :CGPoint = CGPoint(x:0, y:0)
        
        for counter in 1...graphData.count {
            
            let xCoord = Int(Float(graphWidth) / Float(graphData.count) * Float(counter))
            
//            var offsets = kPointLabelHeight + kPointLabelOffsetFromPointCenter
            var offsets = 0
            if hideLabels == false
            {
                offsets += kBarLabelHeight
            }
            
            let offSetFromTop :CGFloat! = 10.0 + 15.0
            let offsetFromBottom :CGFloat! = 10.0 + 15.0
            
            let screenHeight :CGFloat = (self.frame.height - CGFloat(offsets)) / (self.frame.height + offSetFromTop + offsetFromBottom)
            
            let rangeHeight : CGFloat = (self.frame.size.height * screenHeight) / CGFloat(range)
            
            let offset : CGFloat =  CGFloat((graphData[counter-1] as! NSInteger - lowest)) * rangeHeight
            
            let point = CGPoint(x: CGFloat(xCoord), y:CGFloat( self.frame.size.height - offsetFromBottom - offset))

            self.createBackgroundVerticalBarWithXCoord(point: point, indexNumber: counter-1)
            
            //画点上方的文字
            if self.hideLabels == false
            {
                self.createPointLabelForPoint(point: point, text: NSString(string: "\(graphData[counter-1])") )
            }
            
            //画直线
            if useCurvedLine == false
            {
                if lastPoint.x != 0 {
                    if !self.hideLines {
                        self.drawLineBetweenPoint(lastPoint: lastPoint, point: point, strokeColor: strokeColor)
                    }
                }
            }
            
            var pointValue : NSValue = NSValue()
            pointValue = NSValue(cgPoint: point)
            pointsCenterLocations.append(pointValue)
            
            lastPoint = point
        }
        
        //画曲线
        if self.useCurvedLine == true && self.hideLines == false
        {
            self.drawCurvedLineBetweenPoints(pointArray: pointsCenterLocations as! Array<NSValue>)
        }
        
        //画点
        if self.hidePoints == false
        {
            self.drawPointswithStrokeColour(pointStrokeColor: strokeColor, pointFillColor: pointFillColor, pointsLocations: pointsCenterLocations as! Array<NSValue>)
        }
       
    }

    
    /// 排序 取出最大 最小的值 和范围
    func workOutRangeFromArray(array: NSArray) -> NSDictionary {
        
        let newArray = array.sortedArray(using: #selector(NSNumber.compare(_:)))
        
        let lowest = newArray.first as! NSInteger
        let highest = newArray.last as! NSInteger
        let range = highest - lowest
        let  graphRange = NSDictionary(objects:[ NSNumber(value: lowest),NSNumber(value: highest),NSNumber(value: range)], forKeys: ["lowest" as NSCopying,"highest" as NSCopying,"range" as NSCopying])

        return graphRange
    }
    
    
    //MARK: -- Drawing methods
    fileprivate func createBackgroundVerticalBarWithXCoord(point : CGPoint , indexNumber: NSInteger)  {
        //swift 3 余数
        let x = Float(self.graphWidth).truncatingRemainder(dividingBy: Float(Double(graphData.count)))
        
        self.contentSize = CGSize.init(width: self.graphWidth - CGFloat(x) , height: self.frame.size.height)
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: graphWidth/CGFloat(graphData.count) - CGFloat(kGapBetweenBackgroundVerticalBars), height: self.frame.size.height * 2)
        label.textAlignment = .center
        label.textColor = labelXFontColor
        label.backgroundColor = barColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.font = labelXFont
        label.numberOfLines = 2
//        label.text = graphDataLabels[indexNumber] as? String
        graphView.addSubview(label)
        label.center = CGPoint.init(x: point.x, y: 16.0)
    }
    
    
    fileprivate func createPointLabelForPoint(point : CGPoint , text: NSString )
    {
        let tempLabel = UILabel()
        tempLabel.frame = CGRect(x: point.x, y: point.y, width: CGFloat(30.0), height: CGFloat(kPointLabelHeight))
        tempLabel.textAlignment = .center
        tempLabel.textColor = labelFontColor
//        tempLabel.backgroundColor = labelBackgroundColor
        tempLabel.font = labelFont
        tempLabel.adjustsFontSizeToFitWidth = true
        tempLabel.minimumScaleFactor = 0.6
        graphView.addSubview(tempLabel)
        tempLabel.center = CGPoint.init(x: point.x, y: point.y - CGFloat(kPointLabelOffsetFromPointCenter))
        tempLabel.text = text as String
    }
    
    
    fileprivate func drawLineBetweenPoint(lastPoint: CGPoint , point:CGPoint , strokeColor:UIColor )  {

        let linePath = CGMutablePath()
        let lineShape = CAShapeLayer()
        
        lineShape.lineWidth = CGFloat(strokeWidth)
        lineShape.lineCap = kCALineCapRound
        lineShape.lineJoin = kCALineJoinBevel
        lineShape.strokeColor = strokeColor.cgColor

        linePath.move(to: lastPoint)
        linePath.addLine(to: point)
        
        lineShape.path = linePath
    
        graphView.layer.addSublayer(lineShape)
        self.addLineAnimation(targetLayer: lineShape)
    }
    
    func drawCurvedLineBetweenPoints(pointArray :Array<NSValue>)
    {
        let curve = UIBezierPath()
        
        var pointsArray = Array<CGPoint>()
        for item in pointArray
        {
            pointsArray.append(item as CGPoint)
        }

        curve.contractionFactor = CGFloat(0.7)
        curve.move(to: pointsArray[0])
        curve.addBezierThrough(points: pointsArray)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = CGFloat(strokeWidth)
        shapeLayer.path = curve.cgPath
        shapeLayer.lineCap = kCALineCapRound
        self.graphView.layer.addSublayer(shapeLayer)
        self.addLineAnimation(targetLayer: shapeLayer)
    }
    

    func pointAtIndex(index: NSInteger ,array : NSArray) -> CGPoint{
        let value = array[index]
        return (value as AnyObject).cgPointValue
    }
    
    
    func drawPointswithStrokeColour(pointStrokeColor: UIColor , pointFillColor: UIColor , pointsLocations: Array<NSValue>) {
        
        if pointsLocations.count == 0 {
            return
        }
        else
        {
            for i in 0..<pointsLocations.count
            {
                let pointRect = CGRect(x: 0, y: 0, width: 20, height: 20)
                let point = NDChartGraphPoint.init(frame: pointRect)
                point.strokeColor = pointStrokeColor
                point.fillColor = pointFillColor
                point.backgroundColor = UIColor.clear
                
                point.center = pointsLocations[i].cgPointValue
                graphView.addSubview(point)
            }
        }
    }
}


extension NDChartGraphView :CAAnimationDelegate
{
    fileprivate func addLineAnimation(targetLayer : CAShapeLayer) {
        let lineAnimation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        lineAnimation.duration = 0.1 * 15 * 2
        lineAnimation.delegate = self
        lineAnimation.fromValue = 0.0
        lineAnimation.toValue = 1.0
        lineAnimation.fillMode = kCAFillModeForwards
        lineAnimation.isRemovedOnCompletion = false
        targetLayer.add(lineAnimation, forKey: "strokeEnd")
        
    }
}
