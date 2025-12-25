//
//  Race_SimulatorApp.swift
//  Race Simulator
//
//  Created by Batuhan KANDIRAN on 13.03.2025.
//

import SwiftUI

@main
struct Race_SimulatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
