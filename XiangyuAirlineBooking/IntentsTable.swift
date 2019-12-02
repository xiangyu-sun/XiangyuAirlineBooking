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
    let showReservationPub = NotificationCenter.default.publisher(for: .showReservation)
    let startReservationCheckInPub = NotificationCenter.default.publisher(for: .startReservationCheckIn)
    
    @State var reservationContainers = [INSpeakableString]()
    fileprivate var showReservationNotificationToken: NSObjectProtocol?
    fileprivate var startCheckInNotificationToken: NSObjectProtocol?
    
    @State var showCheckAlert = false
    @State var bookingNumber: String?
    
    @State var reservationItemReferences: [INSpeakableString]?
    @State var reservationContainerReference: INSpeakableString?
    @State var singleReservation: Bool = false
    @State var containerReservations: Bool = false
    @State var reservation: INReservation?
    @State var reservations:[INReservation]?
    
    var body: some View {
        NavigationView {
            List(reservationContainers, id: \.self) { reservationContainer in
                
                NavigationLink(destination: self.buildCell(reservationContainer: reservationContainer)){
                    Text(reservationContainer.spokenPhrase)
                }
                // The app was launched with an reservationItemReferences array containing a single reservation, indicating it should
                // show a single reservation.
                if self.singleReservation {
                    NavigationLink(destination: ReservationDetailView(reservationContainerReference: self.reservationItemReferences?.first, reservation: self.reservation), isActive: self.$singleReservation) {
                        EmptyView()
                    }
                }
                if self.containerReservations {
                    NavigationLink(destination: ReservationsListView(reservationContainerReference: self.reservationContainerReference, reservations: self.reservations ?? []), isActive: self.$containerReservations) {
                        EmptyView()
                    }
                }
                
            }
        }
        .onAppear(perform: {
            let server = Server.sharedInstance
            self.reservationContainers = server.reservationContainers()
        })
        .alert(isPresented: $showCheckAlert) {
                Alert(title: Text("Check in for \(bookingNumber ?? "")"), message: Text("Start check-in flow"), dismissButton: .cancel())
        }.navigationBarItems(trailing: Button(action: {
            INInteraction.deleteAll(completion: nil)
        }, label: {Text("Clear")}))
            .onReceive(showReservationPub) { (notification) in
                guard let userActivity = notification.object as? NSUserActivity else {
                    return
                }
                self.handleShowReservationNotification(withUserActivity: userActivity)
        }.onReceive(startReservationCheckInPub) { (notification) in
            guard let userActivity = notification.object as? NSUserActivity else {
                return
            }
            if let userInfo = userActivity.userInfo {
                if let bookingNumber = userInfo["bookingNumber"] as? String{
                    //self.navigationController?.popToRootViewController(animated: false)
                    self.bookingNumber = bookingNumber
                    self.showCheckAlert = true
                }
            }
        }
    }
    
    fileprivate func handleShowReservationNotification(withUserActivity userActivity: NSUserActivity) {
        guard let intent = userActivity.interaction?.intent as? INGetReservationDetailsIntent else {
            return
        }
        
        guard let reservationItemReferences = intent.reservationItemReferences else {
            return
        }
        
        self.reservationItemReferences = reservationItemReferences
        singleReservation = false
        containerReservations = false
        
        if reservationItemReferences.count == 1, let reservationItemReference = reservationItemReferences.first {
            guard let reservation = Server.sharedInstance.reservation(withItemReference: reservationItemReference) else {
                singleReservation = false
                return
            }
            self.reservation = reservation
        }
            
        else if let reservationContainerReference = intent.reservationContainerReference {
            guard let reservations = Server.sharedInstance.reservations(inReservationContainer: reservationContainerReference) else {
                return
            }
            self.reservations = reservations
            containerReservations = true
        }
    }
    
    func buildCell(reservationContainer: INSpeakableString) ->  some View {
        
        if let reservations = Server.sharedInstance.reservations(inReservationContainer: reservationContainer) {
            
            if reservations.count == 1,
                let firstReservation = reservations.first,
                firstReservation.itemReference == reservationContainer {
                // This is a single reservation, show it.
                return AnyView(ReservationDetailView(reservationContainerReference: reservationContainer, reservation: firstReservation as INReservation?))
            }else {
                return AnyView(ReservationsListView(reservationContainerReference: reservationContainer, reservations: reservations))
            }
        }
        
        return AnyView(EmptyView())
    }
    
}

struct IntentsTable_Previews: PreviewProvider {
    static var previews: some View {
        IntentsTable()
    }
}
