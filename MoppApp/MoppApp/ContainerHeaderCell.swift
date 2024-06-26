//
//  ContainerHeaderCell.swift
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
import Foundation

protocol ContainerHeaderDelegate: AnyObject {
    func editContainerName(completion: @escaping (_ fileName: String) -> Void)
    func saveContainer(containerPath: URL?)
}

class ContainerHeaderCell: UITableViewCell {
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var titleLabel: ScaledLabel!
    @IBOutlet weak var filenameLabel: ScaledLabel!
    @IBOutlet weak var editContainerNameButton: UIButton!
    @IBOutlet weak var saveContainerButton: UIButton!
    
    weak var delegate: ContainerHeaderDelegate? = nil
    
    var containerPath: URL?
    
    @IBAction func editContainerName(_ sender: Any) {
        delegate?.editContainerName(completion: { (fileName: String) in
            guard !fileName.isEmpty else {
                printLog("Filename is empty, container name not changed")
                return
            }
            DispatchQueue.main.async {
                self.filenameLabel.text = fileName.sanitize()
            }
        })
    }
    
    @IBAction func saveContainer(_ sender: UIButton) {
        delegate?.saveContainer(containerPath: containerPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if headerStackView != nil {
            headerStackView.isAccessibilityElement = false
        }
        titleLabel.isAccessibilityElement = true
        titleLabel.text = L(.containerHeaderTitle)
        titleLabel.resetLabelProperties()
    }
    
    func populate(name: String, isEditButtonEnabled: Bool, containerPath: URL) {
        filenameLabel.isAccessibilityElement = true
        filenameLabel.text = name.sanitize()
        filenameLabel.resetLabelProperties()
        editContainerNameButton.isHidden = !isEditButtonEnabled
        editContainerNameButton.accessibilityLabel = L(.containerEditNameButton)
        editContainerNameButton.accessibilityUserInputLabels = [L(.voiceControlChangeContainerName)]
        
        self.containerPath = containerPath
        
        saveContainerButton.isHidden = isEditButtonEnabled
        saveContainerButton.accessibilityLabel = L(.fileImportSaveFile)
        saveContainerButton.accessibilityUserInputLabels = [L(.voiceControlSaveFile)]
    }
}
