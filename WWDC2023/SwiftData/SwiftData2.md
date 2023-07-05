# Build an app with SwiftData

## クラスのSwiftData化(@Model)

``` swift
// before
final class Card: ObservableObject {
    @Published var front: String
    @Published var back: String
    var creationDate: Date

    init(front: String, back: String, creationDate: Date = .now) {
        self.front = front
        self.back = back
        self.creationDate = creationDate
    }
}

@ObservedObject var card: Card

// after
@Model
final class Card {
    var front: String
    var back: String
    var creationDate: Date

    init(front: String, back: String, creationDate: Date = .now) {
        self.front = front
        self.back = back
        self.creationDate = creationDate
    }
}

@Bindable var card: Card
```

## SwiftDataのModel参照(@Query)

``` swift
// SwiftDataからModelに問い合わせるためのプロパティラッパー
// @Stateと同じようにModelが変更されるたびにビューが更新される
// Viewのモデルコンテキストがデータソースとして使用される
@Query private var cards: [Card]

// ソート、順序付け、フィルタリング、アニメーションの変更などの設定も可能
@Query(sort: \.created) private var cards: [Card]
```

## モデルコンテナの提供(modelContainer)

``` swift
// View modifier
.modelContainer(for: Card.self)

// 全てのView階層で使用できるように設定(データを操作できるようになる)
@main FlashCardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Card.self)
    }
}
```

## モデルコンテキストの提供(modelContext)

``` swift
// Environment variable
@Environment(\.modelContext) private var modelContext

let newCard = Card(front: "Sample Front", back: "Sample Back")
modelContext.newInsert(newCard)

// 以下のように明示的にsave()を呼び出す必要はなく、自動保存される
// 自動保存はUI関連のイベントとユーザーの入力がトリガーとなる
// 例外的に全ての変更をすぐに永続化したいことを確認したい場合は明示的に呼び出す
// modelContext.save()
```