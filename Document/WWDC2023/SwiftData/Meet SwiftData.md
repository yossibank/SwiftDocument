# Meet SwiftData

## Using the model macro

* **モデルのスキーマ定義**

``` swift
import SwiftData

// 基本的な値型
// Struct, Enum, Codable, Collectionsなどの複雑な型にも対応
@Model
class Trip {
    var name: String
    var destination: String
    var endDate: Date
    var startDate: Date

    var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
}
```

* **Attribute、RelationShip定義**

``` swift
import SwiftData

@Model
class Trip {
    @Attribute(.unique) var name: String
    var destination: String
    var endDate: Date
    var startDate: Date

    @Relationship(.cascade) var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
}
```

## Model container

* **モデルを操作するための2つのオブジェクト(ModelContainer & ModelContext)**

``` swift
import SwiftData

let container = try ModelContainer(
    for: [Trip.self, LivingAccommodation.self],
    configuration: ModelConfiguration(url: URL("path"))
)
```

``` swift
import SwiftData
import SwiftUI

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Trip.self,
            LivingAccommodation.self
        ])
    }
}
```

``` swift
import SwiftData
import SwiftUI

struct ContextView: View {
    @Environment(\.modelContext) private var context
}
```

## Fetch Data

* **predicateの強化**

``` swift
let tripPredicate = #Predicate<Trip> {
    $0.destination == "New York" &&
    $0.name.contains("birthday") &&
    $0.startDate > today
}

let descriptor = FetchDescriptor<Trip>(predicate: tripPredicate)

let trips = try context.fetch(descriptor)
```

* **sortDescriptorの強化**

``` swift
let descriptor = FetchDescriptor<Trip>(
    sortBy: SortDescriptor(\Trip.name)
    predicate: tripPredicate
)

let trips = try context.fetch(descriptor)
```

* **データの操作**

``` swift
var myTrip = Trip(name: "Birthday Trip", destination: "New York")

// ...

context.insert(myTrip) // 作成
context.delete(myTrip) // 削除

try context.save() // データの永続化、変更情報保存
```

## SwiftUIとの親和性

* **Queryを使用したロード、フィルタリング**

``` swift
import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \.startDate, order: .reverse) var trips: [Trip]
    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationStack() {
            List {
                Foreach(trips) { trip in
                    // ...
                }
            }
        }
    }
}
```