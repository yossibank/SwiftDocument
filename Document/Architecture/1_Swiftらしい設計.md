# Swiftらしい設計

## 設計の原則・Swiftの言語機能による設計改善

### 要件

あるアプリ内に「メッセージ」と呼ばれる概念が3種類あるとする

* **TextMessage**: textを持つ
* **ImageMessage**: imageを持ち、オプショナルでtextを添えられる
* **OfficialMessage**: 受信専用。ユーザーは送信不可能

### 責務

* メッセージ送信の元となる入力値を保持し、その値をサーバに送信する
* 通信結果を保持し、delegateに結果を伝える

### コード

``` swift
final class CommonMessageAPI {
    func fetchAll(
        ofUserId: Int,
        completion: @escaping ([Message]?) -> Void
    ) { ... }

    func fetch(
        id: Int,
        completion: @escaping (Message?) -> Void
    ) { ... }

    func sendTextMessage(
        text: String,
        completion: @escaping (TextMessage?) -> Void
    ) { ... }

    func sendImageMessage(
        image: UIImage,
        text: String?,
        completion: @escaping (ImageMessage?) -> Void
    ) { ... }
}

final class MessageSender {
    private let api = CommonMessageAPI()

    var delegate: MessageSenderDelegate?

    // 送信するメッセージに入力値
    // TextMessage, ImageMessageどちらの場合にも使う
    var text: String? {
        didSet {
            if !isTextValid {
                delegate?.validでないことを伝える()
            }
        }
    }

    // ImageMessageの場合に使う
    var image: UIImage? {
        didSet {
            if !isImageValid {
                delegate?.validでないことを伝える()
            }
        }
    }

    private(set) var isLoading: Bool = false

    // 送信成功したら値が入る
    private(set) var result: Message?

    private var isTextValid: Bool {
        switch messageType {
        case .text: return text != nil && text!.count <= 300 // 300字以内
        case .image: return text == nil || text!.count <= 80 // 80字以内 or nil
        case .official: return false // OfficialMessageはありえない
        }
    }

    // imageの場合のみを考慮する
    private var isImageValid: Bool {
        image != nil
    }

    private var isValid: Bool {
        switch messageType {
        case .text: return isTextValid
        case .image: return isTextValid && isImageValid
        case .official: return false // OfficialMessageはありえない
        }
    }

    let messageType: MessageType

    // MessageType.officialをセットするのは禁止!!
    init(messageType: MessageType) {
        self.messageType = messageType
    }

    func send() {
        guard isValid else {
            delegate?.validではないことを伝える()
            return
        }

        isLoading = false

        switch messageType {
        case .text:
            api.sendTextMessage(text: text!) { [weak self] in
                self?.isLoading = false
                self?.result = $0
                self?.delegate?.通信完了を伝える()
            }
        case .image:
            api.sendImageMessage(image: image!, text: text) {
                ...
            }
        case .official:
            fatalError()
        }
    }
}
```

### コードの問題点1

* **硬さ**: 変更しにくいシステム。1つの変更によってシステムの他の部分に影響が及び、 多くの変更を余儀なくさせるようなソフトウェア
* **もろさ**: 1つの変更によって、その変更とは概念的に関連のない箇所まで壊れてしま うようなソフトウェア
* **扱いにくさ**: 正しいことをするよりも、誤ったことをするほうが容易なソフトウェア
* **不必要な繰り返し**: 同じような構造を繰り返し含み、抽象化してまとめらられる部分
   がまとまっていないソフトウェア

``` swift
// 本当に正しく動くのか、ひと目では判断できない
private var isTextValid: Bool {
    switch messageType {
    case .text: return text != nil && text!.count <= 300
    case .image: return text == nil || text!.count <= 80
    case .official: return false
    }
}

private var isImageValid: Bool {
    image != nil
}

// 引数がないのでどういう条件で変化するのかが分からない
// 依存しているプロパティが暗黙的で、コードを丹念に追う必要がある
private var isValid: Bool {
    switch messageType {
    case .text: return isTextValid
    case .image: return isTextValid && isImageValid
    case .official: return false
    }
}
```

