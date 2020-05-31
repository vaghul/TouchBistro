//
//  RegisterViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let viewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.dataSource = self
        orderTableView.dataSource = self
        menuTableView.delegate = self
        orderTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissedTaxView), name: .TaxViewDismissed, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissedDiscountView), name: .DiscountViewDismissed, object: nil)
    }
    
    @IBAction func showTaxes() {
        let vc = UINavigationController(rootViewController: TaxViewController(style: .grouped))
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showDiscounts() {
        let vc = UINavigationController(rootViewController: DiscountViewController(style: .grouped))
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @objc func dismissedTaxView(){
        viewModel.resetOrderItems()
        orderTableView.reloadData()
        calculateBill()
    }
    func calculateBill() {
        let billvalue = viewModel.getPriceSheet()
        subtotalLabel.text = billvalue.0
        discountsLabel.text = billvalue.1
        taxLabel.text = billvalue.2
        totalLabel.text = billvalue.3
    }
    @objc func dismissedDiscountView(){
        //viewModel.prepareDiscount()
        orderTableView.reloadData()
        calculateBill()
    }
    
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == menuTableView {
            return viewModel.menuCategoryTitle(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.orderTitle(in: section)
        }
        
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuCategories()
        } else if tableView == orderTableView {
            return 1
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuItems(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.numberOfOrderItems(in: section)
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if tableView == menuTableView {
            cell.textLabel?.text = viewModel.menuItemName(at: indexPath)
            cell.detailTextLabel?.text = viewModel.menuItemPrice(at: indexPath)
            
        } else if tableView == orderTableView {
            cell.textLabel?.text = viewModel.labelForOrderItem(at: indexPath)
            cell.detailTextLabel?.text = viewModel.orderItemPrice(at: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let indexPaths = [viewModel.addItemToOrder(at: indexPath)]
            orderTableView.insertRows(at: indexPaths, with: .automatic)
            // calculate bill totals
            calculateBill()
        } else if tableView == orderTableView {
            viewModel.toggleTaxForOrderItem(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == menuTableView {
            return .none
        } else if tableView == orderTableView {
            return .delete
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == orderTableView && editingStyle == .delete {
            viewModel.removeItemFromOrder(at: indexPath)
            orderTableView.deleteRows(at: [indexPath], with: .automatic)
            // calculate bill totals
            calculateBill()
        }
    }
}


class RegisterViewModel {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var orderItems: [Item] = [] //{
//        willSet {
//            if newValue.count != 0 {
//            let newitem = newValue[0]
//                sumValue += Double(truncating: newitem.price)
//                taxValue +=  (Double(truncating: newitem.price) * newitem.taxPercent)
//            }
//        }
  //  }
    var sumValue:Double = 0.0
    var taxValue:Double = 0.0
    //var arrayDiscount:[Discount] = []
  
    func calculateValues(item:Item) {
        let price = Double(truncating: item.price)
        sumValue += price
        taxValue += (price * item.taxPercent)

    }
    func menuCategoryTitle(in section: Int) -> String? {
        return categories[section].name
    }
    
    func orderTitle(in section: Int) -> String? {
        return "Bill"
    }
    
    func numberOfMenuCategories() -> Int {
        return categories.count
    }
    
    func numberOfMenuItems(in section: Int) -> Int {
        return categories[section].items.count
    }
    
    func numberOfOrderItems(in section: Int) -> Int {
        return orderItems.count
    }
    
    func menuItemName(at indexPath: IndexPath) -> String? {
        return categories[indexPath.section].items[indexPath.row].name
    }
    
    func menuItemPrice(at indexPath: IndexPath) -> String? {
        let price = categories[indexPath.section].items[indexPath.row].price
        return formatter.string(from: price)
    }
    func getPriceSheet() -> (String?,String?,String?,String?) {
        let sum = getCurrency(sumValue)
        let tax = getCurrency(taxValue)
        let discount = getDiscount()
        let discountValue = getCurrency(discount)
        let total = getCurrency(sumValue + taxValue - discount)
        return (sum,discountValue,tax,total)
    }
    // can be used if the order of discount applied would influence the result. Currently its is noticed to be same
//    func prepareDiscount() {
//        arrayDiscount = discounts.filter { (discount) -> Bool in
//            discount.isEnabled
//        }.sorted {
//            $0.selectedTime < $1.selectedTime
//        }
//    }
    
    func getDiscount() -> Double {
        var discountval:Double = 0.0
        discounts.forEach { (discount) in
            if discount.ispercent {
                discountval += sumValue * discount.amount
            }else{
                discountval += discount.amount
            }
        }
        return discountval
    }
    func getCurrency(_ forvalue:Double) -> String? {
        return formatter.string(from: NSNumber(value: forvalue))
    }
    func labelForOrderItem(at indexPath: IndexPath) -> String? {
        let item = orderItems[indexPath.row]
       
        if item.showTax {
            if item.taxPercent == 0.0 {
                return "\(item.name) (No Tax)"
            }else{
                return "\(item.name) \(item.taxPercent*100)%" // added this for visual effect
            }
        } else {
            return "\(item.name)"
        }
    }
    
    func orderItemPrice(at indexPath: IndexPath) -> String? {
        let price = orderItems[indexPath.row].price
        return formatter.string(from: price)
    }
    
    // Assumption if applied
    // Appetizer to have 5%
    // Mains to have 8%
    // Alcohol to have 10 %
    func addItemToOrder(at indexPath: IndexPath) -> IndexPath {
        var item = categories[indexPath.section].items[indexPath.row]
        let arraytax = taxes.filter { (taxobj) -> Bool in
            taxobj.category.contains(item.category)
        }
        item.taxPercent = 0.0
        if arraytax.count != 0 {
            if arraytax[0].isEnabled {
                item.taxPercent = arraytax[0].amount
            }
        }
        calculateValues(item: item)
        orderItems.append(item)
        return IndexPath(row: orderItems.count - 1, section: 0)
    }
    
    func resetOrderItems() {
        
        taxValue = 0.0
        sumValue = 0.0
        for (index,var item) in orderItems.enumerated() {
            let arraytax = taxes.filter { (taxobj) -> Bool in
                taxobj.category.contains(item.category)
            }
            item.taxPercent = 0.0
            if arraytax.count != 0 {
                if arraytax[0].isEnabled {
                    item.taxPercent = arraytax[0].amount
                }
            }
            calculateValues(item:item)
            orderItems[index] = item
        }
        
    }
    
    func removeItemFromOrder(at indexPath: IndexPath) {
        let item = orderItems[indexPath.row]
        sumValue -= Double(truncating: item.price)
        taxValue -= (Double(truncating: item.price) * item.taxPercent)
        orderItems.remove(at: indexPath.row)
    }
    
    func toggleTaxForOrderItem(at indexPath: IndexPath) {
        orderItems[indexPath.row].showTax = !orderItems[indexPath.row].showTax
    }
}


extension Notification.Name {

    static let TaxViewDismissed = Notification.Name("TaxViewDismissed")
    static let DiscountViewDismissed = Notification.Name("DiscountViewDismissed")

}
