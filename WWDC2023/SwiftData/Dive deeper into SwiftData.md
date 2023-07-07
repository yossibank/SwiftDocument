# Dive deeper into SwiftData

## Configuring persistence

* **Model**
  * 既存のクラスや構造体の型と一緒に動作する設計
  * マクロである@Modelによって記述され、永続化したい型をSwiftDataに伝える
    * Schemaと呼ばれるアプリケーションのオブジェクトグラフを記述する
    * コードを書くためのインターフェースとなる
  * SwiftDataが使用したい構造を自動的に推測する

``` swift
// before
class Trip {
    var destination: String?
    var end_date: Date?
    var name: String?
    var start_date: Date?
    var bucketListItem: [BucketListItem] = [BucketListItem]()
    var livingAccommodations: LivingAccommodations?
}

// after
@Model
final class Trip {
    var destination: String?
    var end_date: Date?
    var name: String?
    var start_date: Date?
    @Relationship(.cascade)
    var bucketListItem: [BucketListItem] = [BucketListItem]()
    @Relationship(.cascade)
    var livingAccommodations: LivingAccommodations?
}
```

* **Schema**
  * ModelContainerに適用され、データがどのように永続化されるかを記述する

* **ModelContainer**
  * Schemaと永続化の間に立つ橋渡し役
  * Schemaを消費して、Modelクラスのインスタンスを保持するデータベースを作成する

``` swift
let container = try ModelContainer(for: Trip.self)

// 実際には自動的に関連したModel型まで推論される
let container = try ModelContainer(for: [
    Trip.self,
    BucketListItem.self,
    LivingAccommodation.self
])
```

``` swift
// SwiftUIでのコンテナ生成
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
    }
}
```

* **ModelConfiguration**
  * Schemaの永続性を記述する
    * 一過性のデータはメモリに、永続的なデータはディスクに保存する制御を設定できる
    * ユーザーが選択した特定のファイルURLに設定できる
    * 読み取り専用モードの設定
    * CouldKitコンテナ使用の設定

``` swift
// スキーマの生成
let fullSchema = Schema([
    Trip.self,
    BucketListItem.self,
    LivingAccommodation.self,
    Person.self,
    Address.self
])

// ModelConfigurationの生成(Trip)
let trips = ModelConfiguration(
    schema: Schema([
        Trip.self,
        BucketListItem.self,
        LivingAccommodations.self
    ]),
    url: URL(filePath: "/path/to/trip.store"),
    couldKitContainerIdentifier: "com.example.trips"
)

// ModelConfigurationの生成(People)
let people = ModelConfiguration(
    schema: Schema([
        Person.self,
        Address.self
    ]),
    url: URL(filePath: "/path/to/people.store"),
    couldKitContainerIdentifier: "com.example.people"
)

// ModelContainerの生成
let container = try ModelContainer(for: fullSchema, trips, people)

var body: some Scene {
    WindowGroup {
        ContentView()
    }
    .modelContainer(container)
}
```

## Track and persist changes

* **ModelContext**
  * メモリ内の状態を追跡・管理する(Modelクラスのインスタンスに対して)

``` swift
// modelContainerのmodifierがトリガーとなり環境内にmodelContextが設定される
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
    }
}

struct ContentView: View {
    // @Queryでコンテキストにアクセス可能になる
    @Query var trips: [Trip]
    // アプリケーションが管理するデータに対するView
    // context.save()が実行されるまではModelContext内に存在し続ける
    @Environment(\.modelContext) var modelContext

    var body: some View {
        NavigationStack(path: $path) {
            List(selection: $selection) {
                ForEach(trips) { trip in
                    TripListItem(trip: trip)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(trip)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteTrips(at:))
            }
        }
    }
}
```

``` swift
// redo/undoを可能にする
@main
struct TripsApp: App {
    @Environment(\.undoManager) var undoManager

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // スワイプで削除、シェイクで状態を元に戻すといった挙動を追加コード無しで実現可能になる
        .modelContainer(for: Trip.self, isUndoEnabled: true)
    }
}

// 自動保存(デフォルトで有効)
// アプリケーションがフォアグラウンド、バックグラウンドに入るシステムイベントに反応して保存される
// アプリケーションが使用されると、メインコンテキストが定期的に保存される
@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self, isAutosaveEnabled: false)
    }
}
```

## Modeling at scale

``` swift
// モデルの取得(FetchDescritor)
let context = self.newSwiftContext(from: Trip.self)
var trips = try context.fetch(FetchDescriptor<Trip>())

// Predicate macroの使用
let hotelNames = // ...
let context = // ...

var predicate = #Predicate<Trip> { trip in
    trip.livingAccommodations.filter {
        hotelNames.contians($0.placeName)
    }.count > 0
}

var predicate = #Predicate<Trip> { trip in
    trip.livingAccommodation.filter {
        $0.hasReservation == false
    }.count > 0
}

var descriptor = FetchDescriptor(predicate: predicate)
var trips = try context.fetch(descriptor)

// ModelContext enumrate(FetchDescriptorに関連する結果取得変更処理の結合)
let predicate = #Predicate<Trip> { trip in
    trip.bucketListItem.filter {
        $0.hasReservation == false
    }.count > 0
}

let descriptor = FetchDescriptor(predicate: predicate)
descriptor.sortBy = [SortDescriptor(\.start_date)]

context.enumrate(descriptor) { trip in
    // バッチ処理、横断処理に関する方法を自動的に実装する
    // バッチサイズのデフォルト(5000オブジェクト)
}

context.enumrate(
    descriptor,
    batchSize: 10000
) { trip in
    // メモリの増加を犠牲にして横断処理の際のI/0(Input/Output)を減らす
}

context.enumrate(
    descriptor,
    batchSize: 500
) { trip in
    // メモリの増加は抑えられるが、横断処理内のI/Oが増える
}

context.enumrate(
    descriptor,
    batchSize: 500,
    allowEscapingMutations: true // 変異ガードが意図的であることを伝える
) { trip in
    // ...
}
```