# アプリパターン設計(一言で説明してみる)

## 設計とは？

再現性のある問題に対する共通の解決策
  - 問題を定型化して捉えられる
  - 解決策を客観的に比較できる
  - メンバーの共通言語となる

## 設計の原則

``` swift
// 【問題2: 移植性のなさ】
// 【依存関係逆転の原則】
//   ・上位レベルのモジュールは下位レベルのモジュールに依存すべきでない。両方とも抽象に依存すべきである
//   ・抽象は詳細に依存してはならない。詳細が抽象に依存すべきである
//
// 【問題3: もろさ、不必要な複雑さ】
// 【インターフェース分離の原則】
//   ・クライアントに、クライアントが利用しないメソッドへの依存を強制してはならない
final class CommonMessageAPI {
    func fetchAll(
        ofUserId: Int,
        completion: @escaping ([Message]?) -> Void { ... }
    )

    func fetch(
        id: Int,
        completion: @escaping (Message?) -> Void { ... }
    )

    func sendTextMessage(
        text: String,
        completion: @escaping (TextMessage?) -> Void { ... }
    )

    func sendImageMessage(
        image: UIImgge,
        text: String?,
        completion: @escaping (ImageMessage?) -> Void { ... }
    )
}

final class MessageSender {
    private let api = CommonMessageAPI()
    let messageType: MessageType
    var delegate: MessageSenderDelegate?

    // MessageType.officialをセットするのは禁止!!
    init(messageType: MessageType) {
        self.messageType = messageType
    }

    // 送信するメッセージの入力値
    var text: String? { // TextMessage, ImageMessageどちらの場合も使う
        didSet {
            if !isTextValid {
                delegate?.validではないことを伝える()
            }
        }
    }
    var image: UIImage? { // ImageMessageの場合に使う
        didSet {
            if !isImageValid {
                delegate?.validではないことを伝える()
            }
        }
    }
    // 通信結果
    private(set) var isLoading: Bool = false
    private(set) var result: Message? // 送信成功したら値が入る

    // 【問題1: 複雑なバリデーションロジックの保持】
    // 【単一責任原則】
    //   ・クラス(型)を変更する理由は2つ以上存在してはならない
    private var isTextValid: Bool {
        switch messageType {
        case .text: return text != nil && text!.count <= 300 // 300字以内
        case .image: return text == nil || text!.count <= 80 // 80字以内 or nil
        case .offcial: return false // 必ずfalse
        }
    }
    private var isImageValid: Bool {
        return image != nil // imageの場合だけ考慮する
    }
    private var isValid: Bool {
        switch messageType {
        case .text: return isTextValid
        case .image: return isTextValid && isImageValid
        case .offcial: return false // 必ずfalse
        }
    }

    func send() {
        guard isValid else {
            delegate?.validではないことを伝える()
            return
        }

        isLoading = true

        switch messageType {
        case .text:
            api.sendTextMessage(text: text!) { [weak self] in
                self?.isLoading = false
                self?.result = $0
                self?.delegate?.通信完了を伝える()
            }

        case .image:
            api.sendImageMessage(image: image!, text: text) { ... }

        case .official:
            fatalError()
        }
    }
}
```

``` swift
protocol MessageInput {
    associatedtype Payload
    func validate() throws -> Payload
}

protocol MessageSenderAPI {
    associatedtype Payload
    associatedtype Response: Message

    func send(
        payload: Payload,
        completion: @escaping (Response?) -> Void
    )
}

final class MessageSender<API: MessageSenderAPI, Input: MessageInput> where API.Payload == Input.Payload {
    enum State {
        case inputting(validationError: Error?)
        case sending
        case send(API.Response)
        case connectionFailed

        init(evaluating input: Input) { ... }

        mutating func accept(response: API.Response?) { ... }
    }

    private(set) var state: State {
        didSet {
            delegate?.stateの変化を伝える()
        }
    }

    let api: API

    var input: Input {
        didSet {
            state = State(evaluating: input)
        }
    }

    var delegate: MessageSenderDelegate?

    init(api: API, input: Input) {
        self.api = api
        self.input = input
        self.state = State(evaluating: input)
    }

    func send() {
        do {
            let payload = try input.validate()
            state = .sending
            api.send(payload: payload) { [weak self] in
                self?.state.accept(response: $0)
            }
        } catch let e {
            state = .inputting(validationError: e)
        }
    }
}
```

