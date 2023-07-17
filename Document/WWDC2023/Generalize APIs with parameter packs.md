# Generalize APIs with parameter packs

## What parameter packs solve

``` swift
// 基本的には値と型の2つのカテゴリーで構成される
let x: Int = 10
func radians(from degrees: Double) -> Double

// genericsは値と型の両方を抽象化する
func query<Payload>(_ item: Request<Payload>) -> Payload

// 複数の値を渡したい時(variadics)
// 可変長引数は引数に渡された個数によって返却する値の型を変更することができない
func query(_ item: Request...) -> ???

// 可変長引数は静的型情報を保持することができない
func query(_ item: AnyRequest...) -> ???

// overloadingで実現する
func query<Payload>(
    _ item: Request<Payload>
) -> Payload

func query<Payload1, Payload2>(
    _ item1: Request<Payload1>,
    _ item2: Request<Payload2>
) -> (Payload1, Payload2)

func query<Payload1, Payload2, Payload3>(
    _ item1: Request<Payload1>,
    _ item2: Request<Payload2>,
    _ item3: Request<Payload3>
) -> (Payload1, Payload2, Payload3)

// 引数の個数を指定する必要がある
let _ = query(r1, r2, r3)
```

## How to read parameter packs

``` swift
// parameter packs
// 任意の数の値や型を保持し、それらをまとめて引数として渡すことができる
// Bool          Int            String
// true          10               ""
// position0     position1     position2

// parameter packsの宣言
func query<each Payload> // 単数形

// 個別のparameter packsの操作
repeat Request<each Payload>

// each Payload = Bool, Int, Stringとした時はそれぞれの型が順に展開される
(repeat Request<each Payload>)
(Request<Bool>, Request<Int>, Request<String>)

// genericsとしても使用できる
Generics<repeat Request<each Payload>>
Generics<Request<Bool>, Request<Int>, Request<String>>

// 以下の関数をparameter packsを用いて1つにまとめる
func query<Payload>(
    _ item: Request<Payload>
) -> Payload

func query<Payload1, Payload2>(
    _ item1: Request<Payload1>,
    _ item2: Request<Payload2>
) -> (Payload1, Payload2)

func query<Payload1, Payload2, Payload3>(
    _ item1: Request<Payload1>,
    _ item2: Request<Payload2>,
    _ item3: Request<Payload3>
) -> (Payload1, Payload2, Payload3)

func query<Payload1, Payload2, Payload3, Payload4>(
    _ item1: Request<Payload1>,
    _ item2: Request<Payload2>,
    _ item3: Request<Payload3>,
    _ item4: Request<Payload4>
) -> (Payload1, Payload2, Payload3, Payload4)

func query<each Payload>(
    _ item: repeat Request<each Payload>
) -> (repeat each Payload)

// 使用する際
let result = query(Request<Int>())
let results = query(Request<Int>(), Request<String>(), Request<Bool>())

// 型制約準拠
func query<each Payload: Equatable>(
    _ item: repeat Request<each Payload>
) -> (repeat each Payload)

func query<each Payload>(
    _ item: repeat Request<each Payload>
) -> (repeat each Payload) where repeat each Payload: Equatable

// 必ず1つの引数を要求する
func query<FirstPayload, each Payload>(
    _ first: Request<FirstPayload>,
    _ item: repeat Request<each Payload>
) -> (repeat each Payload) where FirstPayload: Equatable, repeat each Payload: Equatable
```

## Using parameter packs

``` swift
struct Request<Payload> {
    func evaluate() -> Payload
}

func query<each Payload>(
    _ item: repeat Request<each Payload>
) -> (repeat each Payload) {
    return (repeat (each item).evaluate())
}

// リファクタリング
protocol RequestsProtocol {
    associatedType Input
    associatedType Output
    func evaluate(_ input: Input) throws -> Output
}

struct Evaluator<each Request: RequestsProtocool> {
    var item: (repeat each Request)

    func query(_ input: repeat (each Request).Input) -> (repeat (each Request).Output)? {
        do {
            return (repeat (each item).evaluate(each input))
        } catch {
            return nil
        }
    }
}
```