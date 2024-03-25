import UIKit

class ParamsStackView: UIStackView {
    
    lazy var paramIcon: UIImageView = {
        var paramIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        paramIcon.tintColor = .black
        paramIcon.contentMode = .scaleAspectFit
        return paramIcon
    }()
    
    lazy var param: UILabel = {
        var param = UILabel()
        param.textAlignment = .center
        param.font = .systemFont(ofSize: 15)
        return param
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        self.axis = .vertical
        self.spacing = 10
        [paramIcon, param].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            paramIcon.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
}