## アーキテクチャ

アプリの大まかなレイヤー(層)分割の捉え方

* GUIアーキテクチャ
  * システム本来の関心領域(ドメイン)を、UI(プレゼンテーション)から引き離す
  * UIにもシステム本来の関心にも該当しない処理は考慮しない
    * 例) サーバーAPIからのデータを試み、そこで発生したネットワークエラーをハンドリングする
    * 例) データをストレージに永続化する

* システムアーキテクチャ
  * UIという単位にとらわれず、システム全体の構造で捉える

## MVC(GUIアーキテクチャ)

* プログラムを「入力」「出力」「データの処理」の3つの要素に分け、それぞれ**Controller**、**View**、**Model**と定義したアーキテクチャ(**Model-View-Controller**)

<img src="../../Image/Architecture/Architecture1.png" width=100%>

* **Model** → 各種ビジネスロジックのかたまり
* **View** → 画面の描画を担当
* **Controller** → 何かしらの入力に対する適切な処理を行うだけでなく、ModelオブジェクトとViewオブジェクトを保持する。Modelオブジェクトに処理を依頼し、受け取った結果を使ってViewオブジェクトへ描画を指示する。

## MVP(GUIアーキテクチャ)

* コンポーネント間を疎結合にすることでテスト容易性と作業分担のしやすさを目的とし、それぞれを**Presenter**、**View**、**Model**と定義したアーキテクチャ(**Model-View-Presenter**)

### Passive View

<img src="../../Image/Architecture/Architecture2.png" width=100%>

* **Model** → Presenterからのみアクセスされ、Viewとは直接の関わりを持たない
* **View** → Presenterからの描画指示に従うだけで、完全に受け身な立ち位置
* **Presenter** → すべてのプレゼンテーションロジックを受け持つ

### Supervising Controller

<img src="../../Image/Architecture/Architecture3.png" width=100%>

* **Model** → Presenterからのみアクセスされ、必要に応じてViewに対してイベントを通知する
* **View** → PresenterとModelの双方から描画処理を受け、簡単なプレゼンテーションロジックを受け持つ
* **Presenter** → 複雑なプレゼンテーションロジックを担う

## MVVM(GUIアーキテクチャ)

* それぞれを**ViewModel**、**View**、**Model**と定義し、画面の描写処理をViewに、画面描写のロジックをViewModelコンポーネントに閉じ込めるアーキテクチャ(**Model-View-ViewModel**)

* View-ViewModel間はデータバインディングで関連付けられ、ViewModelの状態変更に同期してViewの状態も更新され、画面に反映される。宣言的なバインディングにより、ViewModelの自身の状態を更新するだけで、Viewの描画処理が発火され、手続的な描画指示の必要がなくなる

* 関数型リアクティブプログラミングと相性が良い(Combine, RxSwift, RactiveSwift)

<img src="../../Image/Architecture/Architecture4.png" width=100%>

* **Model** → UIに関係しない純粋なドメインロジックやそのデータを保持する
* **View** → ユーザー操作の受け付けと、画面表示を担当する。ViewModelが保持する状態とデータバインディングし、ユーザー入力に応じてViewModelが保持するデータを加工・更新することで、バインディングした画面表示を更新する
* **ViewModel** → View-Model間の画面表示のための仲介役で次の責務を担う
  * Viewに表示するためのデータを保持する
  * Viewからイベントを受け取り、Modelの処理を呼び出す
  * Viewからイベントを受け取り、加工して値を更新する

## Flux(GUIアーキテクチャ)

