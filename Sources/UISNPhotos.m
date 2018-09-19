//
//  UISNPhotos.m
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import "UISNPhotos.h"

@interface CollCellImageAll : UICollectionViewCell
@property(nonatomic,strong)UIButton *btnSelect;
@property(nonatomic,strong)UILabel *lbCount;
@property(nonatomic,strong)UIImageView *ivImg;
@property(nonatomic,strong)NSString *representedAssetIdentifier;
- (void)select:(BOOL)select withIndex:(NSInteger)index;
@end


@interface UISNPhotos ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionView *collView;
@property(nonatomic,strong)NSMutableDictionary *dataSource;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, assign) CGRect previousPreheatRect;
@property(nonatomic,strong)UIImage *img;

@property(nonatomic,strong)UIView *vBottom;
@property(nonatomic,strong)UILabel *lbCount;
@property(nonatomic,strong)UIButton *btnConfirm;
@property(nonatomic,strong)NSMutableArray *selects;

@end

@implementation UISNPhotos


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMain];
}

- (void)initMain{
    _selects = [NSMutableArray array];
    _dataSource = [[NSMutableDictionary alloc]init];
    self.title = @"照片";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.collView];
    [self.view addSubview:self.vBottom];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    if(self.mediaType){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld",(long)self.mediaType];
        if(self.mediaType == IMAGEPICKERVIDEO){
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %ld and duration < %ld",(long)self.mediaType ,(long)self.maxSeconds];
        }
    }
    
    
    if(self.collection){
        self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:options];
    }else{
        self.fetchResult = [PHAsset fetchAssetsWithOptions:options];
    }
    
    [self scrollCollectionViewToBottom];
    
}

- (void)scrollCollectionViewToBottom {
    if (self.fetchResult.count > 0) {
        NSInteger item = self.fetchResult.count - 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dismiss{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    
}

- (void)confirmAction:(UIButton*)sender{
    NSMutableArray *selets = [NSMutableArray array];
    for(NSInteger i=0;i<self.selects.count;i++){
        NSDictionary *data = [self.selects objectAtIndex:i];
        NSString *inStr = [data objectForKey:@"index"];
        NSInteger index = 0;
        if(inStr){
            index = [inStr intValue];
        }
        [selets addObject:[self getSeletObj:index]];
    }
    [self dismiss];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollCellImageAll *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollCellImageAll" forIndexPath:indexPath];
    
    //根据Index 获取asset
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
    __weak typeof(self) weakself = self;
    self.img = [self.dataSource objectForKey:asset.localIdentifier];
    if (!self.img) {
        
        //设置cell representedAssetIdentifier
        cell.representedAssetIdentifier = asset.localIdentifier;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize targetSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, CGRectGetHeight([UIScreen mainScreen].bounds) * scale);
        //imageManager 请求image
        [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if ([cell.representedAssetIdentifier isEqualToString: asset.localIdentifier]) {
                if(result){
                    cell.ivImg.image = result;
                    weakself.img = result;
                    [weakself.dataSource setObject:result forKey:asset.localIdentifier];
                }
            }
            NSLog(@"%@",info);
        }];
    }
    cell.ivImg.image = self.img;
    
    BOOL flag = FALSE;
    for (NSInteger i = 0; i < self.selects.count; i++) {
        NSDictionary *dic = [self.selects objectAtIndex:i];
        NSString *inStr = [dic objectForKey:@"index"];
        NSInteger index = 0;
        if(inStr){
            index = [inStr intValue];
        }
        if(index == indexPath.row){
            flag = TRUE;
            
            NSString *numStr = [dic objectForKey:@"num"];
            NSInteger num = 0;
            if(numStr){
                num = [numStr intValue];
            }
            [cell select:TRUE withIndex:num];
            break;
        }
    }
    if(!flag){
        [cell select:FALSE withIndex:0];
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 10*YYRATIO_WIDHT750)/4.0;
    return CGSizeMake(w, w);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BOOL flag = FALSE;
    for (NSInteger i = 0; i < self.selects.count; i++) {
        NSDictionary *dic = [self.selects objectAtIndex:i];
        NSString *inStr = [dic objectForKey:@"index"];
        NSInteger index = 0;
        if(inStr){
            index = [inStr intValue];
        }
        if(index == indexPath.row){
            [self.selects removeObjectAtIndex:i];
            flag = TRUE;
            break;
        }
    }
    if(!flag){
        if(self.selects.count >= self.maxCount){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"最多可选%ld张",(long)self.maxCount] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self.selects addObject:@{@"index":@(indexPath.row)}];
    }
    [self.selects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *data = [obj mutableCopy];
        [data setObject:@(idx+1) forKey:@"num"];
        [self.selects replaceObjectAtIndex:idx withObject:data];
    }];
    
    
    self.lbCount.text = [NSString stringWithFormat:@"已选(%ld)",(long)self.selects.count];
    if(self.selects.count > 0){
        [self.btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnConfirm.enabled = TRUE;
        self.btnConfirm.backgroundColor = [UIColor colorWithRed:0/255.0 green:100/255.0 blue:0 alpha:1];
    }else{
        
        [_btnConfirm setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    [self.collView reloadData];
    [self getImage:indexPath.row];
    NSLog(@"选择图片");
}

- (void)getImage:(NSInteger)index{
    //根据Index 获取asset
    PHAsset *asset = [self.fetchResult objectAtIndex:index];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, CGRectGetHeight([UIScreen mainScreen].bounds) * scale);
    //imageManager 请求image
    __weak typeof(self) weakself = self;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
        options.networkAccessAllowed = TRUE;
        [self.imageManager requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            
            CMTimeRange range = [[playerItem loadedTimeRanges].lastObject CMTimeRangeValue];
            CMTime loadTime = CMTimeAdd(range.start, range.duration);
            
            CMTime time = loadTime;
            int seconds = ceil(time.value/time.timescale);
            NSLog(@"%d",seconds);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_IMG" object:@{@"type":@"1",@"obj":playerItem}];
        }];
    }else if(asset.mediaType == PHAssetMediaTypeImage){
        [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            weakself.img = result;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_IMG" object:@{@"type":@(2),@"obj":result}];
            [self dismiss];
        }];
    }
}


