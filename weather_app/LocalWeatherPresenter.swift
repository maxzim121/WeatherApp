import UIKit
import MapKit
import CoreLocation

enum LocalWeatherState {
    case initial, loading, failed(Error), data
}

typealias LocalWeatherPresetnerCompletion = (Result<WeatherResponse, Error>) -> Void

protocol LocalWeatherProtocol: AnyObject {
    func fetchAllWeather(location: CLLocationCoordinate2D)
    func getDailyWeather() -> [DailyWeather]
    func getCurrentWeather() -> CurrentWeather?
    func getCurrentLocation() -> String
    func currentLocation()
    func viewController(view: LocalWeatherVCProtocol)
}

final class LocalWeatherPresenter {
    
    private let networkClient = NetworkClient.shared
    let locationManager = CLLocationManager()
    
    private var allWaether: WeatherResponse? {
        didSet {
            currentWeather = allWaether?.current
            dailyWeather = allWaether?.daily
            dailyWeather?.remove(at: 0)
        }
    }
    private var state = LocalWeatherState.initial
    private var currentWeather: CurrentWeather?
    private var currentLocationName = ""
    private var dailyWeather: [DailyWeather]?
    weak var view: LocalWeatherVCProtocol?
    
    func locationFromCityName(cityName: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cityName
        let search = MKLocalSearch(request: request)
        search.start() { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                print(item.placemark.title)
                print((item.placemark.coordinate.longitude * 100) / 100)
                print(item.placemark.coordinate.latitude)
            }
        }
    }
    
}

extension LocalWeatherPresenter: LocalWeatherProtocol {
    
    func viewController(view: LocalWeatherVCProtocol) {
        self.view = view
    }
    
    func getCurrentLocation() -> String {
        return currentLocationName
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
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
    }
    
    func currentLocation() {
        print("Hello")
        guard let location = locationManager.location else { return }
        let geocoder = CLGeocoder()
        print("Hello2")
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let place = placemark.locality {
                    print(place)
                    print(placemark)
                    self.currentLocationName = place
                }
            }
        }
        fetchAllWeather(location: location.coordinate)
    }
    
    func getDailyWeather() -> [DailyWeather] {
        guard let dailyWeather = dailyWeather else { return []}
        return dailyWeather
    }
    
    
    func getCurrentWeather() -> CurrentWeather? {
        return currentWeather
    }
    
    
}



