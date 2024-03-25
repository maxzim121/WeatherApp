import UIKit

public final class LocalWeatherModuleAssembly {
    public func build() -> UIViewController {
        let presenter = LocalWeatherPresenter()
        let viewController = LocalWeatherVC(presenter: presenter)
        return viewController
    }
}

