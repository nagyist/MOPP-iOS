//
//  SettingsTimeStampCell.swift
//  MoppApp
//
/*
 * Copyright 2017 - 2024 Riigi Infosüsteemi Amet
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

import UIKit

protocol SettingsTimeStampCellDelegate: AnyObject {
    func didChangeTimestamp(_ field: SigningCategoryViewController.FieldId, with value: String?)
}

class SettingsTimeStampCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var field: SigningCategoryViewController.Field!
    weak var delegate: SettingsTimeStampCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.moppPresentDismissButton()
        textField.layer.borderColor = UIColor.moppContentLine.cgColor
        textField.layer.borderWidth = 1
        textField.delegate = self

        guard let fieldUITextfield: UITextField = textField else {
            printLog("Unable to get textField")
            return
        }

        titleLabel.isAccessibilityElement = false
        textField.accessibilityLabel = L(.settingsTimestampUrlTitle)
        textField.accessibilityUserInputLabels = [L(.voiceControlTimestampingService)]
        if UIAccessibility.isVoiceOverRunning {
            self.accessibilityElements = [fieldUITextfield]
        }
    }

    func populate(with field: SigningCategoryViewController.Field) {
        self.field = field
        updateUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }

    func updateUI() {
        let defaultSwitch = DefaultsHelper.defaultSettingsSwitch

        if defaultSwitch {
            textField.text = MoppLibManager.tsaURL
            delegate.didChangeTimestamp(field.id, with: nil)

        } else {
            textField.text = DefaultsHelper.timestampUrl ?? MoppLibManager.tsaURL
            delegate.didChangeTimestamp(field.id, with: DefaultsHelper.timestampUrl ?? MoppLibManager.tsaURL)
        }
        textField.isEnabled = !defaultSwitch
        textField.textColor = defaultSwitch ? UIColor.moppLabelDarker : UIColor.moppText
        textField.text = DefaultsHelper.timestampUrl ?? MoppLibManager.tsaURL

        titleLabel.text = L(.settingsTimestampUrlTitle)
        textField.placeholder = L(.settingsTimestampUrlPlaceholder)
        textField.layoutIfNeeded()
    }
}

extension SettingsTimeStampCell: UITextFieldDelegate {    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.moveCursorToEnd()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate.didChangeTimestamp(field.id, with: textField.text)
    }
}
