//
//  FileMonitor.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation


class FileMonitor {
    
    private var streamRef: FSEventStreamRef?
    private let callback: () -> Void
    
    init(paths: [String], callback: @escaping () -> Void) {
        self.callback = callback
        var context = FSEventStreamContext(
            version: 0,
            info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
        streamRef = FSEventStreamCreate(kCFAllocatorDefault,
                                        { (streamRef, contextInfo, numEvents, eventPaths, eventFlags, eventIds) in
                                            let fileMonitor = Unmanaged<FileMonitor>.fromOpaque(contextInfo!).takeUnretainedValue()
                                            fileMonitor.handleEvent()
                                        },
                                        &context,
                                        paths as CFArray,
                                        FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                        0.5,
                                        FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents
                                            | kFSEventStreamCreateFlagUseCFTypes
                                            | kFSEventStreamCreateFlagNoDefer
                                            | kFSEventStreamCreateFlagWatchRoot)
        )
    }
    
    func start() {
        guard let streamRef = streamRef else { return }
        FSEventStreamScheduleWithRunLoop(streamRef, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(streamRef)
    }
    
    func stop() {
        guard let streamRef = streamRef else { return }
        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
    }
    
    private func handleEvent() {
        callback()
    }
    
    deinit {
        stop()
    }
    
}
