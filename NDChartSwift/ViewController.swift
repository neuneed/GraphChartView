//
//  ViewController.swift
//  NDChartSwift
//
//  Created by Lee on 2016/11/17.
//  Copyright © 2016年 dotc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 89.0/255.0, green: 138.0/255.0, blue: 173.0/255.0, alpha: 1)
        self.addLineView()
        
        self.addTwoLineView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLineView()
    {
        
        let graphBGView = UIView()
        graphBGView.frame = CGRect.init(x: 0, y: 64, width: self.view.frame.width, height: 250)
        self.view.addSubview(graphBGView)
        
        let graphView = NDChartGraphView.init(frame: graphBGView.bounds)
        
        graphView.graphData = [20,16,14,20,10,39,22,11,56,33,11,22,33,15,66]
        
        
        graphView.pointFillColor = UIColor.red
        graphView.strokeColor = UIColor.green
        graphView.strokeWidth = 2
        
        graphView.useCurvedLine = true
        graphView.hideLabels = false
        graphView.graphWidth = graphView.frame.size.width * 2;
        graphView.hidePoints = false
        graphView.hideLines = false
        
        graphView.backgroundViewColor = UIColor.clear
        graphView.barColor = UIColor.lightGray.withAlphaComponent(0.3)
        graphView.labelFont = UIFont.systemFont(ofSize: 14)
        graphView.labelFontColor = UIColor.white
        graphView.labelBackgroundColor = UIColor.clear
        
        graphBGView.addSubview(graphView)
        self.view.addSubview(graphBGView)
        
    }

    func addTwoLineView()
    {
        let graphBGView = UIView()
        graphBGView.frame = CGRect.init(x: 0, y: 250+64+50, width: self.view.frame.width, height: 100)
        self.view.addSubview(graphBGView)
        
        let graphView = ChartGraphView.init(frame: graphBGView.bounds)
        graphView.highestData = [20,16,14,20,66, 39,22,11,56,33, 11,22,33,15,28]
        graphView.lowestData = [10,12,6,5,-7, 9,20,8,33,21, 9,6,8,13,20]
        
        graphView.highPointFillColor = UIColor.orange
        graphView.highLineColor = UIColor.orange
        
        graphView.lowPointFillColor = UIColor.yellow
        graphView.lowLineColor = UIColor.yellow
        graphView.strokeWidth = 1
        
        graphView.hideLabels = false
        graphView.graphWidth = graphView.frame.size.width * 2;
        graphView.hidePoints = false
        graphView.hideLines = false

        graphView.backgroundViewColor = UIColor.clear
        graphView.barColor = UIColor.lightGray.withAlphaComponent(0.3)
        graphView.labelFont = UIFont.systemFont(ofSize: 14)
        graphView.labelFontColor = UIColor.white
        graphView.labelBackgroundColor = UIColor.clear
        
        graphBGView.addSubview(graphView)
        self.view.addSubview(graphBGView)
        
        
        
    }


}

