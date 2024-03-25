import UIKit

public final class ExactWeatherModuleAssembly {
    public func build(locationName: String) -> UIViewController {
        let presenter = ExactWeatherPresenter(currentLocationName: locationName)
        let viewController = ExactWeatherVC(presenter: presenter)
        return viewController
    }
}