- (id)getSeletObj:(NSInteger)index{
    //根据Index 获取asset
    PHAsset *asset = [self.fetchResult objectAtIndex:index];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, CGRectGetHeight([UIScreen mainScreen].bounds) * scale);
    //imageManager 请求image
    __block id item;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
        options.networkAccessAllowed = TRUE;
        [self.imageManager requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            
            if(playerItem){
                item =  playerItem;
            }
        }];
    }else if(asset.mediaType == PHAssetMediaTypeImage){
        [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if(result){
                item =  result;
            }
        }];
    }
    return item;
}

- (UICollectionView*)collView{
    if (!_collView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 2*YYRATIO_WIDHT750;
        layout.minimumInteritemSpacing = 2*YYRATIO_WIDHT750;
        _collView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44*YYRATIO_WIDHT750) collectionViewLayout:layout];
        [_collView registerClass:[CollCellImageAll class] forCellWithReuseIdentifier:@"CollCellImageAll"];
        _collView.contentInset = UIEdgeInsetsMake(2*YYRATIO_WIDHT750, 2*YYRATIO_WIDHT750, 2*YYRATIO_WIDHT750, 2*YYRATIO_WIDHT750);
        _collView.backgroundColor = [UIColor whiteColor];
        _collView.delegate = self;
        _collView.dataSource = self;
    }
    return _collView;
}


- (UIView*)vBottom{
    if(!_vBottom){
        _vBottom = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44*YYRATIO_WIDHT750, [UIScreen mainScreen].bounds.size.width, 44*YYRATIO_WIDHT750)];
        _vBottom.backgroundColor = [UIColor blackColor];
        [_vBottom addSubview:self.lbCount];
        [_vBottom addSubview:self.btnConfirm];
        
    }
    return _vBottom;
}

