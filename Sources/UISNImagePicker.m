//
//  UISNImagePicker.m
//  SNImagePicker
//
//  Created by luowei on 2018/9/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import "UISNImagePicker.h"
#import "UISNPhotos.h"

@interface CellImageAblum : UITableViewCell
@property(nonatomic,strong)UIImageView *ivImg;
@property(nonatomic,strong)UILabel *lbText;
@property(nonatomic,strong)UILabel *lbCount;
@property(nonatomic,strong)UIImageView *ivArrow;
@property(nonatomic,strong)UIView *vLine;
@end


@interface UISNImagePicker ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)PHCachingImageManager *imageManager;
@property(nonatomic,strong)PHImageRequestOptions *options;

@end

@implementation UISNImagePicker


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMain];
}

- (void)initMain{
    _dataSource = [[NSMutableArray alloc]init];
    self.title = @"相册";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.table];
    _imageManager = [[PHCachingImageManager alloc] init];
    self.options = [[PHImageRequestOptions alloc]init];
    self.options.synchronous = YES;
    [self loadAllCustUser];
    
    UISNPhotos *vc = [[UISNPhotos alloc]init];
    vc.mediaType = self.mediaType;
    vc.maxCount = self.maxCount; 
    [self.navigationController pushViewController:vc animated:FALSE];
}

- (void)loadAllCustUser{
    // 列出所有相册智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 列出所有相册智能相册
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    for (NSInteger i = 0; i < smartAlbums.count; i++) {
        // 获取一个相册（PHAssetCollection）
        PHCollection *collection = smartAlbums[i];
        NSLog(@"%@",collection.localizedTitle);
        if (![collection.localizedTitle isEqualToString:@"Recently Deleted"] && ![collection.localizedTitle isEqualToString:@"最近删除"]
            && ![collection.localizedTitle isEqualToString:@"已隐藏"]){
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                
                PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                
                SNPhotoAblum *ablum = [[SNPhotoAblum alloc] init];
                ablum.title = collection.localizedTitle;
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollection = assetCollection;
                [self.dataSource addObject:ablum];
            }
        }
    }
    //自定义
    [topLevelUserCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHCollection *collection = (PHCollection*)obj;
        NSLog(@"%@",collection.localizedTitle);
        if (![collection.localizedTitle isEqualToString:@"Recently Deleted"] && ![collection.localizedTitle isEqualToString:@"最近删除"]){
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                
                PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                
                SNPhotoAblum *ablum = [[SNPhotoAblum alloc] init];
                ablum.title = collection.localizedTitle;
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollection = assetCollection;
                [self.dataSource addObject:ablum];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)cancel{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    
}



#pragma  mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55*YYRATIO_WIDHT750;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellImageAblum";
    CellImageAblum *cell = (CellImageAblum*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[CellImageAblum alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    SNPhotoAblum *data = [self.dataSource objectAtIndex:indexPath.row];
    cell.lbText.text = data.title;
    cell.lbCount.text = [NSString stringWithFormat:@"(%ld)",(long)data.count];
    
    if(data.headImageAsset){
        
        [self.imageManager requestImageForAsset:data.headImageAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                cell.ivImg.image = result;
            }
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SNPhotoAblum *data = [self.dataSource objectAtIndex:indexPath.row];
    UISNPhotos *vc = [[UISNPhotos alloc]init];
    vc.collection = data.assetCollection;
    vc.mediaType = self.mediaType;
    vc.maxCount = self.maxCount;
    [self.navigationController pushViewController:vc animated:TRUE];
}

- (UITableView*)table{
    if(!_table){
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _table.backgroundColor = [UIColor whiteColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}
@end


@implementation CellImageAblum

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _ivImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_ivImg];
        
        _lbText = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbText.textColor = [UIColor blackColor];
        _lbText.font = [UIFont systemFontOfSize:14*YYRATIO_WIDHT750];
        [self.contentView addSubview:_lbText];
        
        _lbCount = [[UILabel alloc]initWithFrame:CGRectZero];
        _lbCount.textColor = [UIColor lightGrayColor];
        _lbCount.font = [UIFont systemFontOfSize:14*YYRATIO_WIDHT750];
        [self.contentView addSubview:_lbCount];
        
        _ivArrow = [[UIImageView alloc]initWithFrame:CGRectZero];
        _ivArrow.image = [UIImage imageNamed:@""];
        [self.contentView addSubview:_ivArrow];
        
        _vLine = [[UIView alloc]initWithFrame:CGRectZero];
        _vLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_vLine];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect r = self.ivImg.frame;
    r.size.width = 30*YYRATIO_WIDHT750;
    r.size.height = r.size.width;
    r.origin.x = 10*YYRATIO_WIDHT750;
    r.origin.y = 10*YYRATIO_WIDHT750;
    self.ivImg.frame = r;
    
    CGSize size = [self.lbText sizeThatFits:CGSizeMake(MAXFLOAT, 14*YYRATIO_WIDHT750)];
    r = self.lbText.frame;
    r.size = size;
    r.origin.x = self.ivImg.frame.origin.x + self.ivImg.frame.size.width + 10*YYRATIO_WIDHT750;
    r.origin.y = (self.frame.size.height - r.size.height)/2.0;
    self.lbText.frame = r;
    
    size = [self.lbCount sizeThatFits:CGSizeMake(MAXFLOAT, 14*YYRATIO_WIDHT750)];
    r = self.lbCount.frame;
    r.size = size;
    r.origin.x = self.lbText.frame.origin.x + self.lbText.frame.size.width + 10*YYRATIO_WIDHT750;
    r.origin.y = (self.frame.size.height - r.size.height)/2.0;
    self.lbCount.frame = r;
    
    r = self.vLine.frame;
    r.size.width = [UIScreen mainScreen].bounds.size.width;
    r.size.height = 0.5;
    r.origin.x = 0;
    r.origin.y = self.frame.size.height - r.size.height;
    self.vLine.frame = r;
}

+ (CGFloat)calHeight{
    return 50*YYRATIO_WIDHT750;
}

@end

