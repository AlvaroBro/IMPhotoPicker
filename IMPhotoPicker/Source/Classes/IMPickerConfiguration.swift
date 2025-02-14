//
//  IMPickerConfiguration.swift
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 11/2/25.
//

import UIKit

/// Configuration object for customizing the appearance and behavior of the picker.
@objcMembers public class IMPickerConfiguration : NSObject {
    
    /// Specifies the style for the right button in the picker.
    /// Supported styles include: accept, HD mode toggle, or a custom UIBarButtonItem.
    public var rightButtonStyle: IMPickerViewController.CustomPickerRightButtonStyle = .accept
    
    /// A custom UIBarButtonItem to be used when the right button style is set to custom.
    public var customRightBarButtonItem: UIBarButtonItem?
    
    /// The maximum number of assets that can be selected.
    public var selectionLimit: Int = 0
    
    /// The tint color for the cancel button in the navigation bar.
    public var cancelButtonNavigationItemTintColor: UIColor?
    
    /// The tint color for the left navigation item.
    /// This color will be applied to the back arrow in the navigation bar.
    public var leftNavigationItemTintColor: UIColor?
    
    /// The tint color for the right navigation item.
    /// This color will be applied when the right button type is either 'accept' or 'custom'.
    public var rightNavigationItemTintColor: UIColor?
    
    /// The tint color for the segmented control background.
    public var segmentedControlTintColor: UIColor?
    
    /// The tint color for the selected segment of the segmented control.
    public var segmentedControlSelectedSegmentTintColor: UIColor?
    
    /// The text attributes for the segmented control in its normal state.
    public var segmentedControlTextAttributes: [NSAttributedString.Key: Any]?
    
    /// The text attributes for the segmented control in its selected state.
    public var segmentedControlSelectedTextAttributes: [NSAttributedString.Key: Any]?
    
    /// The color used for the selection overlay badge on assets.
    public var selectionOverlayBadgeColor: UIColor?
    
    /// Configuration settings for the input bar.
    public var inputBarConfiguration: IMInputBarConfiguration?
}

/// Configuration object for customizing the appearance of the input bar.
@objcMembers public class IMInputBarConfiguration : NSObject {
    /// The placeholder text displayed in the input bar's text field.
    public var placeholder: String = NSLocalizedString("input_placeholder", comment: "")
    
    /// The background color of the input bar's text field.
    public var textFieldBackgroundColor: UIColor = .white
    
    /// The font used for the text in the input bar's text field.
    public var textFieldFont: UIFont = UIFont.systemFont(ofSize: 14)
    
    /// The image displayed on the send button.
    public var sendButtonImage: UIImage = UIImage(systemName: "paperplane.fill")!
    
    /// The tint color of the send button.
    public var sendButtonTintColor: UIColor = .white
    
    /// The background color of the send button.
    public var sendButtonBackgroundColor: UIColor = .systemBlue
    
    /// The badge color for the send button, if a badge is displayed.
    public var sendButtonBadgeColor: UIColor = .systemBlue
}
