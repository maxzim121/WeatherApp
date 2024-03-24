import UIKit

protocol LocalWeatherVCProtocol: AnyObject {
    func dataForUI(currentWeather: CurrentWeather?)
    func reloadData()
    func showAlert()
}

class LocalWeatherVC: UIViewController {
    
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Введите город"
        return searchBar
    }()
    
    private lazy var myLocationLabel: UILabel = {
        var myLocationLabel = UILabel()
        myLocationLabel.text = "My Location"
        myLocationLabel.font = .systemFont(ofSize: 30, weight: .bold)
       return myLocationLabel
    }()
    
    private lazy var exactLocationLabel: UILabel = {
        var exactLocationLabel = UILabel()
        exactLocationLabel.text = "Loading..."
        exactLocationLabel.font = .systemFont(ofSize: 15)
        return exactLocationLabel
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
        paramsStack.axis = .horizontal
        return paramsStack
    }()
    
    private lazy var windParams: ParamsStackView = {
        var windParams = ParamsStackView()
        windParams.paramIcon.image = UIImage(systemName: "wind")
        windParams.param.text = "--m/s"
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
        visibilityParams.param.text = "--km"
        return visibilityParams
    }()
    
    private lazy var humidityParams: ParamsStackView = {
        var humidityParams = ParamsStackView()
        humidityParams.paramIcon.image = UIImage(systemName: "humidity")
        humidityParams.param.text = "--%"
        return humidityParams
    }()
    
    private lazy var dailyWeather: UITableView = {
        var dailyWeather = UITableView()
        dailyWeather.register(LocalWeatherTableCell.self, forCellReuseIdentifier: "LocalWeather")
        dailyWeather.backgroundColor = .systemGroupedBackground
        dailyWeather.layer.cornerRadius = 16
        dailyWeather.separatorStyle = .none
        return dailyWeather
    }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    private let networkClient = NetworkClient.shared
    private let presenter: LocalWeatherProtocol
    
    init(presenter: LocalWeatherPresenter) {
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
        searchBar.delegate = self
        view.backgroundColor = .white
        configureConstraints()
        presenter.viewController(view: self)
        presenter.currentLocation()
    }
    
    func configureConstraints() {
        
        [searchBar ,myLocationLabel, exactLocationLabel, mainTempreture, paramsStack, dailyWeather].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [windParams, cloudParams, humidityParams, visibilityParams].forEach {
            paramsStack.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            myLocationLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            myLocationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            exactLocationLabel.topAnchor.constraint(equalTo: myLocationLabel.bottomAnchor, constant: 10),
            exactLocationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mainTempreture.topAnchor.constraint(equalTo: exactLocationLabel.bottomAnchor, constant: 10),
            mainTempreture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            paramsStack.topAnchor.constraint(equalTo: mainTempreture.bottomAnchor, constant: 10),
            paramsStack.heightAnchor.constraint(equalToConstant: 93),
            paramsStack.widthAnchor.constraint(equalToConstant: 266),
            paramsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            dailyWeather.topAnchor.constraint(equalTo: paramsStack.bottomAnchor, constant: 20),
            dailyWeather.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dailyWeather.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dailyWeather.heightAnchor.constraint(equalToConstant: 308)
            
        ])
    }

}

extension LocalWeatherVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension LocalWeatherVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dailyWeather = presenter.getDailyWeather()
        return dailyWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dailyWeather.dequeueReusableCell(withIdentifier: "LocalWeather") as? LocalWeatherTableCell else { return LocalWeatherTableCell()}
        let dailyWeather = presenter.getDailyWeather()
        let weatherForTheDay = dailyWeather[indexPath.row]
        let date = Date(timeIntervalSince1970: weatherForTheDay.dt)
        cell.dayLabel.text = self.dateFormatter.string(from: date).capitalizingFirstLetter()
        cell.weatherImage.image = weatherImages[weatherForTheDay.weather[0].description]
        
        let dayTemp = String(format: "%.0f", weatherForTheDay.temp.day.rounded())
        cell.dayTempreture.text = "\(dayTemp)˚"
        return cell
    }
    
}

extension LocalWeatherVC: LocalWeatherVCProtocol {
    func dataForUI(currentWeather: CurrentWeather?) {
        guard let currentWeather = currentWeather else { return }
        let currentLocation = presenter.getCurrentLocation()
        let degree = String(format: "%.0f", currentWeather.temp.rounded())
        mainTempreture.text = "\(degree)˚"
        exactLocationLabel.text = currentLocation
        windParams.param.text = "\(String(format: "%.0f", currentWeather.temp.rounded()))m/s"
        cloudParams.param.text = "\(currentWeather.clouds)%"
        humidityParams.param.text = "\(currentWeather.humidity)%"
        visibilityParams.param.text = "\(currentWeather.visibility/1000)km"
    }
    
    func reloadData() {
        dailyWeather.reloadData()
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "Нет доступа к локации",
            message: "Чтобы пользоваться прогнозом погоды по вашему местоположению нужно разрешить доступ к Геологации",
            preferredStyle: .actionSheet
        )
        let alertAction = UIAlertAction(
            title: "Пользоваться без местоположения",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
}

extension LocalWeatherVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text)
    }
}
