## The Composable Architecture

* SwiftUIが状態管理にアプローチする方法に対しての5つの大きな問題を定型化し、これを解決するためのアーキテクチャ
  1. 状態管理 → シンプルな値型を使用してアプリケーションの状態を管理し、多くの画面で状態を共有して、ある画面での状態の変更を別の画面ですぐにobserveできるようにする方法
  2. 組み立て・構成 → 大きな機能を小さなComponentに分解し、それぞれを独立したモジュールに抽出し、簡単にそれらを繋いで機能を形成する方法
  3. 副作用 → 可能な限りテスト可能で理解しやすい方法で、アプリケーションの特定の部分を下界と対話させる方法
  4. テスト → アーキテクチャで構築された機能をテストするだけでなく、多くのComponentで構成された機能の統合テストを書いたり、副作用がアプリケーションに与える影響を理解するためにE2Eテストを書いたりする方法。これにより、ビジネスロジックが期待通りに動作していることを強く保証することができる
  5. 開発者にとっての使いやすさ → 上記の全てを、できるだけ少ないコンセプトと動作するパーツからならシンプルなAPIで実現する方法

### 背景

* 宣言的UIの登場で、UIのComponent化(部品化)が進む
  * SwiftUIの登場でUIのComponent化(部品化)が容易になるため
  * 部品を組み合わせて画面を構成する(Compose)作業が必要になる

* 部品化されたUIを、組み立てやすいアーキテクチャが求められている
  * 宣言的UIの環境ではComposable(部品を組み立て可能)なアーキテクチャが求められている
  * 「UIの部品化がしやすい」「その部品を組み合わせやすい」アーキテクチャであれば、宣言的UIのメリットを最大限享受できる

* MVVMはComposableではない
  * MVVMの状態管理には`@Environment`, `@EnvironmentObject`, `@StateObject`, `@ObservedObject`などのProperty Wrapperの使い分けと共に、データフローがかなり複雑になっていく。
  * 特に、Component階層の下流にCompoenntをどんどん埋め込んでいくと、より複雑になる。Componentが増えれば増えるほど、状態変化トリガーや状態監視の管理も難しくなり、どのComponentが状態を保持し、その状態変更トリガーがどこから行われるかということが、コードを一見しただけでは分からなくなる。
  * Component化が進めば進むほど、ViewModelの状態管理は複雑になるため、宣言的UIにはMVVMは合わない

### 基本構造

* **State** → ビジネスロジックを実行し、UIをレンダリングするために必要なデータを記述する型
* **Action** → ユーザーのアクション、通知、イベントソースなど、アプリ内で起こりうる全てのアクションを表す型
* **Reducer** → Actionが与えられた時に、アプリの現在のStateを次のStateに更新させる方法を記述する関数
* **Store** → 実際にアプリの機能を動かすruntime。全てのユーザーアクションをStoreに送信し、StoreはReducerとEffectを実行できるようにし、Storeの状態変化をobserveしてUIを更新できるようにする

### 例

* 数字を増減させる「+」「-」ボタンが表示されるUIを考えてみる。面白くするために、タップするとAPIリクエストを行い、その数字に関するランダムな事実を取得し、その事実をAlertで表示するボタンがあるUIだとする

``` swift
// 実装
import ComposableArchitecture

// ドメインと機能の振る舞いを保持するReducerに準拠した新しい型の定義
struct Feature: Reducer {
    // 現在のカウントを表す数値と、表示したいアラートのタイトルを表すString(nilはアラートを表示しないのでオプショナル)で構成される状態を表すための型の定義
    struct State: Equatable {
        var count = 0
        var numberFactAlert: String?
    }

    // アプリの機能を表すための型の定義
    // ユーザーがアラートをdismissするものやAPIリクエストからresponseを受け取る時に発生するものなどわかりにくいものもある
    enum Action: Equatable {
        case factAlertDismissed
        case decrementButtonTapped
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(String)
    }

    // 機能の実際のロジックや振る舞いをハンドリングする役割を持つreduceメソッドの実装
    // 現在のstateを次のstateに変更する方法を記述し、どのようなeffectsを実行する必要があるのかも記述する
    // actionsによってはeffectsを実行する必要がないものもあり、その場合は.noneをreturnする
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .factAlertDismissed:
            state.numberFactAlert = nil
            return .none

        case .decrementButtonTapped:
            state.count -= 1
            return .none

        case .incrementButtonTapped:
            state.count += 1
            return .none

        case .numberFactButtonTapped:
            return .run { [count = state.count] send in
                let (data, _) = try await URLSession.shared.data(
                    from: URL(string: "http://numbersapi.com/\(count)/trivia")!
                )
                await send(.numberFactResponse(string(decoding: data, as: UTF8.self)))
            }

        case let .numberFactResponse(fact):
            state.numberFactAlert = fact
            return .none
        }
    }
}

// 機能を表示するためのViewの定義
// StateOf<Feature>を保持して、stateへの全ての変更をobserveして再レンダリングできるようにし、stateを変化させるためにユーザーのactionsをstoreに送信できるようにする
// .alert view modifierが必要とするIdentifableを満たせるように、factアラート用にstructのwrapperを導入する
struct FeatureView: View {
    let store: StoreOf<Feature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Button("-") { viewStore.send(.decrementButtonTapped) }
                    Text("\(viewStore.count)")
                    Button("+") { viewStore.send(.incrementButtonTapped) }
                }

                Button("Number fact") { viewStore.send(.numberFactButtonTapped) }
            }
            .alert(
                item: viewStore.building(
                    get: { $0.numberFactAlert.map(FactAlert.init(title:)) },
                    send: .factAlertDismissed
                ),
                content: { Alert(title: Text($0.title)) }
            )
        }
    }
}

struct FactAlert: Identifable {
    var title: String
    var id: String { title }
}

// アプリのエンドポイントでstoreを構築
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            FeatureView(
                store: Store(initialState: Feature.State()) {
                    Feature()
                }
            )
        }
    }
}
```

