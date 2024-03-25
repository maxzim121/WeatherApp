import UIKit

protocol ExactWeatherVCProtocol: AnyObject {
    func dataForUI(currentWeather: CurrentWeather?)
    func reloadData()
    func showAlert()
    func setLocationName(locationName: String)
}

class ExactWeatherVC: UIViewController {
    
    private lazy var locationLabel: UILabel = {
        var locationLabel = UILabel()
        locationLabel.text = NSLocalizedString("loading", comment: "")
        locationLabel.font = .systemFont(ofSize: 30, weight: .bold)
       return locationLabel
    }()
    
    private lazy var mainTempreture: UILabel = {
        var mainTepreture = UILabel()
        mainTepreture.text = "--˚"
        mainTepreture.textAlignment = .center
        mainTepreture.font = .systemFont(ofSize: 70)
        return mainTepreture
    }()
    
    private lazy var paramsStack: UIStackView = {
        var paramsStack = UIStackView()
        paramsStack.distribution = .fillEqually
        paramsStack.spacing = 30
        paramsStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        paramsStack.isLayoutMarginsRelativeArrangement = true
        paramsStack.layer.cornerRadius = 16
        paramsStack.layer.borderWidth = 2
        paramsStack.layer.borderColor = UIColor.lightGray.cgColor
        paramsStack.axis = .horizontal
        return paramsStack
    }()
    
    private lazy var windParams: ParamsStackView = {
        var windParams = ParamsStackView()
        windParams.paramIcon.image = UIImage(systemName: "wind")
        windParams.param.text = "--\(NSLocalizedString("metersPerSecond", comment: ""))"
        return windParams
    }()
    
    private lazy var cloudParams: ParamsStackView = {
        var cloudParams = ParamsStackView()
        cloudParams.paramIcon.image = UIImage(systemName: "cloud")
        cloudParams.param.text = "--%"

        return cloudParams
    }()
    
    private lazy var visibilityParams: ParamsStackView = {
        var visibilityParams = ParamsStackView()
        visibilityParams.paramIcon.image = UIImage(systemName: "eye")
        visibilityParams.param.text = "--\(NSLocalizedString("kilometers", comment: ""))"
        return visibilityParams
    }()
    
    private lazy var humidityParams: ParamsStackView = {
        var humidityParams = ParamsStackView()
        humidityParams.paramIcon.image = UIImage(systemName: "humidity")
        humidityParams.param.text = "--%"
        return humidityParams
    }()
    
    private lazy var dailyWeatherLabel: UILabel = {
        var dailyWeatherLabel = UILabel()
        dailyWeatherLabel.font = .systemFont(ofSize: 20, weight: .bold)
        dailyWeatherLabel.text = NSLocalizedString("weatherForTheWeek", comment: "")
        return dailyWeatherLabel
    }()
    
    private lazy var dailyWeather: UITableView = {
        var dailyWeather = UITableView()
        dailyWeather.register(WeatherTableCell.self, forCellReuseIdentifier: "LocalWeather")
        dailyWeather.backgroundColor = .systemGroupedBackground
        dailyWeather.layer.cornerRadius = 16
        dailyWeather.layer.borderWidth = 2
        dailyWeather.layer.borderColor = UIColor.lightGray.cgColor
        dailyWeather.separatorStyle = .none
        return dailyWeather
    }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    private let networkClient = NetworkClient.shared
    private let presenter: ExactWeatherProtocol
    
    init(presenter: ExactWeatherPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dailyWeather.delegate = self
        dailyWeather.dataSource = self
        view.backgroundColor = .white
        configureConstraints()
        presenter.viewController(view: self)
        presenter.locationFromCityName()
    }
    
    func configureConstraints() {
        
        [locationLabel, mainTempreture, paramsStack, dailyWeatherLabel, dailyWeather].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [windParams, cloudParams, humidityParams, visibilityParams].forEach {
            paramsStack.addArrangedSubview($0)
        }
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mainTempreture.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            mainTempreture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            paramsStack.topAnchor.constraint(equalTo: mainTempreture.bottomAnchor, constant: 10),
            paramsStack.heightAnchor.constraint(equalToConstant: 93),
            paramsStack.widthAnchor.constraint(equalToConstant: 298),
            paramsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dailyWeatherLabel.bottomAnchor.constraint(equalTo: dailyWeather.topAnchor, constant: -10),
            dailyWeatherLabel.leadingAnchor.constraint(equalTo: dailyWeather.leadingAnchor),
            
            dailyWeather.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            dailyWeather.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dailyWeather.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dailyWeather.heightAnchor.constraint(equalToConstant: 308)
        ])
    }
    
    func configureAlert() {
        let alertController = UIAlertController(
            title: NSLocalizedString("searchAlertTitel", comment: ""),
            message: NSLocalizedString("searchAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(
            title: NSLocalizedString("searchAlertAction", comment: ""),
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
            self.dismiss(animated: true)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
}

extension ExactWeatherVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ExactWeatherVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dailyWeather = presenter.getDailyWeather()
        return dailyWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dailyWeather.dequeueReusableCell(withIdentifier: "LocalWeather") as? WeatherTableCell else { return WeatherTableCell()}
        let dailyWeather = presenter.getDailyWeather()
        let weatherForTheDay = dailyWeather[indexPath.row]
        let date = Date(timeIntervalSince1970: weatherForTheDay.dt)
        cell.dayLabel.text = self.dateFormatter.string(from: date).capitalizingFirstLetter()
        cell.weatherImage.image = weatherImages[weatherForTheDay.weather[0].description]
        
        let dayTemp = String(format: "%.0f", weatherForTheDay.temp.day.rounded())
        cell.dayTempreture.text = "\(dayTemp)˚"
        let nightTemp = String(format: "%.0f", weatherForTheDay.temp.night.rounded())
        cell.nightTempreture.text = "\(nightTemp)˚"
        return cell
    }
}

extension ExactWeatherVC: ExactWeatherVCProtocol {
    func dataForUI(currentWeather: CurrentWeather?) {
        guard let currentWeather = currentWeather else { return }
        let degree = String(format: "%.0f", currentWeather.temp.rounded())
        mainTempreture.text = "\(degree)˚"
        windParams.param.text = "\(String(format: "%.0f", currentWeather.temp.rounded()))\(NSLocalizedString("metersPerSecond", comment: ""))"
        cloudParams.param.text = "\(currentWeather.clouds)%"
        humidityParams.param.text = "\(currentWeather.humidity)%"
        if let visibility = currentWeather.visibility {
            visibilityParams.param.text = "\(visibility/1000)\(NSLocalizedString("kilometers", comment: ""))"
        } else { return }
    }
    
    func setLocationName(locationName: String) {
        locationLabel.text = locationName
    }
    
    func reloadData() {
        dailyWeather.reloadData()
    }
    
    func showAlert() {
        configureAlert()
    }
}
