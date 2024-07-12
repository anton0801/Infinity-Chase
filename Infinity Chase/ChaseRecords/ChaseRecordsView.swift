import SwiftUI

struct ChaseRecordsView: View {
    
    @Environment(\.presentationMode) var prm
    @StateObject var vm = ChaseRecordsViewModel()
    @State var balance = UserDefaults.standard.integer(forKey: "balance")
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
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
            
            if vm.records.isEmpty {
                Spacer()
                Text("No level has been passed yet, pass the level and see your record.")
                    .font(.custom("Knewave-Regular", size: 24))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 150, trailing: 16))
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                ScrollView {
                    ForEach(vm.records, id: \.levelNum) { record in
                        ZStack {
                            Image("shop_item_bg")
                                .resizable()
                                .frame(width: 400, height: 120)
                            HStack {
                                Text(formatTime(seconds: record.recordTime))
                                    .font(.custom("Knewave-Regular", size: 26))
                                    .foregroundColor(.white)
                                
                                if record.recordTime > 0 {
                                    Spacer()
                                    Text("100")
                                        .font(.custom("Knewave-Regular", size: 15))
                                        .foregroundColor(.white)
                                    Image("coin")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                    Spacer()
                                    Text(formatDate(record.setUpDate))
                                        .font(.custom("Knewave-Regular", size: 20))
                                        .foregroundColor(.white)
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(width: 260, height: 80)
                        }
                    }
                }
            }
        }
        .background(
            Image("chase_image")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    ChaseRecordsView()
}
