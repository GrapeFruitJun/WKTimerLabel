//
//  WKTimerLabel.swift
//  WKTimerLabel
//
//  Created by Justin on 2022/4/15.
//

import Foundation
import UIKit

@objc public enum WKTimerLabelType: Int {
    case stopwatch
    case timer
}

@objc public protocol WKTimerLabelDelegate {
    @objc optional func timerLabel(_ timerLabel: WKTimerLabel, finishedCountDownTimerWith countTime: TimeInterval)
    @objc optional func timerLabel(_ timerLabel: WKTimerLabel, countingTo: TimeInterval, timerType: WKTimerLabelType)
    @objc optional func timerLabel(_ timerLabel: WKTimerLabel, customTextToDisplayAt time: TimeInterval) -> String?
    @objc optional func timerLabel(_ timerLabel: WKTimerLabel, customAttributedTextToDisplayAt time: TimeInterval) -> NSAttributedString?
}

open class WKTimerLabel:UILabel {
    
    private let kHourFormatReplace = "!!!*"
    private let kDefaultFireIntervalNormal = 0.1
    private let kDefaultFireIntervalHighUse = 0.01
    
    private var timeUserValue: TimeInterval = 0
    private var startCountDate: Date? = nil
    private var pausedTime: Date?
    private var date1970 = Date(timeIntervalSince1970: 0)
    
    private var timeToCountOff = Date()
    