#### 単一責任原則(Single Responsibility Principle)

**クラス(型)を変更する理由はふたつ以上存在してはならない**

* **凝集**という概念を拡張したもので、モジュール内での責務がまとまっている状態(凝集度が高い状態)
  * **手続き的凝集(Procedural Cohesion)**
    * ある種の処理を行う時に動作する部分を集めたモジュール
  * **論理的凝集(Logical Cohesion)**
    * 論理的に似たようなことをするためのモジュール

``` swift
// バリデーションにだけ関心のある型を作成する
// そうすることでバリデーションロジックの変更する際のみに変更する必要性が発生する
struct MessageInputValidator {
    let messageType: MessageType
    let image: UIImage?
    let text: String?

    var isValid: Bool {
        ...
    }

    private var isTextValid: Bool {
        ...
    }

    private var isImageValid: Bool {
        ...
    }
}

// 上のコードではMessageTypeでTextMessageの場合とImageMessageの本来関連のない処理を含めている
// Messageの種別ごとに必要なバリデーションロジックが違うため、別モジュールとして切り出すべき
struct ImageMessageInputValidator {
    let image: UIImage?
    let text: String?

    var isValid: Bool {
        if image == nil {
            return false
        }

        if let text, text.count > 80 {
            return false
        }

        return true
    }
}

// バリデーションはImageMessageInput自身の知識として統合
// 失敗の可能性がある処理を表現する
enum ImageMessageInputError: Error {
    case noImage
    case tooLongText(count: Int)
}

struct ImageMessageInput {
    var text: String?
    var image: UIImage?

    func validate() throws -> (image: UIImage, text: String?) {
        guard let image else {
            throw ImageMessageInputError.noImage
        }

        if let text, text.count >= 80 {
            throw ImageMessageInputError.tooLongText(count: text.count)
        }

        return (image, text)
    }
}
```

### コードの問題点2

* **移植性のなさ**: 他システムでも再利用できる部分をモジュールとして切り離すことが 困難なソフトウェア

``` swift
// この型をテストする際にテストの度にネットワーク通信が走る
// ネットワーク状況やサーバ実装に応じてテスト結果が変化する可能性がある
final class CommonMessageAPI {
    func fetchAll(
        ofUserId: Int,
        completion: @escaping ([Message]?) -> Void
    ) { ... }

    func fetch(
        id: Int,
        completion: @escaping (Message?) -> Void
    ) { ... }

    func sendTextMessage(
        text: String,
        completion: @escaping (TextMessage?) -> Void
    ) { ... }

    func sendImageMessage(
        image: UIImage,
        text: String?,
        completion: @escaping (ImageMessage?) -> Void
    ) { ... }
}
```

#### 依存関係逆転の原則(Dependency Inversion Principle)

**上位レベルのモジュールは下位レベルのモジュールに依存すべきではない。両方とも抽象に依存すべきである**

**抽象は詳細に依存してはならない。詳細が抽象に依存すべきである**

* あるモジュールが具体型ではなく対象(protocol)に依存することで、依存対象の具体型を差し替え可能にする

``` swift
// API通信のインターフェースをprotocolで表現する
// API通信の実装とテストのみに用いるスタブ実装を差し替え可能にする
protocol CommonMessageAPIProtocol {
    func fetchAll(ofUserId: Int, completion: ...)
    func fetch(id: Int, completion: ...)
    func sendTextMessage(text: String, completion: ...)
    func sendImageMessage(image: UIImage, text: String?, completion: ...)
}

final class CommonMessageAPI: CommonMessageAPIProtocol {
    func fetchAll(ofUserId: Int, completion: ...) { ... }
    func fetch(id: Int, completion: ...) { ... }
    func sendTextMessage(text: String, completion: ...) { ... }
    func sendImageMessage(image: UIImage, text: String?, completion: ...) { ... }
}

struct Stub必ず成功するTextMessageAPI: CommonMessageAPIProtocol {
    ...

    func sendTextMessage(text: String, completion: ...) {
        DispatchQueue.main.async {
            completion(ImageMessage(id: 1, image: ..., text: "成功"))
        }
    }

    ...
}

struct Stub必ず失敗するTextMessageAPI: CommonMessageAPIProtocol {
    ...
}

// 外に渡すものはprotocolにすることで依存性注入(DI)を可能にする
// beofre
final class MessageSender {
    private let api = CommonMessageAPI()
}

// after
final class MessageSender {
    private let api: CommonMessageAPIProtocol

    init(api: CommonMessageAPIProtocol) {
        self.api = api
    }
}
```

