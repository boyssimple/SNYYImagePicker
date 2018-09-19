//
//  UISNPhotos.h
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "SNCommon.h"

@protocol UISNPhotosDelegate;
@interface UISNPhotos : UIViewController
@property(nonatomic,strong)PHAssetCollection *collection;


@property(nonatomic,weak)id<UISNPhotosDelegate> delegate;
@property(nonatomic,assign)NSInteger maxCount;//最大数量
@property(nonatomic,assign)NSInteger mediaType;//图片、视频、录音
@property(nonatomic,assign)NSInteger maxSeconds;//最大时长 (秒)
@end
@protocol UISNPhotosDelegate<NSObject>

- (void)selectImage:(UISNPhotos*)imagePicker with:(NSArray*)results withType:(NSInteger)type;

@end
