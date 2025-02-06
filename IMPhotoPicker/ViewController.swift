//
//  ViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 5/2/25.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    // MARK: - UI Properties

    let nativePickerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Native Picker", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPickerAcceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPickerHDButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker with HD option", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - UI Setup

    func setupUI() {
        view.addSubview(nativePickerButton)
        view.addSubview(customPickerAcceptButton)
        view.addSubview(customPickerHDButton)
        
        nativePickerButton.addTarget(self, action: #selector(presentNativePicker), for: .touchUpInside)
        customPickerAcceptButton.addTarget(self, action: #selector(presentPicker2), for: .touchUpInside)
        customPickerHDButton.addTarget(self, action: #selector(presentPicker3), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nativePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nativePickerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            customPickerAcceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPickerAcceptButton.topAnchor.constraint(equalTo: nativePickerButton.bottomAnchor, constant: 20),
            
            customPickerHDButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPickerHDButton.topAnchor.constraint(equalTo: customPickerAcceptButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions

    @objc func presentNativePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = nil
        configuration.selectionLimit = 0
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func presentPicker2() {
        let pickerVC = CustomPickerViewController()
        pickerVC.rightButtonStyle = .accept
        pickerVC.delegate = self
        let navController = UINavigationController(rootViewController: pickerVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func presentPicker3() {
        let pickerVC = CustomPickerViewController()
        pickerVC.rightButtonStyle = .hdModeToggle
        pickerVC.delegate = self
        let navController = UINavigationController(rootViewController: pickerVC)
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
    }
}

// MARK: - CustomPickerViewControllerDelegate

extension ViewController: CustomPickerViewControllerDelegate {
    func customPickerViewController(_ controller: CustomPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool) {
        print("Updated selection: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
    }
    
    func customPickerViewController(_ controller: CustomPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool) {
        print("Finished picking: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func customPickerViewControllerDidCancel(_ controller: CustomPickerViewController) {
        print("Picker canceled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func customPickerViewControllerDidTapRightButton(_ controller: CustomPickerViewController) {
        print("Right button tapped")
    }
}
