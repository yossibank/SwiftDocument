# Discover Observation in SwiftUI

## What is Observation?

* **Observation(プロパティの変更を追跡する)**

``` swift
// データモデルの変更に応じてUI(SwiftUI)が応答する
@Observable class FoodTruckModel {
    var orders: [Order] = []
    var donuts = Donut.all
    var orderCount: Int { orders.count }
}

struct DonutMenu: View {
    let model: FoodTruckModel

    // bodyが実行されるときにSwiftUIはObservable型から使用されるプロパティへの全てのアクセスを追跡する
    // bodyが再更新されるのはbody内で使用しているObservable型の特定のプロパティに変更があった時
    var body: some View {
        List {
            Section("Donuts") {
                ForEach(model.donuts) { donut in
                    Text(donut.name)
                }
                Button("Add new donut") {
                    model.addDonut()
                }
            }
            Section("Orders") {
                LabeledContent("Count", value: "\(model.orderCount)")
            }
        }
    }
}
```

## SwiftUI property wrappers

* **@State, @Environment, @Bindable**

``` swift
// Viewの状態をModelに格納する必要がある場合(@State)
struct DonutListView: View {
    var donutList: DonutList

    @State private var donutToAdd: Donut?

    var body: some View {
        List(donutList.donuts) {
            DonutView(donut: $0)
        }
        Button("Add Donut") {
            donutToadd = Donut()
        }
        .sheet(item: $donutToAdd) {
            TextField("Name", text: $donutToAdd.name)
            Button("Save") {
                donutList.donuts.append(donutToAdd)
                donutToAdd = nil
            }
            Button("Cancel") {
                donutToAdd = nil
            }
        }
    }
}

// 値をグローバルにアクセス可能な値として伝搬させる(@Environment)
@Observable class Account {
    var userName: String?
}

struct FoodTruckMenuView: View {
    @Environment(Account.self) var account

    var body: some View {
        if let name = account.userName {
            HStack {
                Text(name)
                Button("Log out") {
                    account.logout()
                }
            }
        } else {
            Button("Login") {
                account.showLogin()
            }
        }
    }
}

// バインド可能な値を取得する(@Bindable)
@Observable class Donut {
    var name: String
}

struct DonutView: View {
    @Bindable var donut: Donut

    var body: some VIew {
        TextField("Name", text: $donut.name)
    }
}

// ModelはView自体の状態である必要がある → @State var
// Modelはアプリケーションのグローバルな環境の一部である必要がある → @Environment var
// Modelはバインディングを行うだけである → @Bindable var
// 上記の3つ全てに属さない → var
```

## Advanced uses

* **配列・Optional型に対しての自由な変更**

``` swift
@Observable class Donut {
    var name: String
}

struct DonutList: View {
    var donuts: [Donut]

    var body: some View {
        List(donuts) { donut in
            HStack {
                Text(donut.name)
                Spacer()
                Button("Randomize") {
                    donut.name = randomName()
                }
            }
        }
    }
}
```

**computed propertyに対するObservableの変更検知**

``` swift
@Observable class Donut {
    var name: String {
        get {
            access(keyPath: \.name)
            return someNonObservableLocaltion.name
        }
        set {
            withMutation(keyPath: \.name) {
                someNonObservableLocation.name = newValue
            }
        }
    }
}
```

## ObservableObject

* **Observableへの変更**

``` swift
// before
public class FoodTruckModel: ObservableObject {
    @Published public var truck = Truck()

    @Published public var orders: [Order] = []
    @Published public var donuts = Donut.all

    var dailyOrderSummaries: [City.ID: [OrderSummary]] = [:]
    var monthlyOrderSummaries: [City.ID: [OrderSummary]] = [:]

    ...
}

// after
@Observable public class FoodTruckModel {
    public var truck = Truck()

    public var orders: [Order] = []
    public var donuts = Donut.all

    var dailyOrderSummaries: [City.ID: [OrderSummary]] = [:]
    var monthlyOrderSummaries: [City.ID: [OrderSummary]] = [:]

    ...
}
```