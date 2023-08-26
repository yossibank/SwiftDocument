# Meet async/await in Swift

## Async/Await

1. 関数が非同期をマーク(async)する時、それを一時停止(サスペンド)することを許可する
2. 非同期関数の中で1回または何回もサスペンドする可能性がある箇所を指摘するためにasyncキーワードを使う
3. 非同期関数がサスペンドしている間、スレッドはブロックされない
4. 非同期関数が再開すると、呼び出した非同期関数から返された結果が元の関数に戻り、中断したところから実行が続けられる

``` swift
// クロージャ
// comletionで結果を返すのはSwiftで検知されない
// 開発者自身の操作に依存する
func fetchThumbnail(for id: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
    let request = thumbnailURLRequest(for: id)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
        } else if (response as? HTTPURLResponse)?.statusCode != 200 {
            completion(.failure(FetchError.badID))
        } else {
            guard let image = UIImage(data: data!) else {
                completion(.failure(FetchError.badImage))
                return
            }
            image.prepareThumbnail(of: CGSize(width: 40, height: 40)) { thumbnail in
                guard let thumbnail = thumbnail else {
                    completion(.failure(FetchError.badImage))
                    return
                }
                completion(.success(thumbnail))
            }
        }
    }
    task.resume()
}

// async/await
// 戻り値/エラーのスローでSwiftでのチェックを行えるようにする
func fetchThumbnail(for id: String) async throws -> UIImage {
    let request = thumbnailURLRequest(for: id)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badID }
    let maybeImage = UIImage(data: data)
    guard let thumbnail = await maybeImage?.thumbnail else { throw FetchError.badImage }
    return thumbnail
}
```

## Concurrencyのテスト

``` swift
// クロージャ
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() throws {
        let expectation = XCTestExpectation(description: "mock thumbnails completion")

        self.mockViewModel.fetchThumbnail(for: mockID) { result, error in
            XCTAssertEqual(result?.size, CGSize(width: 40, height: 40))
            expectation.fullfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

// async/await
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() async throws {
        let result = try await self.mockViewModel.fetchThumbnail(for: mockID)
        XCTAssertEqual(result?.size, CGSize(width: 40, height: 40))
    }
}
```