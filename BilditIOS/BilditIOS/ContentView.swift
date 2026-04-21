//
//  ContentView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 19/4/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            LoginView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
