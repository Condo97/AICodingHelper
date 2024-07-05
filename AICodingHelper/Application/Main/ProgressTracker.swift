//
//  ProgressTracker.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation


class ProgressTracker: ObservableObject {
    
    @Published var progress: Double? = nil
    @Published var estimatedTimeRemaining: Double? = nil
    @Published private var _totalTasks: Int = 0
    @Published private var _completedTasks: Int = 0
    
    var totalTasks: Int {
        _totalTasks
    }
    
    var completedTasks: Int {
        _completedTasks
    }
    
    public static var maxProgress: Double = 1.0
    
    private var startTime: Date?
    private var lastTaskCompletionTime: Date?
    private var timer: Timer?
    private var smoothedAverageTimePerTask: Double = 0
    private let smoothingFactor: Double = 0.1
    private let timerUpdateInterval: Double = 0.01
    
    func startEstimation(totalTasks: Int) {
        self._totalTasks = totalTasks
        self._completedTasks = 0
        self.progress = nil
        self.estimatedTimeRemaining = nil
        self.startTime = Date()
        self.lastTaskCompletionTime = Date()
        
        // Cancel any existing timer
        self.timer?.invalidate()
        
        // Start new timer if there are tasks to complete
        if totalTasks > 0 {
            let startTimer = Timer.scheduledTimer(withTimeInterval: timerUpdateInterval, repeats: true) { timer in
                self.updateTimer()
            }
            self.timer = startTimer
        }
    }

    func completeTask() {
        guard let startTime = startTime else { return }
        
        let now = Date()
        _completedTasks += 1
        lastTaskCompletionTime = now
        let elapsed = now.timeIntervalSince(startTime)
        let currentAverageTimePerTask = elapsed / Double(completedTasks)
        
        // Apply exponential smoothing
        if completedTasks == 1 {
            smoothedAverageTimePerTask = currentAverageTimePerTask
        } else {
            smoothedAverageTimePerTask = smoothingFactor * currentAverageTimePerTask + (1 - smoothingFactor) * smoothedAverageTimePerTask
        }
        
        estimatedTimeRemaining = smoothedAverageTimePerTask * Double(totalTasks - completedTasks)

        if completedTasks < totalTasks {
            updateProgress()
        } else {
            timer?.invalidate()
            progress = 1.0
        }
    }
    
    private func updateTimer() {
        if let estimatedTimeRemaining = estimatedTimeRemaining, estimatedTimeRemaining > 0 {
            self.estimatedTimeRemaining = max(estimatedTimeRemaining - timerUpdateInterval, 0)
            updateProgress()
        }
    }

    private func updateProgress() {
        if let startTime = startTime, let estimatedTimeRemaining = estimatedTimeRemaining, estimatedTimeRemaining > 0 {
            let elapsedTime = Date().timeIntervalSince(startTime)
            let totalEstimatedTime = elapsedTime + estimatedTimeRemaining
            let newProgress = min(elapsedTime / totalEstimatedTime, 1.0)
            if let progress = progress {
                self.progress = max(progress, newProgress)
            } else {
                self.progress = newProgress
            }
        }
    }

}
