# 概要
アプリにおいて画面遷移の機能は必須の機能とも言えます。  
しかし、必須であるがゆえにどの画面においても画面遷移の処理を書く必要があり、その責務はViewControllerで受け持つことが多いかと思います。  
この画面遷移の責務をViewControllerから切り分けるために生まれたのがCoordinatorパターンになります。  
そしてこのCoordinatorパターンをよりシンプルな形にしたのがFlowControllerという概念になります。  
FlowControllerはUIViewControllerを継承したCoordinatorとも言えます。  

## Container ViewControllerとしてのFlowController
基本的にFlowControllerはComposition(構成)という単純な概念に基づいて、Sequence(あらかじめ決められた順序で処理)を解決するためのContainer的ViewControllerに過ぎません。  
そのフローの中で多くのViewControllerを管理します。  
例えば、商品の表示に関するフローをまとめるProductFlowController、そしてProductListController、ProductDetailController、ProductAuthorController、ProductMapControllerがあったとします。  
それぞれのControllerはProductFlowControllerにDelegate(処理を委譲)することで「商品がタップされた」などの意思表示をし、ProductFlowControllerがその中に埋め込まれたUINavigationControllerを元にフロー内の次の画面を構築して表示することができるようにします。通常FlowControllerは一度に1つの子FlowControllerを表示するだけなので、通常はそのフレームを更新するだけで良いです。

```swift
final class AppFlowController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        childViewControllers.first?.view.frame = view.bounds
    }
}
```

## 依存関係ContainerとしてのFlowController
フロー内の各ViewControllerは、それぞれ異なる依存関係を持つことができます。  
したがって、最初のViewControllerが次のViewControllerに受け渡すために全てのものを渡す必要があるとすれば、それは公平でありません。  
以下は、いくつかの依存関係です。  

* ProductListController: ProductNetworkingService
* ProductDetailController: ProductNetworkingService, ImageDownloaderService, ProductEditService
* ProductAuthorController: AuthorNetworkingService, ImageDownloaderService
* ProductMapController: LocationService, MapService

FlowControllerはそのフロー全体に必要な依存関係を全て運ぶことができるので、必要に応じてViewControllerに渡すことができます。  

```swift
struct ProductDependencyContainer {
    let productNetworkingService: ProductNetworkingService
    let imageDownloaderService: ImageDownloaderService
    let productEditService: ProductEditService
    let authorNetworkingService: AuthorNetworkingService
    let locationService: LocationService
    let mapService: MapService
}

class ProductFlowController {
    let dependencyContainer: ProductDependencyContainer

    init(dependencyContainer: ProductDependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
}

extension ProductFlowController: ProductListControllerDelegate {
    func productListController(_ controller: ProductListController, didSelect product: Product) {
        let productDetailController = ProductDetailController(
            productNetworkingService: dependencyContainer.productNetworkingService,
            productEditService: dependencyContainer.productEditService,
            imageDownloaderService: dependencyContainer.imageDownloaderService
        )
        productDetailController.delegate = self
        embbedNavigationController.pushViewController(productDetailController, animated: true)
    }
}
```

## 追加または削除できる子FlowController
- Coorinatorの場合
Coordinatorでは子Coordinatorの配列を保持し、それをアドレス(`===`演算子)を用いて識別する必要があります。  

```swift
class Coordinator {
    private var children: [Coordinator] = []

    func add(child: Coordinator) {
        guard !children.contains(where: { $0 === child }) else {
            return
        }
        children.append(child)
    }

    func remove(child: Coordinator) {
        guard let index = children.index(where: { $0 === child }) else {
            return
        }
        children.remove(at: index)
    }

    func removeAll() {
        children.removeAll()
    }
}
```

- FlowControllerの場合
FlowControllerはUIViewControllerのサブクラスであるので、子FlowControllerを全て保持するViewControllerを持っています。  
そのため、以下の拡張を追加するだけで子FlowControllerの追加や削除が簡単にできます。  

```swift
extension UIViewController {

    func add(childController: UIViewController) {
        addChild(childController)               /* 引数のViewControllerを現在のViewControllerの子要素として追加する */
        view.addSubView(childController.view)   /* 現在のViewControllerのViewに引数のViewControllerのViewを追加する */
        childController.didMove(toParent: self) /* 処理が終了したことを伝える */
    }

    func remove(childController: UIViewController) {
        childController.willMove(toParent: nil)    /* removeFromParent()を呼ぶ前に親の値としてnilを渡す必要がある */
        childController.view.removeFromSuperview() /* addSubViewしたViewを削除する */
        childController.removeFromParent()         /* ViewControllerを親要素から削除する */
    }
}
```

