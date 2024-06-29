//
//  AICodingHelperWebSocketConnector.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


class AICodingHelperWebSocketConnector {
    
    static func getStream() -> SocketStream {
        WebSocketClient.connect(
            url: URL(string: "\(Constants.Networking.WebSocket.aiCodingHelperWebSocketServer)\(Constants.Networking.WebSocket.Endpoints.getChatStream)")!,
            headers: nil)
    }
    
}
