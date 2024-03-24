import UIKit

final class NetworkClient {
    private let urlSession = URLSession.shared
    private var weatherTask: URLSessionTask?
    static let shared = NetworkClient()
    
    func fetchWeather(lat: String, lon: String, completion: @escaping LocalWeatherPresetnerCompletion) {
        assert(Thread.isMainThread)
        var request = weatherRequest(lat: lat, lon: lon)
        weatherTask = urlSession.object(urlSession: urlSession, for: request) { [weak self] (result: Result<WeatherResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let weather):
                    completion(.success(weather))
                    print(weather)
                case .failure(let error):
                    completion(.failure(error))
                    assertionFailure("\(error)")
                }
            }
        }
    }
    
    func weatherRequest(lat: String, lon: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "?lat=\(lat)&lon=\(lon)&exclude=hourly,minutely,alerts&units=metric&appid=d57f11ea72a6b9793fee32c98a1568a1",
            httpMethod: "get"
        )
    }
}