これらを作成することで`AppFlowController`ではこのように動作させることができます。

```swift
final class AppFlowController: UIViewController {

    func start() {
        if authService.isAuthenticated {
            startMain()
        } else {
            startLogin()
        }
    }

    private func startLogin() {
        let loginFlowController = LoginFlowController()
        loginFlowController.delegate = self
        add(childController: loginFlowController)
        loginFlowController.start()
    }

    private func startMain() {
        let mainFlowController = MainFlowController()
        mainFlowController.delegate = self
        add(childController: mainFlowController)
        mainFlowController.start()
    }
}　

extension AppFlowController: LoginFlowControllerDelegate {

    func loginFlowControllerDidFinish(_ flowController: LoginFlowController) {
        remove(childController: flowController)
        startMain()
    }
}
```

## AppFlowControllerはUIWindowについて知る必要はない
- Coordinatorの場合
通常、AppDelegateが保持するAppCoordinatorをCoordinatorのルートとして保持する。  
例えば、ログイン状況に応じてLoginControllerとMainControllerのどちらをrootViewControllerとして設定するかを決める場合、そのためにはUIWindowをinjectionする必要がある。  

```swift
window = UIWindow(frame: UIScreen.main.bounds)
appCoordinator = AppCoordinator(window: window!)
appCoordinator.start()
window?.makeKeyAndVisible()

final class AppCoordinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    /* window?.makeKeyAndVisible()が呼ばれる前にrootViewControllerを設定する必要がある */
    func start() {
        if dependencyContainer.authService.isAuthenticated {
            startMain()
        } else {
            startLogin()
        }
    }
}
```

- FlowControllerの場合
通常のUIViewControllerを同様に扱えるので、FlowControllerをrootViewControllerとして設定するだけで良い。

```swift
appFlowController = AppFlowController()
window = UIWindow(frame: UIScreen.main.bounds)
window?.rootViewController = appFlowController
window?.makeKeyAndVisible()

appFlowController.start()
```

## LoginFlowControllerは独自のフローを管理できる
UINavigationControllerをベースとしたログインフローがあり、LoginController, ForgetPasswordController, SignUpControllerを表示できるとする。

- Coordinatorの場合
LoginCoordinatorのstart()では何をすべきでしょうか。  
LoginControllerを初期化して、UINavigationControllerのrootViewControllerに設定することでしょうか？  
LoginCoordinatorは内部でこの埋め込みUINavigationControllerを作成することができますが、その場合、UIWindowは親のAppCoordinatorの中で非公開(private)になっているので、UIWindowのrootViewControllerにはアタッチできません。

```swift
final class AppCoordinator: Coordinator {
    private let window: UIWindow

    private func startLogin() {
        let navigationController = UINavigationController()
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        add(child: loginCoordinator)
        window.rootViewController = navigationController
        loginCoordinator.start()
    }
}

final class LoginCoordinator: Coordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let loginController = LoginController(dependencyContainer: dependencyContainer)
        loginController.delegate = self

        navigationController.viewControllers = [loginController]
    }
}
```

- FlowControllerの場合
LoginFlowControllerはContainerViewControllerを利用しているため、UIKitの動作に上手くフィットします。  
AppFlowControllerはLoginFlowControllerを追加し、LoginFlowControllerはembeddedNavigatgionControllerを作成するだけで済みます。  

```swift
final class AppFlowController: UIViewController {

    private func startLogin() {
        let loginFlowController = LoginFlowController(dependencyContainer: dependencyContainer)
        loginFlowController.delegate = self
        add(childViewController: loginFlowController)
        loginFlowController.start()
    }
}

final class LoginFlowController: UIViewController {
    private let dependencyContainer: DependencyContainer
    private var embeddedNavigationController: UINavigationController!
    weak var delegate: LoginFlowControllerDelegate?

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        suprt.init(nibName: nil, bundle: nil)

        embeddedNavigationController = UINavigationController()
        add(childController: embeddedNavigationController)
    }

    func start() {
        let loginController = LoginController(dependencyContainer: dependencyContainer)
        loginController.delegate = self

        embeddedNavigationController.viewControllers = [loginController]
    }
}
```

## FlowControllerとResponder Chain
* Responder Chain
- 外側からユーザ操作として発生したイベントが送信されるオブジェクト(シングルタップやダブルタップ、スワイプなどのジェスチャ...)

- Coordinatorの場合
時には、親Coordinatorに処理をバブルアップ(徐々に階層を上げていく)する素早い方法が必要です。  
その方法の一つとして、関連するオブジェクトとプロトコル拡張を使用堤UIReponsderチェーンを複製することで、Coordinatorとの相互接続を行います。  

