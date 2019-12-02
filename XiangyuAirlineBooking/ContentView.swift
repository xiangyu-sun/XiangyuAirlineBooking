//
//  ContentView.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 26/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    enum Tab {
        case intents, booking
    }
    
    @State private var selection: Tab = .intents

    var body: some View {
        TabView(selection: $selection){
            IntentsTable().tabItem{Text("Intents")}.tag(Tab.intents)
            BookingView().tabItem{Text("Booking")}.tag(Tab.booking)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