    private var timer: Timer?
    lazy private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(identifier: "GMT") //timeZoneWithName
        formatter.dateFormat = self.timeFormat
        return formatter
    }()
    
    private(set) var endedBlock: ((TimeInterval) -> Void)?
    
    public var delegate: WKTimerLabelDelegate?
    
    public var timeFormat = "HH:mm:ss" {
        didSet {
            self.dateFormatter.dateFormat = timeFormat
            self.updateLabel()
        }
    }
    
    public weak var timeLabel: UILabel?
    public var textRange: Range<String.Index>?
    public var attributesForTextInRange: [NSAttributedString.Key: Any]?
    @objc public var timerType: WKTimerLabelType = .timer {
        didSet {
            self.updateLabel()
        }
    }
    public private(set) var counting: Bool = false
    public var resetTimerAfterFinish: Bool = false
    public var shouldCountBeyondHHLimit: Bool = false {
        didSet {
            self.updateLabel()
        }
    }
    
    public init(frame: CGRect = .zero, label: UILabel? = nil, timerType: WKTimerLabelType = WKTimerLabelType.timer) {
        
        super.init(frame: frame)
        if label == nil {
            self.timeLabel = self
        } else {
            self.timeLabel = label
        }
        self.timerType = timerType
        self.updateLabel()
    }
    
    required public init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        self.timeLabel = self
    }
    
    open func start() {
        
        timer?.invalidate()
        timer = nil
        if timeFormat.contains("SS") {
            timer = Timer(timeInterval: kDefaultFireIntervalHighUse, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        } else {
            timer = Timer(timeInterval: kDefaultFireIntervalNormal, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        }
        if let validTimer = timer {
            RunLoop.current.add(validTimer, forMode: .common)
        }
        
        if startCountDate == nil {
            startCountDate = Date()
            if self.timerType == .stopwatch && timeUserValue >= 0 {
                startCountDate = startCountDate?.addingTimeInterval(-1 * timeUserValue)
            }
        }
        if let validPausedTime = pausedTime,
           let validStartCountDate = startCountDate {
            let countedTime = validPausedTime.timeIntervalSince(validStartCountDate)
            startCountDate = Date().addingTimeInterval(-1 * countedTime)
            pausedTime = nil
        }
        counting = true
        timer?.fire()
    }
    
    open func start(with endingBlock: ((TimeInterval) -> Void)?) {
        
        self.endedBlock = endingBlock
        self.start()
    }
    
    open func pause() {
        
        if counting {
            timer?.invalidate()
            timer = nil
            counting = false
            pausedTime = Date()
        }
    }
    
    open func reset() {
        
        pausedTime = nil
        timeUserValue = (self.timerType == .stopwatch) ? 0 : timeUserValue
        startCountDate = self.counting ? Date() : nil
        self.updateLabel()
    }
    
    open func addTimeCounted(by time: TimeInterval) {
        
        if timerType == .timer {
            
            self.setCountDown(time: time + timeUserValue)
            
        } else if timerType == .stopwatch,let newStartDate = startCountDate?.addingTimeInterval(-1 * time) {
            
            if Date().timeIntervalSince(newStartDate) <= 0 {
                startCountDate = Date()
            } else {
                startCountDate = newStartDate
            }
            
        }
        self.updateLabel()
    }
    
    open func getTimeCounted() -> TimeInterval {
        
        guard let validStartCountDate = startCountDate else {
            return 0
        }
        var countedTime = Date().timeIntervalSince(validStartCountDate)
        if let validPausedTime = pausedTime {
            let pauseCountedTime = Date().timeIntervalSince(validPausedTime)
            countedTime -= pauseCountedTime
        }
        return countedTime
    }
    
    open func getTimeRemaining() -> TimeInterval {
        
        if timerType == .timer {
            return (timeUserValue - self.getTimeCounted())
        }
        return 0
    }
    
    open func getCountDownTime() -> TimeInterval {
        
        if timerType == .timer {
            return timeUserValue
        }
        return 0
    }
    
    open override func removeFromSuperview() {
        
        timer?.invalidate()
        timer = nil
        super.removeFromSuperview()
    }
    
    open func setStopWatch(time: TimeInterval) {
        
        self.timeUserValue = (time < 0) ? 0 : time
        if timeUserValue > 0 {
            self.startCountDate = Date().addingTimeInterval(-1 * timeUserValue)
            self.pausedTime = Date()
            self.updateLabel()
        }
        
    }
    
    open func setCountDown(time: TimeInterval) {
        
        self.timeUserValue = (time < 0) ? 0 : time
        timeToCountOff = date1970.addingTimeInterval(timeUserValue)
        self.updateLabel()
    }
    
    open func setCountDownTo(date: Date) {
        
        let timeLeft = date.timeIntervalSince(Date())
        if timeLeft > 0 {
            self.timeUserValue = timeLeft
            self.timeToCountOff = date1970.addingTimeInterval(timeLeft)
        } else {
            self.timeUserValue = 0
            self.timeToCountOff = date1970.addingTimeInterval(0)
        }
        self.updateLabel()
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
}

extension WKTimerLabel {
    
    @objc
    open func updateLabel() {
        
        var timeDiff: TimeInterval = 0
        if let startDate = startCountDate {
            timeDiff = Date().timeIntervalSince(startDate)
        }
        var timeToShow = Date()
        var timerEnded = false
        
        if timerType == .stopwatch {
            
            if counting {
                
                timeToShow = date1970.addingTimeInterval(timeDiff)
            } else {
                
                if let _ = startCountDate {
                    timeToShow = date1970.addingTimeInterval(timeDiff)
                } else {
                    timeToShow = date1970.addingTimeInterval(0)
                }
            }

            delegate?.timerLabel?(self, countingTo: timeDiff, timerType: timerType)
            
        } else {
            
            if counting {
                let timeLeft = timeUserValue - timeDiff
                delegate?.timerLabel?(self, countingTo: timeLeft, timerType: timerType)
                if timeDiff >= timeUserValue {
                    self.pause()
                    timeToShow = date1970.addingTimeInterval(0)
                    startCountDate = nil
                    timerEnded = true
                } else {
                    timeToShow = timeToCountOff.addingTimeInterval(timeDiff * -1) //added 0.999 to make it actually counting the whole first second
                }
            } else {
                timeToShow = timeToCountOff
            }
            
        }
        
        let atTime = timerType == .stopwatch ? timeDiff : ((timeUserValue - timeDiff) < 0 ? 0 : (timeUserValue - timeDiff))
        if delegate?.timerLabel?(self, customTextToDisplayAt: atTime) != nil {
            
            if let customText = delegate?.timerLabel?(self, customTextToDisplayAt: atTime), !customText.isEmpty {
                self.timeLabel?.text = customText
            } else {
                self.timeLabel?.text = self.dateFormatter.string(from: timeToShow)
            }
            
        } else if delegate?.timerLabel?(self, customAttributedTextToDisplayAt: atTime) != nil {
            
            let atTime = timerType == .stopwatch ? timeDiff : ((timeUserValue - timeDiff) < 0 ? 0 : (timeUserValue - timeDiff))
            if let customText = delegate?.timerLabel?(self, customAttributedTextToDisplayAt: atTime),
               !customText.string.isEmpty {
                self.timeLabel?.attributedText = customText
            } else {
                self.timeLabel?.text = self.dateFormatter.string(from: timeToShow)
            }
            
        } else {
            
            if shouldCountBeyondHHLimit {
                
                var beyondFormat = String(timeFormat)
                beyondFormat = beyondFormat.replacingOccurrences(of: "HH", with: kHourFormatReplace)
                beyondFormat = beyondFormat.replacingOccurrences(of: "H", with: kHourFormatReplace)
                self.dateFormatter.dateFormat = beyondFormat
                let hours = (timerType == .stopwatch) ? self.getTimeCounted() / 3600 : self.getTimeRemaining() / 3600
                let formattedDate = self.dateFormatter.string(from: timeToShow)
                let beyondedDate = formattedDate.replacingOccurrences(of: kHourFormatReplace, with: String(format: "%02.0f", hours))
                self.timeLabel?.text = beyondedDate
                self.dateFormatter.dateFormat = timeFormat
                
            } else {
                
                if let validRange = textRange, !validRange.isEmpty {
                    
                    if let attributes = self.attributesForTextInRange,!attributes.isEmpty {
                        
                        let attrTextInRange = NSAttributedString(string: self.dateFormatter.string(from: timeToShow), attributes: attributes)
                        let attributedString = NSMutableAttributedString(string: self.text ?? "")
                        let nsRange = NSRange(validRange, in: self.text ?? "")
                        
                        attributedString.replaceCharacters(in: nsRange, with: attrTextInRange)
                        self.timeLabel?.attributedText = attributedString
                        
                    } else {
                        
                        let labelText = self.text?.replacingCharacters(in: validRange, with: self.dateFormatter.string(from: timeToShow))
                        self.timeLabel?.text = labelText
                        
                    }
                    
                } else {
                    
                    self.timeLabel?.text = self.dateFormatter.string(from: timeToShow)
                }
            }
        }
        
        if timerEnded {
            
            delegate?.timerLabel?(self, finishedCountDownTimerWith: timeUserValue)
            
            self.endedBlock?(timeUserValue)
            if resetTimerAfterFinish {
                self.reset()
            }
        }
        
    }
    
}


