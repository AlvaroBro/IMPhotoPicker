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
    
    let inputAccessoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Input Accessory View Example", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker1Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 1", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker2Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 2", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker3Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 3", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker4Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 4 (WhatsApp style)", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let customPicker5Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Custom Picker Example 5", for: .normal)
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
        view.addSubview(inputAccessoryButton)
        view.addSubview(customPicker1Button)
        view.addSubview(customPicker2Button)
        view.addSubview(customPicker3Button)
        view.addSubview(customPicker4Button)
        view.addSubview(customPicker5Button)
        
        nativePickerButton.addTarget(self, action: #selector(presentNativePicker), for: .touchUpInside)
        inputAccessoryButton.addTarget(self, action: #selector(presentInputAccessoryViewController), for: .touchUpInside)
        customPicker1Button.addTarget(self, action: #selector(presentPicker1), for: .touchUpInside)
        customPicker2Button.addTarget(self, action: #selector(presentPicker2), for: .touchUpInside)
        customPicker3Button.addTarget(self, action: #selector(presentPicker3), for: .touchUpInside)
        customPicker4Button.addTarget(self, action: #selector(presentPicker4), for: .touchUpInside)
        customPicker5Button.addTarget(self, action: #selector(presentPicker5), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nativePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nativePickerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            inputAccessoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputAccessoryButton.topAnchor.constraint(equalTo: nativePickerButton.bottomAnchor, constant: 20),
            
            customPicker1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker1Button.topAnchor.constraint(equalTo: inputAccessoryButton.bottomAnchor, constant: 20),
            
            customPicker2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker2Button.topAnchor.constraint(equalTo: customPicker1Button.bottomAnchor, constant: 20),
            
            customPicker3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker3Button.topAnchor.constraint(equalTo: customPicker2Button.bottomAnchor, constant: 20),
            
            customPicker4Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker4Button.topAnchor.constraint(equalTo: customPicker3Button.bottomAnchor, constant: 20),
            
            customPicker5Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customPicker5Button.topAnchor.constraint(equalTo: customPicker4Button.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions

    @objc func presentNativePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = nil
        configuration.selectionLimit = 0
        configuration.preferredAssetRepresentationMode = .automatic
        if #available(iOS 15.0, *) {
            configuration.selection = .ordered
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func presentInputAccessoryViewController() {
        let viewController = InputAccessoryViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .automatic
        present(navController, animated: true)
    }
    
    @objc func presentPicker1() {
        let picker = IMPickerViewController()
        picker.delegate = self
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func presentPicker2() {
        let picker = IMPickerViewController()
        let customButton = UIBarButtonItem(title: "Custom", style: .done, target: self, action: #selector(customRightButtonTapped))
        let configuration = IMPickerConfiguration()
        configuration.assetTypeFilter = .photos
        configuration.rightButtonStyle = .custom
        configuration.customRightBarButtonItem = customButton
        configuration.selectionLimit = 3
        configuration.cancelButtonNavigationItemTintColor = .red
        configuration.leftNavigationItemTintColor = .blue
        configuration.rightNavigationItemTintColor = .blue
        configuration.segmentedControlTintColor = .white
        configuration.segmentedControlSelectedSegmentTintColor = .black
        configuration.segmentedControlTextAttributes = [.foregroundColor: UIColor.black]
        configuration.segmentedControlSelectedTextAttributes = [.foregroundColor: UIColor.white]
        picker.configuration = configuration
        picker.delegate = self
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .fullScreen
        presentViewControllerAsPageSheet(picker: navController)
    }

    @objc func presentPicker3() {
        let picker = getPickerWrapperViewController()
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
    
    @objc func presentPicker4() {
        let picker = getPickerWrapperViewController()
        presentViewControllerAsPageSheet(picker: picker)
    }
    
    @objc func presentPicker5() {
        let customPicker = CustomPickerWrapperViewController()
        let configuration = IMPickerConfiguration()
        configuration.selectionLimit = 1
        customPicker.configuration = configuration
        customPicker.delegate = self
        presentViewControllerAsPageSheet(picker: customPicker)
    }
    
    func getPickerWrapperViewController() -> IMPickerWrapperViewController {
        let picker = IMPickerWrapperViewController()
        let configuration = IMPickerConfiguration()
        configuration.rightButtonStyle = .hdModeToggle
        configuration.cancelButtonNavigationItemTintColor = .black
        configuration.leftNavigationItemTintColor = .black
        configuration.rightNavigationItemTintColor = .black
        configuration.selectionOverlayBadgeColor = .systemGreen
        configuration.inputBarConfiguration = IMInputBarConfiguration()
        configuration.inputBarConfiguration?.placeholder = "Enter your message..."
        configuration.inputBarConfiguration?.sendButtonBackgroundColor = .systemGreen
        configuration.inputBarConfiguration?.sendButtonBadgeColor = .systemGreen
        configuration.inputBarConfiguration?.sendButtonTintColor = .white
        picker.configuration = configuration
        picker.delegate = self
        return picker
    }
    
    func presentViewControllerAsPageSheet(picker: UIViewController) {
        if #available(iOS 15.0, *) {
            picker.modalPresentationStyle = .pageSheet
            if let sheet = picker.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [
                        .custom(identifier: .init("custom.detent")) { context in
                            return context.maximumDetentValue * 0.65
                        },
                        .large()
                    ]
                } else {
                    sheet.detents = [
                        .medium(),
                        .large()
                    ]
                }
                sheet.preferredCornerRadius = 20
                present(picker, animated: true)
            }
        } else {
            picker.modalPresentationStyle = .pageSheet
            present(picker, animated: true, completion: nil)
        }
    }
    
    @objc func customRightButtonTapped() {
        print("Custom button tapped")
    }
    
    // MARK: - Alerts
    func showNoPermissionAlert(fromViewController: UIViewController) {
        let alert = UIAlertController(
            title: "No Access to Photos",
            message: "Please enable photo library access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            fromViewController.dismiss(animated: true)
        }))
        fromViewController.present(alert, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
    }
}

// MARK: - IMPickerViewControllerDelegate

extension ViewController: IMPickerWrapperViewControllerDelegate, CustomPickerWrapperViewControllerDelegate {
    func pickerViewController(_ controller: IMPickerViewController, didUpdateSelection selection: [PHAsset], hdModeEnabled: Bool) {
        print("Updated selection: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
    }
    
    func pickerViewController(_ controller: IMPickerViewController, didFinishPicking selection: [PHAsset], hdModeEnabled: Bool) {
        print("Finished picking: \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewControllerDidCancel(_ controller: IMPickerViewController) {
        print("Picker canceled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewControllerDidTapRightButton(_ controller: IMPickerViewController) {
        print("Right button tapped")
    }
    
    func pickerWrapperViewController(_ controller: IMPickerWrapperViewController, didTapSendWithText text: String, selection: [PHAsset], hdModeEnabled: Bool) {
        print("Send tapped with text: \(text), \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func pickerViewController(_ controller: IMPickerViewController, didFailWithPermissionError error: Error) {
        print("Permission error: \(error)")
        showNoPermissionAlert(fromViewController: controller)
    }
    
    func pickerViewControllerDidAttemptToDismiss(_ controller: IMPickerViewController) {
        print("User attempted to dismiss via swipe-down gesture.")
    }
    
    func pickerWrapperViewController(_ controller: CustomPickerWrapperViewController, didTapActionButtonWithSelection selection: [PHAsset], hdModeEnabled: Bool) {
        print("Custom action button tapped with \(selection.count) items, HD mode: \(hdModeEnabled ? "Enabled" : "Disabled")")
    }
}
