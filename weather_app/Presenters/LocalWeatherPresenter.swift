import Foundation
import MapKit
import CoreLocation

typealias WeatherPresetnerCompletion = (Result<WeatherResponse, Error>) -> Void

protocol LocalWeatherProtocol: AnyObject {
    func getDailyWeather() -> [DailyWeather]
    func viewController(view: LocalWeatherVCProtocol)
    func exactModuleAssembly(locationName: String) -> UIViewController
    func setCLManagerDelegate()
}

final class LocalWeatherPresenter: NSObject {
    
    private let networkClient = NetworkClient.shared
    let locationManager = CLLocationManager()
    
    private var allWaether: WeatherResponse? {
        didSet {
            currentWeather = allWaether?.current
            dailyWeather = allWaether?.daily
            dailyWeather?.remove(at: 0)
        }
    }
    private var currentWeather: CurrentWeather?
    private var currentLocationName = ""
    private var dailyWeather: [DailyWeather]?
    weak var view: LocalWeatherVCProtocol?
    
    func fetchAllWeather(location: CLLocationCoordinate2D) {
        let lat = String(describing: location.latitude)
        let lon = String(describing: location.longitude)
        networkClient.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weather):
                self.allWaether = weather
                self.view?.dataForUI(currentWeather: weather.current)
                self.view?.reloadData()
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
    }
    
    func currentLocation() {
        guard let location = locationManager.location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let place = placemark.locality {
                    self.currentLocationName = place
                    self.view?.setCurrentLocationLabel(locationName: self.currentLocationName)
                }
            }
        }
        fetchAllWeather(location: location.coordinate)
    }
}

extension LocalWeatherPresenter: LocalWeatherProtocol {
    
    func getDailyWeather() -> [DailyWeather] {
        guard let dailyWeather = dailyWeather else { return []}
        return dailyWeather
    }
    
    func setCLManagerDelegate() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func exactModuleAssembly(locationName: String) -> UIViewController {
        let exactModule = ExactWeatherModuleAssembly()
        return exactModule.build(locationName: locationName)
    }
    
    func viewController(view: LocalWeatherVCProtocol) {
        self.view = view
    }
}

extension LocalWeatherPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            currentLocation()
        case .denied, .restricted:
            view?.showAlert()
        default:
            break
        }
    }
}