```swift
extension UIViewController {

    private struct AssociatedKeys {
        static var parentCoordinator = "ParentCoordinator"
    }

    public var parentCoordinator: Any? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.parentCoordinator)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.presentCoordinator, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

open class Coordinator<T: UIViewController>: UIResponder, Coordinating {
    open var parent: Coordinating?

    override open var coordinatingResponder: UIResponder? {
        parent as? UIResponder
    }
}
```

- FlowControllerの場合
FlowControllerはUIResponderを継承したUIViewControllerであるため、Responder Chainはすぐに発生します。  

## FlowControllerとTrait Collection
- FlowController
FlowControllerは親ViewControllerであるため、そのtrait collectionをオーバーライドすれば、そのフロー内全てのViewControllerのサイズクラスに影響を与えることができます。  

```swift
let trait = UITraitCollection(traitsFrom: [
    .init(horizontalSizeClass: .compact),
    .init(verticalSizeClass: .regular),
    .init(userInterfaceIdiom: .phone)
])

appFlowController.setOverrideTraitCollection(trait, forChildViewController: loginFlowController)
```

## FlowControllerとBack Button
- Coordinatorの場合
UINavigationControllerの問題点として、デフォルトの戻るボタンをクリックすると、ナビゲーションスタックからViewControllerがポップアウトし、そしてCooridnatorはそのことを意識していません。  
Coordinatorの場合は、CooridnatorとUIViewControllerを同期させ、UINavigationControllerDelegateをフックして処理する必要があります。  

```swift
extension Coordinator: UINavigationControllerDelegate {

    func navigationController(
        navigationController: UINavigationController,
        didShowViewController viewController: UIVIewController, 
        animated: Bool
    ) {
        /* ensure the viewController is poping */
        guard
            let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController)
        else {
            return
        }

        /* and it's the right type */
        if fromViewController is FirstViewControllerInCoordinator {
            /* deallocate the relevant coordinator */
        }
    }
}
```

あるいは、NavigationControllerというクラスを作成し、内部で子Coordinatorのリストを管理するようにします。  

```swift
final class NavigationController: UIViewController {

    // MARK: - Inputs

    private let rootViewController: UIViewController

    // MARK: - Mutable state

    private var viewControllersToChildCoordinators: [UIViewController: Coordinator] = [:]

    // MARK: - Lazy views

    private lazy var childNavigationController: UINavigationController = UInavigationController(
        rootViewController: self.rootViewController
    )

    // MARK: - Initialization

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }
}

```

- FlowControllerの場合
FlowControllerは単なるUIViewControllerであるため、子FlowControllerを手動で管理する必要はありません。  
子FlowControllerはpopやdismissをすることで削除されます。  
UINavigationControllerのイベントをリスニングしたい場合は、FlowControllerの内部で処理するだけになります。  

```swift
final class LoginFlowController: UIViewController {
    private let dependencyContainer: DependencyContainer
    private var embeddedNavigationController: UINavigationController!
    weak var delegate: LoginFlowControllerDelegate?

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        suprt.init(nibName: nil, bundle: nil)

        embeddedNavigationController = UINavigationController()
        embeddedNavigationController.delegate = self
        add(childController: embeddedNavigationController)
    }

    func start() {
        let loginController = LoginController(dependencyContainer: dependencyContainer)
        loginController.delegate = self

        embeddedNavigationController.viewControllers = [loginController]
    }
}

extension LoginFlowController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController, 
        willShow viewController: UIViewController, 
        animated: Bool
    ) {
        /* handling */
      }
}
```

## FlowControllerとcallback
- FlowController
デリゲートパターンを使って、FlowControllerにフロー内の別のViewControllerを表示するように通知することができます。  

```swift
extension ProductFlowController: ProductListControllerDelegate {

    func productListController(_ controller: ProductListController, didSelect product: Product) {
        let productDetailController = ProductDetailController(
            productNetworkingService: dependencyContainer.productNetworkingService,
            productEditService: dependencyContainer.productEditService,
            imageDownloaderService: dependencyContainer.imageDownloaderService
        )

        productDetailController.delegate = self
        embeddedNavigationController.pushViewController(
            productDetailController,
            animated: true
        )
    }
}

final class ProductFlowController {

    func start() {
        let productListController = ProductListController(
            productNetworkingService: dependencyContainer.productNetworkingService
        )

        productListController.didSelectProduct = { [weak self] product in
            self?.showDetail(for: product)
        }

        embeddedNavigationController.viewControllers = [productListController]
    }
}
```