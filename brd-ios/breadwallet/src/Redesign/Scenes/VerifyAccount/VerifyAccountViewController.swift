//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class VerifyAccountViewController: BaseTableViewController<KYCCoordinator,
                                   VerifyAccountInteractor,
                                   VerifyAccountPresenter,
                                   VerifyAccountStore>,
                                   VerifyAccountResponseDisplays {
    
    typealias Models = VerifyAccountModels
    
    lazy var verifyButton: FEButton = {
        let button = FEButton()
        return button
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(Margins.large.rawValue)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(ButtonHeights.common.rawValue)
        }
        
        verifyButton.configure(with: Presets.Button.primary)
        verifyButton.setup(with: .init(title: "Verify your account"))
        
        verifyButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // MARK: - Overrides
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .description:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        coordinator?.showVerifications()
    }

    // MARK: - VerifyAccountResponseDisplay

    // MARK: - Additional Helpers
}
