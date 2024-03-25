import UIKit

final class WeatherTableCell: UITableViewCell {
    
    var dayLabel: UILabel = {
        var dayLabel = UILabel()
        dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dayLabel.textColor = .black
        return dayLabel
    }()
    
    var weatherImage: UIImageView = {
        var weatherImage = UIImageView()
        weatherImage.tintColor = .black
        weatherImage.contentMode = .scaleAspectFit
        return weatherImage
    }()
    
    var dayTempreture: UILabel = {
        var dayTempreture = UILabel()
        
        dayTempreture.textColor = .black
       return dayTempreture
    }()
    
    var nightTempreture: UILabel = {
        var nightTempreture = UILabel()
        
        nightTempreture.textColor = .lightGray
       return nightTempreture
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        [dayLabel, weatherImage, dayTempreture, nightTempreture].forEach { element in
            contentView.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.widthAnchor.constraint(equalToConstant: 120),
            
            weatherImage.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 30),
            weatherImage.widthAnchor.constraint(equalToConstant: 30),
            weatherImage.heightAnchor.constraint(equalToConstant: 30),
            weatherImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nightTempreture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nightTempreture.widthAnchor.constraint(equalToConstant: 44),
            nightTempreture.heightAnchor.constraint(equalToConstant: 44),
            nightTempreture.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            
            dayTempreture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayTempreture.widthAnchor.constraint(equalToConstant: 44),
            dayTempreture.heightAnchor.constraint(equalToConstant: 44),
            dayTempreture.leadingAnchor.constraint(equalTo: nightTempreture.leadingAnchor, constant: -65),
        ])
        
    }
    
}
