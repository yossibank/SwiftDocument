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