* データフローが単一方向であるアーキテクチャ

<img src="../../Image/Architecture/Architecture5.png" width=100%>

* **Action** → 実行する処理を特定するためのtypeと、実行する処理に紐づくdataを保持したオブジェクト
* **Dispatcher** → Actionを受け取り、自身に登録されているStoreに伝える
* **Store** → 状態を保持し、Dispatcherから伝わったActionのtypeとdataに応じて、状態を変更する
* **View** → Storeの状態を購読し、その変更に応じて画面を更新する

<img src="../../Image/Architecture/Architecture6.png" width=100%>

※ ユーザーの入力を受けたViewは、その入力をもとにActionを生成し、Dispatcherに渡される。Storeの状態はAction経由でのみ変更される。


* Viewコンポーネント
  * ユーザーの何らかの入力によるイベント

<img src="../../Image/Architecture/Architecture7.png" width=100%>

* Actionコンポーネント
  * 何らかの処理を行い、その結果からActionの生成
  * 生成したActionをDispatcherへ送信

<img src="../../Image/Architecture/Architecture8.png" width=100%>
<img src="../../Image/Architecture/Architecture9.png" width=100%>

* Dispatcherコンポーネント
  * register(callback:)をStore側で呼び出し、Callbackを登録してActionを受け取る
  * dispatch(_:)でActionCreatorがActionを送信する

<img src="../../Image/Architecture/Architecture10.png" width=100%>

* Storeコンポーネント
  * Dispatcherのregister(callback:)を使ってCallbackを登録し、そのCallbackからActionを受け取る
  * Storeの状態に変更があった場合に変更通知を送信し、Viewがその変更通知を受け取る

<img src="../../Image/Architecture/Architecture11.png" width=100%>

* 全体データフロー

<img src="../../Image/Architecture/Architecture12.png" width=100%>

## Clean Architecture(システムアーキテクチャ)

* UIだけでなくアプリケーション全体、Modelの内部表現まで踏み込んだアーキテクチャパターン。

* あるシステムの1機能を実現するアプリケーションを考える時、その実現する機能の領域(ドメイン)と技術の詳細に注目し、4つのコンポーネントに切り分ける
  * **Entity** → アプリケーションに依存しない、ドメインに関するデータ構造やビジネスロジック
  * **Use Case** → アプリケーションで固有なロジック
  * **インターフェイスアダプター** → Use Case・フレームワークとドライバで使われるデータ構造を互いに変換する
  * **フレームワークとドライバ** → データベース(DB)、Webなどのフレームワークやツールの「詳細」

<img src="../../Image/Architecture/Architecture13.png" width=100%>

### 依存性のなさ(依存性が低い→高い)

* Entity → Use Case → インターフェイスアダプター → フレームワークとドライバ
  * 依存の方向を外から内への一方向にすることで、変えやすい部分を変えやすく、維持しておきたい部分はそのままにしやすくできる

### 依存関係のルール

* Entity
  * 処理の方法に依存しないビジネスロジックで、データ構造やメソッドの集合体
  * 外側の層には依存しないため、Use Caseや他の層にによってどのように使われるかを気にしない

* Use Case
  * Entityを使ってアプリケーション固有のビジネスロジック(構築対象のアプリケーションに対してのみ有効な処理)を実現する
  * UIに関する処理を持たない

* インターフェイスアダプター
  * 円の内外に合わせてデータやイベントを変換するためのレイヤー
  * Use CaseやEntityで扱っているデータ表現をSQLやUI用のデータに変換したり、逆にデータベースやWebからのデータをUse CaseやEntityで使われる表現に変換するなど、両縁のためにつなぎの役割をこなす(PresenterやController)
  * Use Caseと最外層とを接続する役割を担うことから、Use Caseの入出力ポートを外側の何かに接続するかを決定する責務を持つ

* フレームワークとドライバ
  * UI、データベース、デバイスドライバ、Web APIクライアントなどの最外層として、実装の詳細で、環境や顧客の要求変化にもっとも影響を受ける場所
  * UIの実装先OSの種類、フレームワークといった環境も扱う(UIKitやAlamofireなど)

