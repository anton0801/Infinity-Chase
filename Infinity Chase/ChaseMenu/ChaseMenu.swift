import SwiftUI

struct ChaseMenu: View {
    
    @State var toGame = false
    @State var toShop = false
    @State var toRecords = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                Button {
                    toGame = true
                } label: {
                    Image("chase_game")
                        .resizable()
                        .frame(width: 300, height: 120)
                }
                Button {
                    toShop = true
                } label: {
                    Image("chase_shop")
                        .resizable()
                        .frame(width: 300, height: 120)
                }
                Button {
                    toRecords = true
                } label: {
                    Image("chase_records")
                        .resizable()
                        .frame(width: 300, height: 120)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("chase_sound")
                            .resizable()
                            .frame(width: 100, height: 80)
                    }
                }
                
                NavigationLink(destination: ChaseGameView()
                    .navigationBarBackButtonHidden(true), isActive: $toGame) {
                    
                }
                NavigationLink(destination: ChaseShopView()
                    .navigationBarBackButtonHidden(true), isActive: $toShop) {
                    
                }
                NavigationLink(destination: ChaseRecordsView()
                    .navigationBarBackButtonHidden(true), isActive: $toRecords) {
                    
                }
            }
            .onAppear {
                ApplicationOrigentationChecker.orientationLock = .portrait
            }
            .background(
                Image("chase_image")
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width,
                           minHeight: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            )
            .onAppear {
                if !UserDefaults.standard.bool(forKey: "sadafa") {
                    UserDefaults.standard.set("chase_image", forKey: "selected_chase")
                    UserDefaults.standard.set("plane", forKey: "plane")
                    UserDefaults.standard.set(true, forKey: "sadafa")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ChaseMenu()
}
