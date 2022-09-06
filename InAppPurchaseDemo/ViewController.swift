//
//  ViewController.swift
//  InAppPurchaseDemo
//
//  Created by  on 03/09/22.
//
import StoreKit
import UIKit

class ViewController: UIViewController {
    private var products = [SKProduct]()
    private enum ProductsTypes: String, CaseIterable {
        case removeAds = "com.inapppurchase.removeads"
        case getCoins = "com.inapppurchase.getcoins"
        case premium = "com.inapppurchase.premium"
    }
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        fetchProducts()
    }
    
    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(ProductsTypes.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle): \(product.localizedDescription) - \(product.priceLocale.currencySymbol ?? "") \(product.price)"
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = SKPayment(product: products[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }
}

extension ViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [weak self] in
            self?.products = response.products
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach ({
            switch $0.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                SKPaymentQueue.default().finishTransaction($0)
            case .deferred:
                break
            @unknown default:
                break
            }
        })
    }
}
