//
//  WebSocketClient.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


class WebSocketClient {
    
    static func connect(url: URL, headers: [String: String]?) -> SocketStream {
        var urlRequest = URLRequest(url: url)
        
        headers?.forEach({k, v in
            urlRequest.addValue(v, forHTTPHeaderField: k)
        })
        
        let socketConnection = URLSession.shared.webSocketTask(with: urlRequest)
        
        return SocketStream(task: socketConnection)
    }
    
}
