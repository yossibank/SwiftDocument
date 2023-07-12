# Meet Swift OpenAPI Generator

## Exploring OpenAPI

* **OpenAPI**
  * API定義を手助けする様々な機能を提供するサービス

``` swift
// OpenAPIなしでのAPI呼び出し
let baseURL = "http://example.com/api"

guard var urlComponents = URLComponents(string: baseURL) else {
    throw APIError("Invalid server URL: \(baseURL)")
}

urlComponents.path.append("/greet")
urlComponents.queryItems = [URLQueryItem(name: "name", value: "Jane")]

guard let url = urlComponents.url else {
    throw APIError("Invalid API endpoint: \(urlComponents)")
}

let urlRequest = URLRequest(url: url)
let (data, response) = try await URLSession.shared.dataTask(for: urlRequest)

guard let httpResponse = response as? HTTPURLResponse else {
    throw APIError("API response not HTTP Response")
}

guard let httpResponse.statusCode == 200 else {
    throw APIError("Unexpected status code: \(httpResponse.statusCode)")
}

if let contentType = httpResponse.value(forHTTPHeaderField: "content-type") {
    guard contentType.lowercased() == "application/json" else {
        throw APIError("Unexpected content type: \(contentType)")
    }
}

struct Greeting: Decodable {
    var message: String
}

let greeting: Greeting

do {
    greeting = try JSONDecoder().decode(Gretting.self, from: data)
} catch {
    throw APIError("Unexpected response body, error: \(error.localizedDescription)")
}

print(greeting.message)
```

``` swift
// OpenAPIで呼び出す
openapi: "3.0.3"
info:
    title: "GreetingService"
    version: "1.0.0"
servers:
    - url: "http://localhost:8080/api"
      description: "Production"
paths:
    /greet:
        get:
            operationId: "getGreeting"
            parameters:
            - name: "name"
              required: false
              in: "query"
              description: "Personalizes the greeting."
              schema:
                type: "string"
            responses:
                "200":
                    description: "Returns a greeting"
                    content:
                        application/json:
                            schema:
                                $ref: "#/components/schemas/Gretting"


switch try await client.getGreeting(Operations.getGreeting.Input(
    query: Operations.getGreeting.Input.Query(name: "Jane")
)) {
    case .ok(let response):
        switch response.body {
        case .json(let greeting):
            print(greeting.message)
        }
}
```

## Making API calls from your app

``` swift
// GET https://localhost:8080/api/emoji
// ランダムに10種類の猫の絵文字を返すAPI
// 😻😸😽😺😹😼🙀😿😾🐱

// 「Projects」 → 「Package Dependencies」 → 「swift-openapi-package」
// 「Targets」 → 「Build Phases」 → 「Run Build Tool Plug-ins」
// OpenAPIドキュメントとプラグイン設定ファイル追加

// Viewの置き換え
import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView: View {
    @State private var emoji = "😄"

    var body: some View {
        VStack {
            Text(emoji)
                .font(.system(size: 100))

            Button("Get cat!") {
                Task {
                    try? await updateEmoji()
                }
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }

    let client: Client

    init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport()
        )
    }

    func updateEmoji() async throws {
        let response = try await client.getEmoji(Operations.getEmoji.Input())

        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case let .text(text):
                emoji = text
            }

        case .undocumented(statusCode: let statusCode, _):
            print("cat-astrophe: \(statusCode)")
            emoji = "🐵"
        }
    }
}
```

## Adapting as the API evolves

* **OpenAPIドキュメントの更新に対するアプリ適用**

``` swift
// queryの適用
// GET https://localhost:8080/api/emoji?count=5
// 😻😻😻😻😻

// openapi.yaml更新
openapi: "3.0.3"
info:
    title: CatService
    version: 1.0.0
servers:
    - url: "http://localhost:8080/api"
      description: "Localhost cats 🙀"
paths:
    /emoji:
        get:
            operationId: getEmoji
            parameters:
            - name: count
              required: false
              in: query
              description: "The number of cats to return 😽😽😽"
              schema:
                type: integer
            responses:
                "200":
                    description: "Returns a random emoji, of a cat, ofc! 😻"
                    content:
                        text/plain:
                            schema:
                                type: string


// UI更新
struct ContentView: View {
    @State private var emoji = "😄"

    var body: some View {
        VStack {
            Text(emoji)
                .font(.system(size: 100))

            Button("Get cat!") {
                Task {
                    try? await updateEmoji()
                }
            }

            Button("More cats!") {
                Task {
                    try? await updateEmoji(count: 3)
                }
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }

    let client: Client

    init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport()
        )
    }

    func updateEmoji(count: Int = 1) async throws {
        let response = try await client.getEmoji(Operations.getEmoji.Input(
            query: Operations.getEmoji.Input.Query(count: count)
        ))

        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case let .text(text):
                emoji = text
            }

        case .undocumented(statusCode: let statusCode, _):
            print("cat-astrophe: \(statusCode)")
            emoji = "🐵"
        }
    }
}
```

## Testing your app with mocks

* **Mockを使用したAPIテスト**

``` swift
// Mockの生成
struct MockClient: APIProtocol {
    func getEmoji(_ input: Operations.getEmoji.Input) async throws -> Operations.getEmoji.Output {
        let count = input.query.count ?? 1
        let emojis = String(repeating: "🤖", count: count)

        return .ok(Operations.getEmoji.Output.Ok(
            body: .text(emojis)
        ))
    }
}

// View(Preview)への適用
#Preview {
    ContentView(client: MockClient())
}

struct ContentView<C: APIProtocol>: View {
    @State private var emoji = "😄"

    var body: some View {
        VStack {
            Text(emoji)
                .font(.system(size: 100))

            Button("Get cat!") {
                Task {
                    try? await updateEmoji()
                }
            }

            Button("More cats!") {
                Task {
                    try? await updateEmoji(count: 3)
                }
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }

    let client: C

    init(client: C) {
        self.client = client
    }

    init() where C == Client {
        self.client = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport()
        )
    }

    func updateEmoji(count: Int = 1) async throws {
        let response = try await client.getEmoji(Operations.getEmoji.Input(
            query: Operations.getEmoji.Input.Query(count: count)
        ))

        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case let .text(text):
                emoji = text
            }

        case .undocumented(statusCode: let statusCode, _):
            print("cat-astrophe: \(statusCode)")
            emoji = "🐵"
        }
    }
}
```

## Server development in Swift

* **SwiftでのOpenAPI Server**

``` swift
import Foundation
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

struct Handler: APIProtocol {
    func getEmoji(_ input: Operations.getEmoji.Input) async throws -> Operations.getEmoji.Output {
        let candidates = "😻😸😽😺😹😼🙀😿😾🐱"
        let chosen = String(candidates.randomElement()!)
        let count = input.query.count ?? 1
        let emojis = String(repeating: chosen, count: count)
        return .ok(Operations.getEmoji.Output.Ok(body: .text(emojis)))

        return .ok(Operations.getEmoji.Output.Ok(
            body: .text(emojis)
        ))
    }
}

@main
struct CatService {
    public static func main() throws {
        let app = Vapor.Application()
        let transport = VaporTransport(routesBuilder: app)
        let handler = Handler()
        try handler.registerHandlers(on: transport, serverURL: Servers.server1())
        try app.run()
    }
}
```