### コードの問題点3

* **もろさ**: 1つの変更によって、その変更とは概念的に関連のない箇所まで壊れてしまうようなソフトウェア
* **不必要な複雑さ**: 本質的な意味を持たない構造を内包しているようなソフトウェア

``` swift
protocol MessageSenderAPIProtocol {
    // メッセージ送信には関係ない
    func fetchAll(ofUserId: Int, completion: ...)
    // メッセージ送信には関係ない
    func fetch(id: Int, completion: ...)
    func sendTextMessage(text: String, completion: ...)
    func sendImageMessage(image: UIImage, text: String?, completion: ...)
}
```

#### インターフェース分離の原則(Interface Segregation Principle)

**クライアントに、クライアントが利用しないメソッドへの依存を強制してはならない**

* ある型が、別の型に依存する複数のインターフェース(メソッドなど)を利用する場合に、そのすべてを利用することはあまりない
* 不要な依存は、変更の影響を受けやすくなるため、必要なものだけをグルーピングして抽象的に扱う

``` swift
// ユーザーの送信には本来関係ないofficialを除いて再定義する
enum SendableMessageType {
    case text
    case image
}

// 送信に関わるメソッドのみで再定義する
protocol MessageSenderAPIProtocol {
    func sendTextMessage(text: String, completion: ...)
    func sendImageMessage(image: UIImage, text: String?, completion: ...)
}
```

#### 開放閉鎖の原則(Open/Closed Principle)

**クラス(型)は拡張に対して開いていて、修正に対して閉じていなければならない**

* 拡張に対して開いている(Open): 使用要求が変更されても、モジュールに新たな振る舞いを追加することでその変更に対処できる
* 修正に対して閉じている(Closed): モジュールの振る舞いを拡張しても、そのソースコードやバイナリコードは影響を受けない

``` swift
// インターフェースを統一する
// caseが新しく増えても、MessageSenderのコードは一切変える必要がない
enum SendableMessageStrategy {
    case text(api: TextMessageSenderAPI, input: TextMessageInput)
    case image(api: ImageMessageSenderAPI, input: ImageMessageInput)

    mutating func update(input: Any) {
        ... // inputを置き換える
    }

    func send(completion: @escaping (Message?) -> Void) {
        ... // case毎に通信を行う
    }
}

// 通信状態を表すenum
enum State {
    case inputting(validationError: Error?)
    case sending
    case sent(Message)
    case connectionFailed
}
```

### コード改善後

``` swift
// 単一責任原則によって、複数なバリデーションを別の型に切り出した
// 依存関係逆転の原則によって、API通信の実装を差し替え可能にした
// インターフェース分離の原則によって、必要なインターフェースだけに依存させた
// 開放閉鎖原則によって、通信状態をenumで、メッセージの種別をgenericsで扱えるコードにした
protocol MessageInput {
    associatedType Payload
    func validate() throws -> Payload
}

protocol MessageSenderAPI {
    associatedType Payload
    associatedType Response: Message
    func send(
        payload: Payload,
        completion: @escaping (Response?) -> Void
    )
}

final class MessageSender<API: MessageSenderAPI, Input: MessageInput>
where API.Payload == Input.Payload {
    enum State {
        case inputting(validationError: Error?)
        case sending
        case sent(API.Response)
        case connectionFailed

        init(evaluating input: Input) {
            ...
        }

        mutating func accept(response: API.Response?) {
            ...
        }
    }

    private(set) var state: State {
        didSet {
            delegate?.stateの変化を伝える()
        }
    }

    var delegate: MessgaeSenderDelegate?

    var input: Input {
        didSet {
            state = State(evaluating: input)
        }
    }

    let api: API

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