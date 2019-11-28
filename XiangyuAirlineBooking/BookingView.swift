//
//  BookingView.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 26/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import SwiftUI

struct BookingView: View {
    @State private var departure: String = ""
    @State private var arrival: String = ""
    
    @State private var departureDate = Date()
    @State private var arrivalDate = Date()
    
    private var airports = ["DXB", "LHR", "CAN"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $departure, label: Text("Departure Airport")) {
                        ForEach(self.airports, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker(selection: $arrival, label: Text("Arrival Airport")) {
                        ForEach(self.airports, id: \.self) {
                            Text($0)
                        }
                    }
                }
                Section {
                    DatePicker(selection: $departureDate, displayedComponents: .date, label: { Text("Departure Date") })
                    DatePicker(selection: $arrivalDate, displayedComponents: .date, label: { Text("Arrival Date") })
                }
                Section {
                    Button("Confirm", action: {
                        
                    }).font(.title)
                }
            }.navigationBarTitle(Text("Xiangyu Air"))
        }
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
    }
}
