import SwiftUI

struct ChaseShopView: View {
    
    @Environment(\.presentationMode) var prm
    
    @StateObject var chaseShopManager = ShopManager()
    @State var items: [Item] = [
        Item(id: "background1", type: .background, price: 0, icon: "chase_image"),
        Item(id: "background2", type: .background, price: 100, icon: "chase_image_2"),
        Item(id: "background3", type: .background, price: 100, icon: "chase_image_3"),
        Item(id: "background4", type: .background, price: 100, icon: "chase_image_4"),
        Item(id: "background5", type: .background, price: 100, icon: "chase_image_5"),
        Item(id: "background6", type: .background, price: 100, icon: "chase_image_6"),
        Item(id: "plane1", type: .airplane, price: 0, icon: "plane"),
        Item(id: "plane2", type: .airplane, price: 100, icon: "plane_2"),
        Item(id: "plane3", type: .airplane, price: 100, icon: "plane_3")
    ]
    
    @State var balance = UserDefaults.standard.integer(forKey: "balance") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "balance")
        }
    }
    @State var selectedChase = UserDefaults.standard.string(forKey: "selected_chase") {
        didSet {
            UserDefaults.standard.set(selectedChase, forKey: "selected_chase")
        }
    }
    @State var selectedPlane = UserDefaults.standard.string(forKey: "plane") {
        didSet {
            UserDefaults.standard.set(selectedPlane, forKey: "plane")
        }
    }
    @State var notEnoughtBalanceToBuy = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    prm.wrappedValue.dismiss()
                } label: {
                    Image("back_b")
                        .resizable()
                        .frame(width: 120, height: 80)
                }
                Spacer()
                ZStack {
                    Image("balance")
                        .resizable()
                        .frame(width: 120, height: 80)
                    HStack {
                        Text("\(balance)")
                            .font(.custom("Knewave-Regular", size: 20))
                            .foregroundColor(.white)
                        Image("coin")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
            }
            
            ScrollView {
                ForEach(items, id: \.id) { item in
                    ZStack {
                        Image("shop_item_bg")
                            .resizable()
                            .frame(width: 400, height: 120)
                        HStack {
                            Text("\(item.price)")
                                .font(.custom("Knewave-Regular", size: 32))
                                .foregroundColor(.white)
                            Image("coin")
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text("=")
                                .font(.custom("Knewave-Regular", size: 32))
                                .foregroundColor(.white)
                            
                            Image(item.icon)
                                .resizable()
                                .frame(width: 90, height: 50)
                                .scaledToFit()
                                .background(Color.white)
                                .border(.black)
                                .cornerRadius(12)
                                .padding(.leading)
                        }
                        
                        if (item.type == .background || item.type == .airplane) &&
                            (selectedChase == item.icon || selectedPlane == item.icon){
                            if item.type == .background && selectedChase == item.icon {
                                Image("selected_button")
                                    .resizable()
                                    .frame(width: 70, height: 50)
                                    .offset(x: 160, y: 40)
                            } else if item.type == .airplane && selectedPlane == item.icon {
                                Image("selected_button")
                                    .resizable()
                                    .frame(width: 70, height: 50)
                                    .offset(x: 160, y: 40)
                            }
                        } else {
                            if chaseShopManager.isItemPurchased(item) {
                                Button {
                                    if item.type == .airplane {
                                        selectedPlane = item.icon
                                        print(selectedPlane)
                                    } else {
                                        selectedChase = item.icon
                                        print(selectedChase)
                                    }
                                } label: {
                                    Image("select_button")
                                        .resizable()
                                        .frame(width: 70, height: 50)
                                }
                                .offset(x: 160, y: 40)
                            } else {
                                Button {
                                    if balance >= item.price {
                                        balance -= item.price
                                        chaseShopManager.buyItem(item)
                                    } else {
                                        notEnoughtBalanceToBuy = true
                                    }
                                } label: {
                                    Image("buy_button")
                                        .resizable()
                                        .frame(width: 70, height: 50)
                                }
                                .offset(x: 160, y: 40)
                            }
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            if !chaseShopManager.isItemPurchased(items[0]) {
                chaseShopManager.buyItem(items[0])
                selectedChase = items[0].icon
            }
            if !chaseShopManager.isItemPurchased(items[6]) {
                chaseShopManager.buyItem(items[6])
                selectedPlane = items[6].icon
            }
        }
        .background(
            Image("chase_image")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .alert(isPresented: $notEnoughtBalanceToBuy) {
            Alert(title: Text("Error purchase item"), message: Text("Not enought balance"), dismissButton: .cancel(Text("OK")))
        }
    }
}

#Preview {
    ChaseShopView()
}

enum ItemType: String, Codable {
    case background
    case airplane
}

struct Item: Identifiable, Codable {
    let id: String
    let type: ItemType
    let price: Int
    let icon: String
}
