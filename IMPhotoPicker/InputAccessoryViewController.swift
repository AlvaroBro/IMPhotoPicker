//
//  InputAccessoryViewController.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 12/2/25.
//

import UIKit

// MARK: - InputAccessoryViewController
class InputAccessoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.keyboardDismissMode = .interactive
        tv.allowsMultipleSelection = true
        return tv
    }()
    
    public let inputBar: SimpleInputBarView = {
        let view = SimpleInputBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        return count > 0 ? inputBar : nil
    }
    
    override var canBecomeFirstResponder: Bool {
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        return count > 0
    }
    
    private var keyboardVisible: Bool = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setContentBottomInset(bottomInset: keyboardVisible ? 0 : self.view.safeAreaInsets.bottom)
    }
    
    // MARK: - Private Methods
    
    private func updateInputBarVisibility() {
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        if count > 0 {
            if !inputBar.isFirstResponder, !isFirstResponder {
                becomeFirstResponder()
            }
        } else {
            if isFirstResponder {
                resignFirstResponder()
            } else if inputBar.isFirstResponder {
                _ = inputBar.resignFirstResponder()
            }
        }
    }
    
    private func setContentBottomInset(bottomInset: CGFloat) {
        self.tableView.contentInset.bottom = bottomInset
        var verticalInsets = self.tableView.verticalScrollIndicatorInsets
        verticalInsets.bottom = bottomInset
        self.tableView.verticalScrollIndicatorInsets = verticalInsets
    }
    
    // MARK: - Keyboard notifications
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        let intersection = view.bounds.intersection(convertedFrame)
        let bottomInset = intersection.height
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: {
            self.setContentBottomInset(bottomInset: bottomInset)
            self.keyboardVisible = true
        }, completion: nil)
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: {
            self.setContentBottomInset(bottomInset: self.view.safeAreaInsets.bottom)
            self.keyboardVisible = false
        }, completion: nil)
    }

    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateInputBarVisibility()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateInputBarVisibility()
    }
}
