//
//  ChartGraphView.swift
//  NDChartSwift
//
//  Created by neuneed on 2016/11/17.
//  Copyright © 2016年 dotc. All rights reserved.
//


// TWO LINE VIEW


import Foundation
import UIKit


enum LineType {
    case lineTypeHigh,lineTypeLow
}

let verticalBarsIntervalWidth = 4
let labelOffsetFromPointCenter = 15
let titleHeight = 15


class ChartGraphView: UIScrollView {
    
    let graphView = UIView()
    
    //最高温度，最低温度
    open var lowestData : NSArray = NSArray()
    open var highestData : NSArray = NSArray()

    
    // Color of the graph line
    open var lowLineColor = UIColor(red: 0.71, green: 1.0, blue: 0.196, alpha: 1.0)
    open var highLineColor = UIColor(red: 0.71, green: 1.0, blue: 0.196, alpha: 1.0)

    
    // Point fill color
    open var lowPointFillColor = UIColor(red: 0.219, green: 0.657, blue: 0, alpha: 1.0)
    open var highPointFillColor = UIColor(red: 0.219, green: 0.657, blue: 0, alpha: 1.0)

    
    
    // Width of the stroke of the graph line
    open var strokeWidth : NSInteger! = 2

    // Choose to hide the graph line and just show points
    // defaults to NO
    open var hideLines : Bool = false
    
    // Choose to hide the points and just show line
    // defaults to NO
    open var hidePoints : Bool = false

    // Choose whether to hide the labels floating above the points
    open var hideLabels : Bool = false

    // Choose how wide in pts the graph should be
    // defaults to width of screen (landscape) x2
    open  var graphWidth : CGFloat!
    
    // Background colour for the scrollView
    open var backgroundViewColor = UIColor.clear
    
    // Colour of the vertical bar that defines each x axis values
    open var barColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    

    // Font of the laber
    open var labelFontColor = UIColor.white

    // Font to use only on the x axis labels
    open var labelFont = UIFont.systemFont(ofSize: 12)

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
        
