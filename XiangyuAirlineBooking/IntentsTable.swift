//
//  IntentsTable.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 27/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import SwiftUI
import Intents

struct IntentsTable: View {
    var reservationContainers = [INSpeakableString]()
    fileprivate var showReservationNotificationToken: NSObjectProtocol?
    fileprivate var startCheckInNotificationToken: NSObjectProtocol?
    @EnvironmentObject var activityHandler: ActivityHandler

    
    var body: some View {
        List {
            Text("Text")
            
            // The app was launched with an reservationItemReferences array containing a single reservation, indicating it should
            // show a single reservation.
            if activityHandler.singleReservation {
                NavigationLink(destination: ReservationDetailView(reservationContainerReference: activityHandler.reservationItemReferences?.first, reservation: activityHandler.reservation), isActive: $activityHandler.singleReservation) {
                    EmptyView()
                }
            } else if activityHandler.containerReservations {
                NavigationLink(destination: ReservationsListView(reservationContainerReference: activityHandler.reservationContainerReference, reservations: activityHandler.reservations ?? []), isActive: $activityHandler.singleReservation) {
                    EmptyView()
                }
            }
     
        }.alert(isPresented: $activityHandler.showCheckAlert) {
            Alert(title: Text("Check in for \(activityHandler.bookingNumber ?? "")"), message: Text("Start check-in flow"), dismissButton: .cancel())
        }
    }

}

struct IntentsTable_Previews: PreviewProvider {
    static var previews: some View {
        IntentsTable().environmentObject(ActivityHandler())
    }
}
