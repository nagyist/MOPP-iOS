//
//  SigningViewController.swift
//  MoppApp
//
/*
 * Copyright 2017 - 2022 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */
import Foundation

class SigningViewController : MoppViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    enum Section {
        case fileImport
    }

    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = L(LocKey.signatureViewBeginLabel)
        importButton.localizedTitle = LocKey.signatureViewBeginButton
        if isNonDefaultPreferredContentSizeCategory() || isBoldTextEnabled() {
            titleLabel.font = UIFont.setCustomFont(font: .medium, isNonDefaultPreferredContentSizeCategoryBigger() ? 20 : nil, .headline)
            importButton.titleLabel?.font = UIFont.setCustomFont(font: .medium, isNonDefaultPreferredContentSizeCategoryBigger() ? 12 : nil, .body)
        }
        menuButton.accessibilityLabel = L(LocKey.menuButton)
        
        titleLabel.isAccessibilityElement = false
        importButton.accessibilityLabel = L(.signatureViewBeginLabel)
        
        UIAccessibility.post(notification: .screenChanged, argument: importButton)
        
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Test Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        let numbers = [0]
        let _ = numbers[1]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LandingViewController.shared.isAlreadyInMainPage = true
        LandingViewController.shared.presentButtons([.signTab, .cryptoTab, .myeIDTab])
    }
    
    @IBAction func menuActivationSelector() {
        let menuViewController = UIStoryboard.menu.instantiateInitialViewController()!
            menuViewController.modalPresentationStyle = .overFullScreen
        MoppApp.instance.rootViewController?.present(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func importFilesAction() {
        NotificationCenter.default.post(
            name: .startImportingFilesWithDocumentPickerNotificationName,
            object: nil,
            userInfo: [kKeyFileImportIntent: MoppApp.FileImportIntent.openOrCreate, kKeyContainerType: MoppApp.ContainerType.asic])
    }
}
