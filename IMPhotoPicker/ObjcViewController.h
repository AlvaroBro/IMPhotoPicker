//
//  ObjcViewController.h
//  IMPhotoPicker
//
//  Created by Alvaro Marcos on 14/2/25.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import "IMPhotoPicker-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface ObjcViewController : UIViewController <PHPickerViewControllerDelegate, IMPickerViewControllerDelegate, IMPickerWrapperViewControllerDelegate>

@end

NS_ASSUME_NONNULL_END
