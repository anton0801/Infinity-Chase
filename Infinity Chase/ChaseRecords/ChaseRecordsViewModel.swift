import Foundation
import Combine

struct RecordItem: Identifiable, Codable {
    let id = UUID()
    var levelNum: Int
    var recordTime: Int
    var setUpDate: Date
}

class ChaseRecordsViewModel: ObservableObject {
    @Published private(set) var records: [RecordItem] = []
    
    private let recordsKey = "GameRecords"
    
    init() {
        self.records = getRecords()
    }
    
    func addRecord(_ record: RecordItem) {
        records.append(record)
        saveRecords(records)
    }
    
    func updateRecord(_ levelNum: Int, newRecordTime: Int) {
       if let index = records.firstIndex(where: { $0.levelNum == levelNum }) {
           records[index] = RecordItem(levelNum: levelNum, recordTime: newRecordTime, setUpDate: Date())
           saveRecords(records)
       }
   }
    
    func getLastRecordItem() -> RecordItem? {
        return records.sorted(by: { $0.setUpDate < $1.setUpDate }).last
    }
    
    private func getRecords() -> [RecordItem] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey) else {
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([RecordItem].self, from: data)
            return items
        } catch {
            return []
        }
    }
    
    private func saveRecords(_ items: [RecordItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: recordsKey)
        } catch {
        }
    }
}
