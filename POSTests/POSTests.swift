//
//  POSTests.swift
//  POSTests
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
@testable import POS

class POSTests: XCTestCase {

    
    let expectedlabel = [
        "Tax 1 (5%)",
        "Tax 2 (8%)",
        "Alcohol Tax (10%)"
    ]
    var taxModel:TaxViewModel!
    
    override func setUp() {
        taxModel = TaxViewModel()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTaxTitle(){
        XCTAssert(taxModel.title(for: 0) == "Taxes", "Tax Model Title Missmatch")
    }
    
    func testTaxCount(){
           XCTAssert(taxModel.numberOfRows(in: 0) == 3, "Base Tax Clause not available")
       }
    func testAllTaxlabel() {
        for i in 0..<expectedlabel.count {
            testTaxlabel(index: i)
        }
    }
    
    func testTaxlabel(index:Int){
        XCTAssert(taxModel.labelForTax(at: IndexPath(item: index, section: 0)) == expectedlabel[index], "Tax label MisMatch on \(index)")
    }
    func testAccessory() {
        for i in 0..<expectedlabel.count {
            testAccessory(index: i)
        }
    }
    
    func testAccessory(index:Int){
        XCTAssert(taxModel.accessoryType(at: IndexPath(item: index, section: 0)) == .checkmark, "Tax Accessory MisMatch on \(index)")
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
