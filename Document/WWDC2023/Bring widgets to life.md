# Bring widgets to life

## Animations

* **ウィジェットにおけるアニメーション**

``` swift
// 通常のSwiftUI
struct DailyCaffeineView: View {
    // 状態の保持・変化には@Stateを使う
    @State var logs: [CaffeineLog] = []
    @State var totalCaffeine: Measurement<UnitMass> = .mg(0)

    var body: some View {
        VStack(alignment: .leading) {
            TotalCaffeineView(totalCaffeine)
            LastDrinkView(logs: logs)

            Button {
                // アニメーションの指定
                withAnimation {
                    logs.append(CaffeineLog(drink: .espresso, date: Date()))
                    totalCaffeine = totalCaffeine + Drink.espresso.caffeine
                }
            } label: {
                Label("Espresso", systemImage: "plus")
            }
        }
    }
}

// Widgetでは状態を持たないため、代わりにエントリー毎に作られたタイムラインを作成する
// エントリー間での変更された部分をアニメーションする
import SwiftUI
import AppIntents
import WidgetKit

struct CaffineTrackerWidgetView: View {
    var entry: CaffeineEntry

    var body: some View {
        VStack(alignment: .leading) {
            TotalCaffeineView(
                totalCaffeine: entry.totalCaffeine
            )

            Spacer()

            if let log = entry.log {
                LastDrinkView(log: log)
            }
        }
        .fontDesign(.rounded)
        // ウィジェットの背景定義(Mac, iPadで新しくサポートされた全ての箇所に表示される)
        .containerBackground(for: .widget) {
            Color.cosmicLatte
        }
    }
}

struct TotalCaffineView: View {
    let totalCaffiene: Measurement<UnitMass>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Caffeiene")
                .font(.caption)

            Text(totalCaffiene.formatted())
                .font(.title)
                .minimumScaleFactor(0.8)
                // アニメーションの追加
                .contentTransition(.numericText(value: totalCaffienvalue))
        }
        .foregroundColor(.espresso)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LastDrinkView: View {
    static var dateFormatStyle = Date.FormatStyle(
        date: .omitted,
        time: .shortened
    )

    let log: CaffineLog

    var caffeineAmmount: String {
        log.drink.caffeine.formatted()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(log.drink.name)
                .bold()

            Text("\(log.date, format: Self.dateFormatStyle) \・\ \(caffeineAmmount)")
        }
        .font(.caption)
        // ビューのID紐付け(変更されるたびに新しいものに遷移する必要があることを通知する)
        .id(log)
        // アニメーションの追加
        .transition(.push(from: .bottom))
        .animation(.smooth(duration: 0.2), value: log)
    }
}

// プレビューでの確認
#Preview(as: WidgetFamily.systemSmall) {
    CaffineTrackerWidget()
} timeline: {
    CaffineLogEntry.log1
    CaffineLogEntry.log2
    CaffineLogEntry.log3
    CaffineLogEntry.log4
}
```

## Interactivity

* **ウィジェット内でのアクション実行**

``` swift
// Widgetの更新
class WeatherForecastLocationStore {
    // ...

    func reloadForecast() async throws {
        self.forecast = try await loadCurrentLocationForecast()
        WidgetCenter.shared.reloadTimelines(ofKind: "LocationForecast")
    }

    // ...
}

// Widget内でのアクション操作
struct TodoView: View {
    var todo: Todo

    var body: some View {
        HStack {
            Text(todo.title)

            // レンダリングは別のプロセスで行われるため、クロージャは実行されない
            Button("Done!") {
                todo.markAsDone()
            }
        }
    }
}

// AppIntent
struct ToggleTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle as Todo"

    @Parameter(title: "Todo")
    var todo: Todo

    func perform() async throws -> some IntentResult {
        // Toggle todo in database
        return .result()
    }
}

// AppIntent用のイニシャライザーの追加
import SwiftUI
import AppIntents

extension Button {
    public init<I: AppIntent>(
        intent: I,
        @ViewBuilder label: () -> Label
    )
}

extension Toggle {
    public init<I: AppIntent>(
        isOn: Bool,
        intent: I,
        @ViewBuilder label: () -> Label
    )
}

// AppIntentの作成
import AppIntents

struct LogDrinkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a drink"

    @Parameter(title: "Drink", optionsProvider: DrinkOptionsProvider())
    var drink: Drink

    init() {}

    init(drink: Drink) {
        self.drink = drink
    }

    func perform() async throws -> some IntentResult {
        await DrinkLogStore.shared.log(drink: drink)
        return .result()
    }
}

struct LogDrinkButtonView: View {
    var body: some View {
        Button(intent: LogDrinkIntent(drink: .espresso)) {
            Label("Espresso", systemImage: "plus")
                .font(.caption)
        }
        .tint(.espresso)
    }
}

struct CaffineTrackerWidgetView: View {
    var entry: CaffeineEntry

    var body: some View {
        VStack(alignment: .leading) {
            TotalCaffeineView(
                totalCaffeine: entry.totalCaffeine
            )

            Spacer()

            if let log = entry.log {
                LastDrinkView(log: log)
            }

            Spacer()

            HStack {
                Spacer()
                LogDrinkButtonView()
                Spacer()
            }
        }
        .fontDesign(.rounded)
        .containerBackground(for: .widget) {
            Color.cosmicLatte
        }
    }
}

struct TotalCaffineView: View {
    let totalCaffiene: Measurement<UnitMass>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Caffeiene")
                .font(.caption)

            Text(totalCaffiene.formatted())
                .font(.title)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText(value: totalCaffienvalue))
                // アプリのインテントが終了するとウィジェットはタイムラインをリロードする
                // そのため、アクションからUIが変更されるまでにわずかな待ち時間が発生する
                // invalidateableContent()で更新が入るためにその値が無効であることを示すエフェクトを表示できる(必要な時のみ使用)
                .invalidateableContent()
        }
        .foregroundColor(.espresso)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```