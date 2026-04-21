//
//  BilditIOSApp.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 19/4/26.
//

import SwiftUI

@main
struct BilditIOSApp: App {
    
    init(){
        _ = DatabaseManager.shared
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
