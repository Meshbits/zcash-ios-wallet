//
//  NullBytesTests.swift
//  PirateLightClientKit-Unit-Tests
//
//  Created by Francisco Gindre on 6/5/20.
//

import XCTest
@testable import TestUtils
@testable import PirateLightClientKit

class NullBytesTests: XCTestCase {
    let networkType = NetworkType.mainnet

    func testZaddrNullBytes() throws {
        // this is a valid zAddr. if you send ARRR to it, you will be contributing to Human Rights Foundation. see more ways to help at https://paywithz.cash/
        let validZaddr = "zs1gqtfu59z20s9t20mxlxj86zpw6p69l0ev98uxrmlykf2nchj2dw8ny5e0l22kwmld2afc37gkfp"
        let zAddrWithNullBytes = "\(validZaddr)\0something else that makes the address invalid"
        
        XCTAssertFalse(DerivationTool(networkType: networkType).isValidSaplingAddress(zAddrWithNullBytes))
    }

    func testTaddrNullBytes() throws {
        // this is a valid tAddr. if you send ARRR to it, you will be contributing to Human Rights Foundation. see more ways to help at https://paywithz.cash/
        let validTAddr = "t1J5pTRzJi7j8Xw9VJTrPxPEkaigr69gKVT"
        let tAddrWithNullBytes = "\(validTAddr)\0fasdfasdf"

        XCTAssertFalse(DerivationTool(networkType: networkType).isValidTransparentAddress(tAddrWithNullBytes))
    }
    
    func testInitAccountTableNullBytes() async throws {
        let wrongHash = "000000000\015c597fab53f\058b9e1ededbe8bd83ca0203788e2039eceeb0d65ca6"
        let goodHash = "00000000015c597fab53f58b9e1ededbe8bd83ca0203788e2039eceeb0d65ca6"
        let time: UInt32 = 1582235356
        let height: Int32 = 735000

        let wrongTree = """
        0161f2ff97ff6ac6a90f9bce76c11710460f4944d8695aecc7dc99e34cad0131040011015325b185e23e82562db27817be996ffade9597181244f67efc40561aeb9dde1101dae\
        ffadc9e38f755bcb55a847a1278518a0ba4a2ef33b2fe01bbb3eb242ab0070000000000011c51f9077e3f7e28e8e337eaf4bb99b41acbc853a37dcc1e172467a1c919fe410001\
        0bb1f55481b2268ef31997dc0fb6b48a530bc17870220f156d832326c433eb0a010b3768d3bf7868a67823e022f49be67982d0588e7041c498a756024\0750065a4a0001a9e1b\
        f4bccb48b14b544e770f21d48f2d3ad8d6ca54eccc92f60634e3078eb48013a1f7fb005388ac6f04099b647ed85d8b025d8ae4b178c2376b473b121b8c052000001d2ea556f49\
        fb934dc76f087935a5c07788000b4e3aae24883adfec51b5f4d260
        """

        let goodTree = """
        0161f2ff97ff6ac6a90f9bce76c11710460f4944d8695aecc7dc99e34cad0131040011015325b185e23e82562db27817be996ffade9597181244f67efc40561aeb9dde1101dae\
        ffadc9e38f755bcb55a847a1278518a0ba4a2ef33b2fe01bbb3eb242ab0070000000000011c51f9077e3f7e28e8e337eaf4bb99b41acbc853a37dcc1e172467a1c919fe410001\
        0bb1f55481b2268ef31997dc0fb6b48a530bc17870220f156d832326c433eb0a010b3768d3bf7868a67823e022f49be67982d0588e7041c498a756024750065a4a0001a9e1bf4\
        bccb48b14b544e770f21d48f2d3ad8d6ca54eccc92f60634e3078eb48013a1f7fb005388ac6f04099b647ed85d8b025d8ae4b178c2376b473b121b8c052000001d2ea556f49fb\
        934dc76f087935a5c07788000b4e3aae24883adfec51b5f4d260
        """

        let rustBackend = ZcashRustBackend.makeForTests(
            dbData: try! __dataDbURL(),
            fsBlockDbRoot: Environment.uniqueTestTempDirectory,
            networkType: networkType
        )

        do {
            _ = try await rustBackend.initBlocksTable(
                height: height,
                hash: wrongHash,
                time: time,
                saplingTree: goodTree
            )
            XCTFail("InitBlocksTable with Null bytes on hash string should have failed")
        } catch {
            guard let rustError = error as? ZcashError else {
                XCTFail("Expected ZcashError")
                return
            }

            if rustError.code != .rustInitBlocksTableHashContainsNullBytes {
                XCTFail("expected error code \(ZcashError.rustInitBlocksTableHashContainsNullBytes.code.rawValue) and got error \(rustError)")
            }
        }

        do {
            try await rustBackend.initBlocksTable(
                height: height,
                hash: goodHash,
                time: time,
                saplingTree: wrongTree
            )
            XCTFail("InitBlocksTable with Null bytes on saplingTree string should have failed")
        } catch {
            guard let rustError = error as? ZcashError else {
                XCTFail("Expected ZcashError")
                return
            }

            if rustError.code != .rustInitBlocksTableSaplingTreeContainsNullBytes {
                XCTFail("expected error code \(ZcashError.rustInitBlocksTableSaplingTreeContainsNullBytes.code.rawValue) and got error \(rustError)")
            }
        }
    }
    
