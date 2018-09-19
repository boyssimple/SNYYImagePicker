//
//  SNCommon.h
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#ifndef SNCommon_h
#define SNCommon_h

#define YYRATIO_WIDHT750 [UIScreen mainScreen].bounds.size.width/375.0
#define YYRATIO_HEIGHT750 [UIScreen mainScreen].bounds.size.height/667.0

typedef enum : NSUInteger {
    IMAGEPICKERIMAGE = 1,
    IMAGEPICKERVIDEO = 2,
    IMAGEPICKERAUDIO = 3,
} SNImagePickerTYPE;


#endif /* SNCommon_h */
