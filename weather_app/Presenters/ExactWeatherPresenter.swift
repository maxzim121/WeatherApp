import Foundation
import MapKit
import CoreLocation

protocol ExactWeatherProtocol: AnyObject {
    func getDailyWeather() -> [DailyWeather]
    func viewController(view: ExactWeatherVCProtocol)
    func locationFromCityName()
}

final class ExactWeatherPresenter {
    
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
    private var currentLocationName: String
    private var dailyWeather: [DailyWeather]?
    weak var view: ExactWeatherVCProtocol?
    
    init(currentLocationName: String) {
        self.currentLocationName = currentLocationName
    }
    
    func correctNameOfLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                if let place = placemark.locality {
                    self.currentLocationName = place
                    self.view?.setLocationName(locationName: self.currentLocationName)
                }
            }
        }
    }
    
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
            case .failure(_):
                self.view?.showAlert()
            }
        }
    }
}

extension ExactWeatherPresenter: ExactWeatherProtocol {
    
    func locationFromCityName() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = currentLocationName
        let search = MKLocalSearch(request: request)
        search.start() { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                self.view?.showAlert()
                return
            }
            var finalLocation = CLLocation()

            for item in response.mapItems {
                guard let location = item.placemark.location else { return }
                finalLocation = location
            }
            self.correctNameOfLocation(location: finalLocation)
            self.fetchAllWeather(location: finalLocation.coordinate)
        }
    }
    
    func getDailyWeather() -> [DailyWeather] {
        guard let dailyWeather = dailyWeather else { return []}
        return dailyWeather
    }
    
    func viewController(view: ExactWeatherVCProtocol) {
        self.view = view
    }
}
