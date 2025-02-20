//
//  ObjcViewController.m
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 14/2/25.
//

#import "ObjcViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "IMPhotoPicker-Swift.h"

@interface ObjcViewController () <PHPickerViewControllerDelegate, IMPickerWrapperViewControllerDelegate, CustomPickerWrapperViewControllerDelegate>

@property (nonatomic, strong) UIButton *nativePickerButton;
@property (nonatomic, strong) UIButton *inputAccessoryButton;
@property (nonatomic, strong) UIButton *customPicker1Button;
@property (nonatomic, strong) UIButton *customPicker2Button;
@property (nonatomic, strong) UIButton *customPicker3Button;
@property (nonatomic, strong) UIButton *customPicker4Button;
@property (nonatomic, strong) UIButton *customPicker5Button;

@end

@implementation ObjcViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.nativePickerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nativePickerButton setTitle:@"Native Picker" forState:UIControlStateNormal];
    self.nativePickerButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.inputAccessoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.inputAccessoryButton setTitle:@"Input Accessory View Example" forState:UIControlStateNormal];
    self.inputAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customPicker1Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customPicker1Button setTitle:@"Custom Picker Example 1" forState:UIControlStateNormal];
    self.customPicker1Button.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customPicker2Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customPicker2Button setTitle:@"Custom Picker Example 2" forState:UIControlStateNormal];
    self.customPicker2Button.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customPicker3Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customPicker3Button setTitle:@"Custom Picker Example 3" forState:UIControlStateNormal];
    self.customPicker3Button.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customPicker4Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customPicker4Button setTitle:@"Custom Picker Example 4 (WhatsApp style)" forState:UIControlStateNormal];
    self.customPicker4Button.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.customPicker5Button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.customPicker5Button setTitle:@"Custom Picker Example 5" forState:UIControlStateNormal];
    self.customPicker5Button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.nativePickerButton];
    [self.view addSubview:self.inputAccessoryButton];
    [self.view addSubview:self.customPicker1Button];
    [self.view addSubview:self.customPicker2Button];
    [self.view addSubview:self.customPicker3Button];
    [self.view addSubview:self.customPicker4Button];
    [self.view addSubview:self.customPicker5Button];
    
    [self.nativePickerButton addTarget:self action:@selector(presentNativePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.inputAccessoryButton addTarget:self action:@selector(presentInputAccessoryViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.customPicker1Button addTarget:self action:@selector(presentPicker1) forControlEvents:UIControlEventTouchUpInside];
    [self.customPicker2Button addTarget:self action:@selector(presentPicker2) forControlEvents:UIControlEventTouchUpInside];
    [self.customPicker3Button addTarget:self action:@selector(presentPicker3) forControlEvents:UIControlEventTouchUpInside];
    [self.customPicker4Button addTarget:self action:@selector(presentPicker4) forControlEvents:UIControlEventTouchUpInside];
    [self.customPicker5Button addTarget:self action:@selector(presentPicker5) forControlEvents:UIControlEventTouchUpInside];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.nativePickerButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.nativePickerButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:100],
        
        [self.inputAccessoryButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.inputAccessoryButton.topAnchor constraintEqualToAnchor:self.nativePickerButton.bottomAnchor constant:20],
        
        [self.customPicker1Button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.customPicker1Button.topAnchor constraintEqualToAnchor:self.inputAccessoryButton.bottomAnchor constant:20],
        
        [self.customPicker2Button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.customPicker2Button.topAnchor constraintEqualToAnchor:self.customPicker1Button.bottomAnchor constant:20],
        
        [self.customPicker3Button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.customPicker3Button.topAnchor constraintEqualToAnchor:self.customPicker2Button.bottomAnchor constant:20],
        
        [self.customPicker4Button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.customPicker4Button.topAnchor constraintEqualToAnchor:self.customPicker3Button.bottomAnchor constant:20],
        
        [self.customPicker5Button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.customPicker5Button.topAnchor constraintEqualToAnchor:self.customPicker4Button.bottomAnchor constant:20]
    ]];
}

#pragma mark - Actions