## TCA

* SwiftUIが状態管理にアプローチする方法に対しての、5つの大きな問題を定型化し、これを解決するためのアーキテクチャ(SwiftUI版のRedux)

1. アプリケーション全体の状態を管理する方法
2. 値の型のような単純な単位でアーキテクチャをモデル化する方法
3. アプリケーションの各機能をモジュール化する
4. アプリケーションの副作用をモデル化する
5. 各機能の包括的なテストを簡単に記述する方法

* 「副作用のない純粋関数」を用いて「人間が理解しやすい単方向の予測可能な状態変化のフロー」**でしか**コードを書けなくなる
  * 「複雑怪奇で難解なコード」を生み出すリスクが大幅に下がる

* 「状態管理、Composable、テスト」に重点を置いた、複数の要素や部品などを結合して、構成や組み立てが可能なアーキテクチャとなる

### 背景

* 宣言的UIの登場で、UIのコンポーネント化(部品化)が進む
  * → SwiftUIでUIのコンポーネント化(部品化)が容易になるため
  * → 部品を組み合わせて画面を構成する(Compose)作業が必要になる

* 部品化されたUIを、組み立てやすいアーキテクチャが求められている
  * 宣言的UIの環境ではComposable(部品を組み立て可能)なアーキテクチャが求められている
  * 「UIの部品化がしやすい」「その部品を組み合わせやすい」アーキテクチャであれば、宣言的UIのメリットを最大限享受できる

※ MVVMはComposableではない

MVVMの状態管理には`@Environment`, `@EnvironmentObject`, `@StateObject`, `@ObservedObject`などのProperty Wrapperの使い分けと共に、データフローがかなり複雑になっていく。

特に、コンポーネント階層の下流にコンポーネントをどんどん埋め込んでいくと、より複雑になる。コンポーネントが増えれば増えるほど、状態変化トリガーや状態監視の管理も難しくなり、どのコンポーネントが状態を保持し、その状態変更トリガーがどこから行われるかということが、コードを一見しただけでは分からなくなる。

コンポーネント化が進めば進むほど、ViewModelの状態管理は複雑になるため、宣言的UIにはMVVMは合わない

→ 解決策がThe Composable Architecture(TCA)

### 導入メリット

* 宣言的UIに適したComposableなアーキテクチャを導入できる
* 処理やデータの流れがシンプルになる
  * 異なるコンポーネントを通過するデータの流れが明確に定義され、一方向である
  * コードや処理の理解を容易にする
* 大規模アプリになっても、コードがスケールする(容易に分割できる)
* ビジネスロジックの切り出しが容易
* ロジック(reducer)やstateを合成できる。状態管理とロジックを組み合わせることが容易
* テストが書きやすい

### 導入デメリット

* 学習コストが高い
  * コンポーネント階層が深くなると、Storeの設計や、Store情報の受け渡し方法に頭を悩ませる
    * Storeの情報(環境情報なども)をProps渡しするのが煩雑になる
    * Storeの分割をどうするかを悩む
* TCAのライブラリ自体の信頼性がまだ低い
* 作成されてから日がまだ浅い

### SwiftUIにMVVMは、なぜ合わないのか

* Composableではない
  * 宣言的UIでUIの部品化が進むと、コンポーネント間の接続の問題(状態管理とその状態をどうやって運ぶか)が発生するが、MVVMはコンポーネント間の接続の問題を解決するアーキテクチャではない
* 異なるコンポーネントを通過するデータフローが明確に定義されず、フローの方向がぐちゃぐちゃになる(コードの理解を難しくする)
  * Property Wrapperの種類の多さから、ViewModelをどこに管理して、どうやって運ぶかという問題に、いちいち頭を悩ませる必要がある
  * ViewModelの無秩序化によって、コードが複雑になりスケールしない
  * ViewModelとModelのやりとりが煩雑になる