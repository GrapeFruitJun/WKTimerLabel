//
//  ViewController.swift
//  WKTimeLabelDemo
//
//  Created by 吴凯 on 2022/4/14.
//

import UIKit
import WKTimerLabel

class ViewController: UIViewController, WKTimerLabelDelegate {
    
    @IBOutlet weak var timerLabel1: WKTimerLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel1.timerType = .stopwatch
        timerLabel1.delegate = self
        
    }
    
    @IBAction func start1Action(_ sender: Any) {
        
//        if timerLabel1. {
//            
//        } else {
//            timerLabel1.start()
//        }
           
    }
    
    @IBAction func resetAction(_ sender: Any) {
        
        timerLabel1.reset()
    }
    
    func timerLabel(_ timerLabel: WKTimerLabel, finishedCountDownTimerWith countTime: TimeInterval) {
        print(countTime)
    }
    
    func timerLabel(_ timerLabel: WKTimerLabel, countingTo: TimeInterval, timerType: WKTimerLabelType) {
        print(countingTo)
    }
    
    func timerLabel(_ timerLabel: WKTimerLabel, customTextToDisplayAt time: TimeInterval) -> String? {
        nil
    }
    
    func timerLabel(_ timerLabel: WKTimerLabel, customAttributedTextToDisplayAt time: TimeInterval) -> NSAttributedString? {
        nil
    }

}