- (void)presentNativePicker {
    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
    configuration.filter = nil;
    configuration.selectionLimit = 0;
    configuration.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeAutomatic;
    if (@available(iOS 15, *)) {
        configuration.selection = PHPickerConfigurationSelectionOrdered;
    }
    
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)presentInputAccessoryViewController {
    InputAccessoryViewController *vc = [[InputAccessoryViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationAutomatic;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentPicker1 {
    IMPickerViewController *picker = [[IMPickerViewController alloc] init];
    picker.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentPicker2 {
    IMPickerViewController *picker = [[IMPickerViewController alloc] init];
    UIBarButtonItem *customButton = [[UIBarButtonItem alloc] initWithTitle:@"Custom"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(customRightButtonTapped)];
    IMPickerConfiguration *config = [[IMPickerConfiguration alloc] init];
    config.assetTypeFilter = IMAssetTypeFilterPhotos;
    config.rightButtonStyle = CustomPickerRightButtonStyleCustom;
    config.customRightBarButtonItem = customButton;
    config.selectionLimit = 3;
    config.cancelButtonNavigationItemTintColor = [UIColor redColor];
    config.leftNavigationItemTintColor = [UIColor blueColor];
    config.rightNavigationItemTintColor = [UIColor blueColor];
    config.segmentedControlTintColor = [UIColor whiteColor];
    config.segmentedControlSelectedSegmentTintColor = [UIColor blackColor];
    config.segmentedControlTextAttributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    config.segmentedControlSelectedTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    picker.configuration = config;
    picker.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewControllerAsPageSheet:nav];
}

- (void)presentPicker3 {
    IMPickerWrapperViewController *picker = [self getPickerWrapperViewController];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)presentPicker4 {
    IMPickerWrapperViewController *picker = [self getPickerWrapperViewController];
    [self presentViewControllerAsPageSheet:picker];
}

- (void)presentPicker5 {
    CustomPickerWrapperViewController *customPicker = [[CustomPickerWrapperViewController alloc] init];
    IMPickerConfiguration *config = [[IMPickerConfiguration alloc] init];
    config.selectionLimit = 1;
    customPicker.configuration = config;
    customPicker.delegate = self;
    [self presentViewControllerAsPageSheet:customPicker];
}

- (IMPickerWrapperViewController *)getPickerWrapperViewController {
    IMPickerWrapperViewController *picker = [[IMPickerWrapperViewController alloc] init];
    IMPickerConfiguration *config = [[IMPickerConfiguration alloc] init];
    config.rightButtonStyle = CustomPickerRightButtonStyleHdModeToggle;
    config.cancelButtonNavigationItemTintColor = [UIColor blackColor];
    config.leftNavigationItemTintColor = [UIColor blackColor];
    config.rightNavigationItemTintColor = [UIColor blackColor];
    config.selectionOverlayBadgeColor = [UIColor systemGreenColor];
    config.inputBarConfiguration = [[IMInputBarConfiguration alloc] init];
    config.inputBarConfiguration.placeholder = @"Enter your message...";
    config.inputBarConfiguration.sendButtonBackgroundColor = [UIColor systemGreenColor];
    config.inputBarConfiguration.sendButtonBadgeColor = [UIColor systemGreenColor];
    picker.configuration = config;
    picker.delegate = self;
    return picker;
}

- (void)presentViewControllerAsPageSheet:(UIViewController *)picker {
    if (@available(iOS 15.0, *)) {
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        UISheetPresentationController *sheet = picker.sheetPresentationController;
        if (sheet) {
            if (@available(iOS 16.0, *)) {
                UISheetPresentationControllerDetent *customDetent = [UISheetPresentationControllerDetent customDetentWithIdentifier:@"custom.detent" resolver:^CGFloat(id<UISheetPresentationControllerDetentResolutionContext> _Nonnull context) {
                    return context.maximumDetentValue * 0.65;
                }];
                UISheetPresentationControllerDetent *largeDetent = [UISheetPresentationControllerDetent largeDetent];
                sheet.detents = @[customDetent, largeDetent];
            } else {
                UISheetPresentationControllerDetent *mediumDetent = [UISheetPresentationControllerDetent mediumDetent];
                UISheetPresentationControllerDetent *largeDetent = [UISheetPresentationControllerDetent largeDetent];
                sheet.detents = @[mediumDetent, largeDetent];
            }
            sheet.preferredCornerRadius = 20;
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else {
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)customRightButtonTapped {
    NSLog(@"Custom button tapped");
}

- (void)showNoPermissionAlertFromViewController:(UIViewController *)fromViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Access to Photos"
                                                                   message:@"Please enable photo library access in Settings."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [fromViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:action];
    [fromViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IMPickerWrapperViewControllerDelegate, CustomPickerWrapperViewControllerDelegate

- (void)pickerViewController:(IMPickerViewController *)controller didUpdateSelection:(NSArray<PHAsset *> *)selection hdModeEnabled:(BOOL)hdModeEnabled {
    NSLog(@"Updated selection: %lu items, HD mode: %@", (unsigned long)selection.count, hdModeEnabled ? @"Enabled" : @"Disabled");
}

- (void)pickerViewController:(IMPickerViewController *)controller didFinishPicking:(NSArray<PHAsset *> *)selection hdModeEnabled:(BOOL)hdModeEnabled {
    NSLog(@"Finished picking: %lu items, HD mode: %@", (unsigned long)selection.count, hdModeEnabled ? @"Enabled" : @"Disabled");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickerViewControllerDidCancel:(IMPickerViewController *)controller {
    NSLog(@"Picker canceled");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickerViewControllerDidTapRightButton:(IMPickerViewController *)controller {
    NSLog(@"Right button tapped");
}

- (void)pickerWrapperViewController:(IMPickerWrapperViewController *)controller didTapSendWithText:(NSString *)text selection:(NSArray<PHAsset *> *)selection hdModeEnabled:(BOOL)hdModeEnabled {
    NSLog(@"Send tapped with text: %@, %lu items, HD mode: %@", text, (unsigned long)selection.count, hdModeEnabled ? @"Enabled" : @"Disabled");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickerViewController:(IMPickerViewController *)controller didFailWithPermissionError:(NSError *)error {
    NSLog(@"Permission error: %@", error);
    [self showNoPermissionAlertFromViewController:controller];
}

- (void)pickerViewControllerDidAttemptToDismiss:(IMPickerViewController *)controller {
    NSLog(@"User attempted to dismiss via swipe-down gesture.");
}

- (void)pickerWrapperViewController:(CustomPickerWrapperViewController *)controller didTapActionButtonWithSelection:(NSArray<PHAsset *> *)selection hdModeEnabled:(BOOL)hdModeEnabled {
    NSLog(@"Custom action button tapped with %lu items, HD mode: %@", (unsigned long)selection.count, hdModeEnabled ? @"Enabled" : @"Disabled");
}

@end
