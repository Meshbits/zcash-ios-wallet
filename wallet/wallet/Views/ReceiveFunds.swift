//
//  ReceiveFunds.swift
//  wallet
//
//  Created by Francisco Gindre on 1/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ZcashLightClientKit
struct ReceiveFunds: View {
    
    let unifiedAddress: UnifiedAddress
//    @Environment(\.presentationMode) var presentationMode
    @State var selectedTab: Int = 0
    @State var qrImage : Image?
    var body: some View {
        NavigationView {
            
            ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 10, content: {
                    DisplayAddress(address: unifiedAddress.zAddress,
                                   title: "address_shielded".localized(),
                                   badge: Image("skullcoin"),
                                   qrImage: qrImage  ?? Image("QrCode"),
                                   accessoryContent: { EmptyView() })
                        
                })
            }.zcashNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                    Text("receive_title".localized())
                         .font(.barlowRegular(size: 26)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center).padding(.top,40)
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
//                     presentationMode.wrappedValue.dismiss()
                         if UIApplication.shared.windows.count > 0 {
                             UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: nil)
                         }
                     }).frame(width: 30, height: 30).padding(.top,40)
             })
            .onAppear {
                tracker.track(.screen(screen: .receive), properties: [:])
            }
            .navigationBarHidden(true)
//            .navigationBarTitle(Text("receive_title"),
//                                           displayMode: .inline)                       
//                       .navigationBarItems(trailing: ZcashCloseButton(action: {
//                           tracker.track(.tap(action: .receiveBack), properties: [:])
//                           presentationMode.wrappedValue.dismiss()
//                           }).frame(width: 30, height: 30))
        }
    }
}