        if lowestData.count > 0 && highestData.count > 0
        {
            plotGraphData()
        }
        
    }
    
    fileprivate func plotGraphData() {
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = self.backgroundViewColor
        self.contentSize = CGSize.init(width: graphWidth, height: self.frame.height)
        self.addSubview(graphView)
        
        let xCoordOffset = self.highestData.count >= self.lowestData.count ?
                            (Float(graphWidth) / Float(self.highestData.count)) / 2.0
                            :(Float(graphWidth) / Float(self.lowestData.count)) / 2.0
        
       
        graphView.frame = CGRect(x: CGFloat(-xCoordOffset), y: 0.0 , width: graphWidth, height: self.frame.height)
        
        var lowPointsCenterLocations : [NSValue?] = Array()
        var highPointsCenterLocations : [NSValue?] = Array()
        
    
        //最大 最小值 和区间
        let lowestDic : NSDictionary! = self.workOutRangeFromArray(array: self.lowestData)
        let hightestDic : NSDictionary! = self.workOutRangeFromArray(array: self.highestData)
        
        var lowest:NSInteger = lowestDic.value(forKey: "lowest") as! NSInteger
        var highest:NSInteger = hightestDic.value(forKey: "highest") as! NSInteger
        var range = highest - lowest
        if (range == 0) {
            lowest = 0
            if highest == 0{ highest = 10}
            range = highest * 2
        }
//        var lastPoint :CGPoint = CGPoint(x:0, y:0)
        
        
        //画背景和文字 计算点
        let dataArray = self.highestData.count >= self.lowestData.count ? self.highestData :self.lowestData
        for counter in 1...dataArray.count {
            
            let xCoord = Int(Float(graphWidth) / Float(dataArray.count) * Float(counter))
            
//            var offsets = titleHeight + kPointLabelOffsetFromPointCenter
            var offsets = 0
            if hideLabels == false
            {
                offsets += kBarLabelHeight
            }
            
            let offSetFromTop :CGFloat! = 10.0 + 20.0
            let offsetFromBottom :CGFloat! = 10.0 + 20.0
            
            let screenHeight :CGFloat = (self.frame.height - CGFloat(offsets)) / (self.frame.height + offSetFromTop + offsetFromBottom)
            
            
            let rangeHeight : CGFloat = (self.frame.size.height * screenHeight) / CGFloat(range)
            
            
            let highOffset : CGFloat =  CGFloat((highestData[counter-1] as! NSInteger - lowest)) * rangeHeight
            let highPoint = CGPoint(x: CGFloat(xCoord), y:CGFloat( self.frame.size.height - offsetFromBottom - highOffset))

            
            let lowoffset : CGFloat =  CGFloat((lowestData[counter-1] as! NSInteger - lowest)) * rangeHeight
            let lowPoint = CGPoint(x: CGFloat(xCoord), y:CGFloat( self.frame.size.height - offsetFromBottom - lowoffset))

            
            //画点下方的文字
            if self.hideLabels == false
            {
                self.createPointLabelForPoint(point: lowPoint, text: NSString(string: "\(lowestData[counter-1])°") ,type: LineType.lineTypeLow)
                self.createPointLabelForPoint(point: highPoint, text: NSString(string: "\(highestData[counter-1])°") ,type: LineType.lineTypeHigh)
            }
            
            //创建背景图
            if self.highestData.count >= self.lowestData.count {
                self.createBackgroundVerticalBarWithXCoord(point: lowPoint, indexNumber: counter-1)
            }
            else{
                self.createBackgroundVerticalBarWithXCoord(point: highPoint, indexNumber: counter-1)
            }
            
            
            var lowPointValue : NSValue = NSValue()
            lowPointValue = NSValue(cgPoint: lowPoint)
            lowPointsCenterLocations.append(lowPointValue)
            
            var highPointValue : NSValue = NSValue()
            highPointValue = NSValue(cgPoint: highPoint)
            highPointsCenterLocations.append(highPointValue)
            
//            lastPoint = point
        }
        
        
        
        
        //画曲线
        self.drawCurvedLineBetweenPoints(pointArray: highPointsCenterLocations as! Array<NSValue>,type:LineType.lineTypeHigh)
        self.drawCurvedLineBetweenPoints(pointArray: lowPointsCenterLocations as! Array<NSValue>, type:LineType.lineTypeLow)
        

        
        //画点
        if self.hidePoints == false
        {
            //high
            self.drawPointswithStrokeColour(pointStrokeColor: highLineColor, pointFillColor: highPointFillColor, pointsLocations: highPointsCenterLocations as! Array<NSValue>)
            
            
            //low
            self.drawPointswithStrokeColour(pointStrokeColor: lowLineColor, pointFillColor: lowPointFillColor, pointsLocations: lowPointsCenterLocations as! Array<NSValue>)
        }
        
       
    }

    
    /// 排序 取出最大 最小的值 和范围
    func workOutRangeFromArray(array: NSArray) -> NSDictionary {
        
        let newArray = array.sortedArray(using: #selector(NSNumber.compare(_:)))
        
        let lowest = newArray.first as! NSInteger
        let highest = newArray.last as! NSInteger
//        let range = highest - lowest
        let  graphRange = NSDictionary(objects:[ NSNumber(value: lowest),NSNumber(value: highest)], forKeys: ["lowest" as NSCopying,"highest" as NSCopying])
        return graphRange
    }
    
    
    
    //MARK: -- 画背景
    fileprivate func createBackgroundVerticalBarWithXCoord(point : CGPoint , indexNumber: NSInteger)  {
        //swift 3 余数
        let x = Float(self.graphWidth).truncatingRemainder(dividingBy: Float(Double(lowestData.count)))
        
        self.contentSize = CGSize.init(width: self.graphWidth - CGFloat(x) , height: self.frame.size.height)
        let bgView = UIView()
        bgView.frame = CGRect.init(x: 0, y: 0, width: graphWidth/CGFloat(lowestData.count) - CGFloat(verticalBarsIntervalWidth), height: self.frame.size.height * 2)
        bgView.backgroundColor = barColor
        graphView.addSubview(bgView)
        bgView.center = CGPoint.init(x: point.x, y: 16.0)
    }
    
    
    
    fileprivate func createPointLabelForPoint(point : CGPoint , text: NSString ,type: LineType)
    {
        let tempLabel = UILabel()
        tempLabel.frame = CGRect(x: 0, y: 0, width: CGFloat(30.0), height: CGFloat(titleHeight))
        tempLabel.textAlignment = .center
        tempLabel.textColor = labelFontColor
        tempLabel.backgroundColor = labelBackgroundColor
        tempLabel.font = labelFont
        tempLabel.adjustsFontSizeToFitWidth = true
        tempLabel.minimumScaleFactor = 0.6
        graphView.addSubview(tempLabel)
        
        if type == LineType.lineTypeLow
        {
            tempLabel.center = CGPoint(x: point.x, y: point.y + CGFloat(labelOffsetFromPointCenter))
        }
        else
        {
            tempLabel.center = CGPoint(x: point.x, y: point.y - CGFloat(labelOffsetFromPointCenter))
        }
        
        tempLabel.text = text as String
    }
    
    
    //曲线
    func drawCurvedLineBetweenPoints(pointArray :Array<NSValue> , type: LineType)
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
        shapeLayer.strokeColor = type == LineType.lineTypeHigh ? highLineColor.cgColor : lowLineColor.cgColor
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

extension ChartGraphView :CAAnimationDelegate
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
