//
//  UISNImagePicker.h
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "SNPhotoAblum.h"
#import "SNCommon.h"

typedef enum : NSUInteger {
    IMAGEPICKERIMAGE = 1,
    IMAGEPICKERVIDEO = 2,
    IMAGEPICKERAUDIO = 3,
} SNImagePickerTYPE;

@protocol UISNImagePickerDelegate;
@interface UISNImagePicker : UIViewController

@property(nonatomic,weak)id<UISNImagePickerDelegate> delegate;
@property(nonatomic,assign)NSInteger maxCount;//最大数量
@property(nonatomic,assign)SNImagePickerTYPE mediaType;//图片、视频、录音
@end

@protocol UISNImagePickerDelegate<NSObject>

- (void)selectImage:(UISNImagePicker*)imagePicker with:(NSArray*)results withType:(SNImagePickerTYPE)type;

@end