    // TODO: [#716] fix, https://github.com/zcash/PirateLightClientKit/issues/716
    func testderiveExtendedFullViewingKeyWithNullBytes() throws {
//        let wrongSpendingKeys = SaplingExtendedSpendingKey(validatedEncoding: "secret-extended-key-main1qw28psv0qqqqpqr2ru0kss5equx6h0xjsuk5299xrsgdqnhe0cknkl8uqff34prwkyuegyhh5d4rdr8025nl7e0hm8r2txx3fuea5mq\0uy3wnsr9tlajsg4wwvw0xcfk8357k4h850rgj72kt4rx3fjdz99zs9f4neda35cq8tn3848yyvlg4w38gx75cyv9jdpve77x9eq6rtl6d9qyh8det4edevlnc70tg5kse670x50764gzhy60dta0yv3wsd4fsuaz686lgszc7nc9vv") // this spending key corresponds to the "demo app reference seed"
//
//        let goodSpendingKeys = SaplingExtendedSpendingKey(validatedEncoding: "secret-extended-key-main1qw28psv0qqqqpqr2ru0kss5equx6h0xjsuk5299xrsgdqnhe0cknkl8uqff34prwkyuegyhh5d4rdr8025nl7e0hm8r2txx3fuea5mquy3wnsr9tlajsg4wwvw0xcfk8357k4h850rgj72kt4rx3fjdz99zs9f4neda35cq8tn3848yyvlg4w38gx75cyv9jdpve77x9eq6rtl6d9qyh8det4edevlnc70tg5kse670x50764gzhy60dta0yv3wsd4fsuaz686lgszc7nc9vv")
//
//        XCTAssertThrowsError(
//            try DerivationTool(networkType: networkType)deriveSaplingExtendedFullViewingKey(wrongSpendingKeys, networkType: networkType),
//            "Should have thrown an error but didn't! this is dangerous!"
//        ) { error in
//            guard let rustError = error as? RustWeldingError else {
//                XCTFail("Expected RustWeldingError")
//                return
//            }
//
//            switch rustError {
//            case .malformedStringInput:
//                XCTAssertTrue(true)
//            default:
//                XCTFail("expected \(RustWeldingError.malformedStringInput) and got \(rustError)")
//            }
//        }
//
//        XCTAssertNoThrow(try DerivationTool(networkType: networkType)deriveSaplingExtendedFullViewingKey(goodSpendingKeys, networkType: networkType))
    }
    
    func testCheckNullBytes() throws {
        // this is a valid zAddr. if you send ARRR to it, you will be contributing to Human Rights Foundation. see more ways to help at https://paywithz.cash/
        let validZaddr = "zs1gqtfu59z20s9t20mxlxj86zpw6p69l0ev98uxrmlykf2nchj2dw8ny5e0l22kwmld2afc37gkfp"

        XCTAssertFalse(validZaddr.containsCStringNullBytesBeforeStringEnding())
        XCTAssertTrue(
            "zs1gqtfu59z20s\u{0}9t20mxlxj86zpw6p69l0ev98uxrmlykf2nchj2dw8ny5e0l22kwmld2afc37gkfp"
                .containsCStringNullBytesBeforeStringEnding()
        )
        XCTAssertTrue("\u{0}".containsCStringNullBytesBeforeStringEnding())
        XCTAssertFalse("".containsCStringNullBytesBeforeStringEnding())
    }

    func testTrimTrailingNullBytes() throws {
        let nullTrailedString = "This Is a memo with text and trailing null bytes\u{0}\u{0}\u{0}\u{0}\u{0}\u{0}\u{0}"

        let nonNullTrailedString = "This Is a memo with text and trailing null bytes"

        let trimmedString = String(nullTrailedString.reversed().drop(while: { $0 == "\u{0}" }).reversed())

        XCTAssertEqual(trimmedString, nonNullTrailedString)
    }
}