import Foundation
import Combine

class ShopManager: ObservableObject {
    static let shared = ShopManager()
    
    @Published private(set) var purchasedItems: [Item] = []
    
    private let purchasedItemsKey = "PurchasedItems"
    
    init() {
        self.purchasedItems = getPurchasedItems()
    }
    
    func buyItem(_ item: Item) {
        if !isItemPurchased(item) {
            purchasedItems.append(item)
            savePurchasedItems(purchasedItems)
        }
    }
    
    func isItemPurchased(_ item: Item) -> Bool {
        return purchasedItems.contains(where: { $0.id == item.id })
    }
    
    private func getPurchasedItems() -> [Item] {
        guard let data = UserDefaults.standard.data(forKey: purchasedItemsKey) else {
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([Item].self, from: data)
            return items
        } catch {
            print("Failed to decode items: \(error.localizedDescription)")
            return []
        }
    }
    
    private func savePurchasedItems(_ items: [Item]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: purchasedItemsKey)
        } catch {
            print("Failed to encode items: \(error.localizedDescription)")
        }
    }
    
}
