//
//  Menu.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

typealias Item = (name: String, category: String, price: NSDecimalNumber, showTax: Bool,taxPercent:Double)

typealias Discount = (label: String, amount: Double, ispercent: Bool, isEnabled: Bool,selectedTime:Int)

func category(_ category: String) -> (String, NSDecimalNumber) -> Item {
    return { name, price in
        return (name, category, price, false,0.0)
    }
}

let appetizers = category("Appetizers")
let mains = category("Mains")
let drinks = category("Drinks")
let alcohol = category("Alcohol")

let appetizersCategory = [
    appetizers("Nachos", 13.99),
    appetizers("Calamari", 11.99),
    appetizers("Caesar Salad", 10.99),
]

let mainsCategory = [
    mains("Burger", 9.99),
    mains("Hotdog", 3.99),
    mains("Pizza", 12.99),
]

let drinksCategory = [
    drinks("Water", 0),
    drinks("Pop", 2.00),
    drinks("Orange Juice", 3.00),
]

let alcoholCategory = [
    alcohol("Beer", 5.00),
    alcohol("Cider", 6.00),
    alcohol("Wine", 7.00),
]

// adding an array of applicable category so its easier to scale when more categories needs to be applied to a tax bucket ( also if restaurant wants to change the tax bucket)
let tax1 = (label: "Tax 1 (5%)", amount: 0.05, isEnabled: true, category:["Appetizers"])
let tax2 = (label: "Tax 2 (8%)", amount: 0.08, isEnabled: true, category:["Mains"])
let alcoholTax = (label: "Alcohol Tax (10%)", amount: 0.10, isEnabled: true, category:["Alcohol"])

let discount5Dollars = Discount(label:"$5.00", amount: 5.00,ispercent:false, isEnabled: false,selectedTime:0)
let discount10Percent = Discount(label: "10%", amount: 0.10,ispercent:true, isEnabled: false,selectedTime:0)
let discount20Percent = Discount(label: "20%", amount: 0.20,ispercent:true, isEnabled: false,selectedTime:0)

var taxes = [
    tax1,
    tax2,
    alcoholTax,
]

var discounts = [
    discount5Dollars,
    discount10Percent,
    discount20Percent,
]

var categories = [
    (name: "Appetizers", items: appetizersCategory),
    (name: "Mains", items: mainsCategory),
    (name: "Drinks", items: drinksCategory),
    (name: "Alcohol", items: alcoholCategory),
]

extension Date {

    func toMillis() -> Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
}
