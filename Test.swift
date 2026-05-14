import UIKit

class SplashViewController: UIViewController {

    // MARK: - UI Elements
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // ou a cor do seu ícone
        view.translatesAutoresizingMaskIntoConstraints = false
        // Deixamos redondo definindo cornerRadius no viewDidLayoutSubviews
        return view
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "SensorySafe"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Container para centralizar o conjunto no meio da tela
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Garantir que o círculo fique redondo após o layout definir seus bounds
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        circleView.layer.masksToBounds = true
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0) // fundo azul

        // Adiciona o círculo e o label ao stack
        containerStackView.addArrangedSubview(circleView)
        containerStackView.addArrangedSubview(appNameLabel)

        // Adiciona o stack à view principal
        view.addSubview(containerStackView)

        // Constraints
        NSLayoutConstraint.activate([
            // Stack centralizado
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Tamanho do círculo (ex.: 120x120)
            circleView.widthAnchor.constraint(equalToConstant: 120),
            circleView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