``` swift
// テスト
import ComposableArchitecture

// テストするためにはTestStoreを使用する
// Storeを同じ情報で作成できるが、actionsが送信されたときに機能がどのように変化するかをassertするための追加の作業を行う
@MainActor
func testFeature() async {
    let store = TestStore(initialState: Feature.State()) {
        Feature()
    }
}

// ユーザーフロー全体のステップをassertionしていく
// increment/decrement bubttonをタップするとカウントが変化することをテストする
await store.send(.incrementButtonTapped) {
    $0.count = 1
}
await store.send(.decrementButtonTapped) {
    $0.count = 0
}

// ステップによってeffectが実行され、データがstoreにフィードバックされる場合、それについてassertする必要がある
// 例えば、ユーザーがfact buttonをタップした際に、factを含むresponseが返却され、それによってalertが表示されることを期待する
await store.send(.numberFactButtonTapped)

// 現状は実際のAPIリクエストを送信してレスポンスを取得するようにしている
await store.receive(.numberFactResponse(.success(???))) {
    $0.numberFactAlert = ???
}

// dependencyをreducerに渡すようにする
// アプリ実行の時には実際のdependencyを使用する
// テスト実行の時にはmock化されたdependencyを使用する
struct Feature: Reducer {
    let numberFact: (Int) async throws -> String
    // ...

    case .numberFactButtonTapped:
      return .run { [count = state.count] send in
          let fact = try await self.numberFact(count)
          await send(.numberFactResponse(fact))
      }
}

// アプリケーションのエンドポイントでは実際のAPIリクエストのdependencyを提供する
@main
struct MyApp: App {
    var body: some Scene {
        FeatureView {
            store: Store(initialState: Feature.State()) {
                Feature(
                    numberFact: { number in
                        let (data, _) = try await URLSession.shared.data(
                            from: URL(string: "http://numbersapi.com/\(number)/trivia")!
                        )
                        return String(decoding: data, as: UTF8.self)
                    }
                )
            }
        }
    }
}

// テストではfactを即座に返すmockのdependencyを提供する
@MainActor
func testFeature() async {
    let store = TestStore(initialState: Feature.State()) {
        Feature(numberFact: { "\($0) is a good number Brent" })
    }
}

await store.send(.numberFactButtonTapped)

await store.receive(.numberFactResponse(.success("0 is a good number Brent"))) {
    $0.numberFactAlert = "0 is a good number Brent"
}

await store.send(.factAlertDismissed) {
    $0.numberFactAlert = nil
}

// 全てのレイヤーを通して明示的にnumberFactを渡すのは煩わしくなる
// numberFactをアプリケーションのどの層でも即座にdependencyを利用できるようにする
struct NumbetFactClient {
    var fetch: (Int) async throws -> String
}

// DependencyKey protocolに準拠させることで、その型をdependencyの管理システムに登録する
// シミュレーターやデバイスでアプリケーションを実行する時に使用するliveValue(実際の値)を指定する必要がある
extension NumberFactClient: DependencyKey {
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared.data(
                from: URL(string: "http://numbersapi.com/\(number)/trivia")!
            )
            return String(decoding: data, as: UTF8.self)
        }
    )
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}

// これらを定義することで、どのような機能でもすぐにdependencyを使用することができる
struct Feature: Reducer {
    // let numberFact: (Int) async throws -> String
    @Dependency(\.numberFact) var numberFact

    // ...

    // try await self.numberFact(count)
    try await self.numberFact.fetch(count)
}

// これにより、機能のreducerを構築する際にdependencyを明示的に渡す必要がなくなる
// previewsやシミュレーター、デバイス上でアプリを実行する場合は、live dependencyがreducerに提供される
// テストではテストのdependencyが提供される
@main
struct MyApp: App {
    var body: some Scene {
        FeatureView(
            store: Store(initialState: Feature.State()) {
                Feature()
            }
        )
    }
}

// testStoreではdependencyを指定せずに構築することができるが、必要に応じてdependencyをoverrideできる
let store = TestStore(initialState: Feature.State()) {
    Feature()
} withDependencies: {
    $0.numberFact.fetch = { "\($0) is a good number Brent" }
}
```