//
//  InitiateRecoveryKeyPhraseFlow.swift
//  ECC-Wallet
//
//  Created by Lokesh Sehgal on 11/09/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct InitiateRecoveryKeyPhraseFlow: View {
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var initiateRecoveryPhrase = false
    
    var body: some View {
        ZStack{
                ARRRBackground()
                VStack(alignment: .center, content: {
                    Spacer(minLength: 10)
                    Text("Write down your key again").padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).font(.barlowRegular(size: Device.isLarge ? 36 : 28)).padding(.top,80)
                    Text("Last written down on ").padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).font(.barlowRegular(size: Device.isLarge ? 16 : 10))
                    Spacer(minLength: 10)
                    Image("hook")
                        .padding(.trailing,80).padding(.leading,80)
                    
                    Spacer(minLength: 10)
                    Button {
                        initiateRecoveryPhrase = true
                       
                    } label: {
                        BlueButtonView(aTitle: "Continue")
                    }
                    
                    
//                   NavigationLink(
//
//                       destination: LazyView(PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .validateAndDismiss, isNewWallet: true)).environmentObject(self.appEnvironment),
//                        isActive: $initiateRecoveryPhrase
//                   ) {
//                       EmptyView()
//                   }
                    
                    NavigationLink(
                        destination: RecoveryWordsView().environmentObject(RecoveryWordsViewModel()).navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                        isActive: $initiateRecoveryPhrase
                    ) {
                        EmptyView()
                    }
//
                    Spacer(minLength: 10)
                })
            
            
            }.edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack(alignment: .leading) {
                ZStack{
                    Image("passcodenumericbg")
                    Text("<").foregroundColor(.gray).bold().multilineTextAlignment(.center).font(
                        .barlowRegular(size: Device.isLarge ? 26 : 18)
                    ).padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
                }
            }.padding(.leading,-20).padding(.top,10)
        })
       
    }
}

struct InitiateRecoveryKeyPhraseFlow_Previews: PreviewProvider {
    static var previews: some View {
        InitiateRecoveryKeyPhraseFlow()
    }
}