- (UILabel*)lbCount{
    if(!_lbCount){
        _lbCount = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100*YYRATIO_WIDHT750)/2.0, 0, 100*YYRATIO_WIDHT750, 44*YYRATIO_WIDHT750)];
        _lbCount.textColor = [UIColor whiteColor];
        _lbCount.font = [UIFont systemFontOfSize:14*YYRATIO_WIDHT750];
        _lbCount.textAlignment = NSTextAlignmentCenter;
    }
    return _lbCount;
}

- (UIButton*)btnConfirm{
    if(!_btnConfirm){
        _btnConfirm = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 65*YYRATIO_WIDHT750, 5*YYRATIO_WIDHT750, 55*YYRATIO_WIDHT750, 34*YYRATIO_WIDHT750)];
        [_btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [_btnConfirm setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _btnConfirm.backgroundColor = [UIColor colorWithRed:105/255.0 green:139/255.0 blue:105/255.0 alpha:1];
        _btnConfirm.titleLabel.font = [UIFont systemFontOfSize:14*YYRATIO_WIDHT750];
        _btnConfirm.enabled = FALSE;
        _btnConfirm.layer.cornerRadius = 3;
        [_btnConfirm addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnConfirm;
}

@end


@implementation CollCellImageAll


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        _ivImg.image = [UIImage imageNamed:@""];
        _ivImg.backgroundColor = [UIColor redColor];
        _ivImg.contentMode = UIViewContentModeScaleAspectFill;
        _ivImg.clipsToBounds = TRUE;
        [self.contentView addSubview:_ivImg];
        
        _btnSelect = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnSelect setImage:[UIImage imageNamed:@"image_check_normal"] forState:UIControlStateNormal];
        [_btnSelect setImage:nil forState:UIControlStateSelected];
        [self.btnSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _btnSelect.layer.cornerRadius = 12.5*YYRATIO_WIDHT750;
        _btnSelect.userInteractionEnabled = FALSE;
        [self.contentView addSubview:_btnSelect];
        
        _lbCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbCount.textColor = [UIColor whiteColor];
        _lbCount.font = [UIFont systemFontOfSize:12*YYRATIO_WIDHT750];
        _lbCount.backgroundColor = [UIColor colorWithRed:0/255.0 green:100/255.0 blue:0/255.0 alpha:1];
        _lbCount.textAlignment = NSTextAlignmentCenter;
        _lbCount.hidden = TRUE;
        _lbCount.layer.cornerRadius = 12.5*YYRATIO_WIDHT750;
        _lbCount.layer.masksToBounds = TRUE;
        [self.contentView addSubview:_lbCount];
    }
    return self;
}

- (void)select:(BOOL)select withIndex:(NSInteger)index{
    if (select) {
        self.btnSelect.hidden = TRUE;
        self.lbCount.hidden = FALSE;
        
        self.lbCount.text = [NSString stringWithFormat:@"%ld",(long)index];
    }else{
        self.btnSelect.hidden = FALSE;
        self.lbCount.hidden = TRUE;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect r = self.ivImg.frame;
    r.size.width = self.frame.size.width;
    r.size.height = self.frame.size.height;
    r.origin.x = 0;
    r.origin.y = 0;
    self.ivImg.frame = r;
    
    r = self.btnSelect.frame;
    r.size.width = 25*YYRATIO_WIDHT750;
    r.size.height = r.size.width;
    r.origin.x = self.frame.size.width - r.size.width;
    r.origin.y = 0;
    self.btnSelect.frame = r;
    
    r = self.lbCount.frame;
    r.size.width = 25*YYRATIO_WIDHT750;
    r.size.height = r.size.width;
    r.origin.x = self.frame.size.width - r.size.width;
    r.origin.y = 0;
    self.lbCount.frame = r;
    
    
}

+ (CGFloat)calHeight{
    return 80*YYRATIO_HEIGHT750;
}


@end
