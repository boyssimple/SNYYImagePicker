//
//  SNPhotoAblum.h
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "SNCommon.h"

@interface SNPhotoAblum : NSObject
@property (nonatomic, copy) NSString *title; //相册名字

@property (nonatomic, assign) NSInteger count; //该相册内相片数量

@property (nonatomic, strong) PHAsset *headImageAsset; //相册第一张图片缩略图

@property (nonatomic, strong) PHAssetCollection *assetCollection; //相册集，通过该属性获取该相册集下所有照片
@end
