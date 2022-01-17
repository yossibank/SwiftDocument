# 概要
アプリにおいて画面遷移の機能は必須の機能とも言えます。  
しかし、必須であるがゆえにどの画面においても画面遷移の処理を書く必要があり、その責務は一般的にView Controllerが受け持ちます。  
画面遷移したい場合にはView Controller内で次のView Controllerをインスタンス化し、Navigation ControllerへのpushやModalのpresentを行うのが一般的です。

```swift
extension ViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        /* 次のViewControllerに必要なデータ抽出 */
        let object = objects[indexPath.item]
        /* 次のViewControllerのインスタンス作成 */
        let nextVC = NextViewController(object: object)
        /* Navigation Controllerへのpush処理を実行 */
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
```

しかし裏を返すと、View Controllerは次のView Controllerのことを知っていることになります。  
遷移元のView Controllerと遷移先のView Controllerの関係が1対1である場合には大した問題にはなりません。  
ですがそのView Controllerを使い回したり、遷移先が複数存在するような場合、遷移先が特定のView Controllerに依存していることで、遷移ロジックが肥大化します。  
これを解決するためにView Controllerの上位レイヤーとして、画面遷移を管理するCoordinatorというものが生まれました。