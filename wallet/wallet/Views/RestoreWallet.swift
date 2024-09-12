//
//  RestoreWallet.swift
//  wallet
//
//  Created by Francisco Gindre on 1/23/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Combine
import PirateLightClientKit

struct RestoreWallet: View {
    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var seedPhrase: String = ""
    @State var walletBirthDay: String = ""
    @State var showError = false
    var isValidBirthday: Bool {
        validateBirthday(walletBirthDay)
    }
    
    var isValidSeed: Bool {
        validateSeed(seedPhrase)
    }
    
    func validateBirthday(_ birthday: String) -> Bool {
        
        guard !birthday.isEmpty else {
            return true
        }
        
        guard let b = BlockHeight(birthday) else {
            return false
        }
        
        return b >= ZCASH_NETWORK.constants.saplingActivationHeight
    }
    
    func validateSeed(_ seed: String) -> Bool {
        do {
            try MnemonicSeedProvider.default.isValid(mnemonic: seed)
            return true
        } catch {
            return false
        }
    }
    
    func importBirthday() throws {
        let b = BlockHeight(self.walletBirthDay.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ZCASH_NETWORK.constants.saplingActivationHeight
        try SeedManager.default.importBirthday(b)
    }
    
    func importSeed() throws {
        let trimmedSeedPhrase = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSeedPhrase.isEmpty else {
            throw WalletError.createFailed(underlying: MnemonicError.invalidSeed)
        }
        
        try SeedManager.default.importPhrase(bip39: trimmedSeedPhrase)
    }
    
    var disableProceed: Bool {
        !isValidSeed || !isValidBirthday
    }
    
    @State var proceed: Bool = false
    
    var seedPhraseSubtitle: some View {
        if seedPhrase.isEmpty {
            return Text.subtitle(text: "Make sure nobody is watching you!".localized())
        }
        
        do {
           try MnemonicSeedProvider.default.isValid(mnemonic: seedPhrase)
            return Text.subtitle(text: "Your seed phrase is valid".localized())
        } catch {
            return Text.subtitle(text: "Your seed phrase is invalid!".localized())
                .foregroundColor(.red)
                .bold()
        }
    }
    var body: some View {
        ZStack {
            NavigationLink(destination:
                            LazyView(

                                HomeTabView(openPasscodeScreen: false).navigationBarTitle("", displayMode: .inline)
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true) //.environmentObject(appEnvironment)
//                                    Home().environmentObject(HomeViewModel())

//                                Home(viewModel: ModelFlyWeight.shared.modelBy(defaultValue: HomeViewModel()))

            ), isActive: $proceed) {
                EmptyView()
            }
            
            ZcashBackground()
            
            VStack(spacing: 40) {
                
                ZcashTextField(
                    title: "Enter Your Seed Phrase".localized(),
                    subtitleView: AnyView(
                        seedPhraseSubtitle
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $seedPhrase,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                
                ZcashTextField(
                    title: "Wallet Birthday Height".localized(),
                    subtitleView: AnyView(
                        Text.subtitle(text: "If you don't know, leave it blank. First sync will take longer with default birthday height to be 1390000.".localized())
                    ),
                    keyboardType: UIKeyboardType.decimalPad,
                    binding: $walletBirthDay,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                Spacer()
                Button(action: {
                    do {
                        try self.importSeed()
                        try self.importBirthday()
                        try self.appEnvironment.initialize()
                    } catch {
                        logger.error("\(error)")
                        tracker.track(.error(severity: .critical), properties: [
                            ErrorSeverity.underlyingError : "\(error)"])
                        self.showError = true
                        return
                    }
                    tracker.track(.tap(action: .walletImport), properties: [:])
                    self.proceed = true
                }) {
                    Text("Proceed")
                        .foregroundColor(.black)
                        .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient)))
                }
                .disabled(disableProceed)
                .opacity(disableProceed ? 0.4 : 1.0)
                .frame(height: 58)
            }
            .padding([.horizontal,.top, .bottom], 30)
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Could not restore wallet".localized()),
                  message: Text("There's a problem restoring your wallet. Please verify your seed phrase and try again.".localized()),
                  dismissButton: .default(Text("button_close".localized())))
        }
        .onAppear {
            tracker.track(.screen(screen: .restore), properties: [:])
        }
        .navigationBarTitle("Restore from Seed Phrase".localized(), displayMode: .inline)
        .navigationBarHidden(false)
    }
}

struct RestoreWallet_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWallet().environmentObject(ZECCWalletEnvironment.shared)
    }
}
