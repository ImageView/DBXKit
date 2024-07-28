//
//  MnaDBLookViewDetailInfoViewController.m
//  MnaDebuggingOnLine
//
//  Created by asherluo on 2021/12/5.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaDBLookViewDetailInfoViewController.h"
#import "MnaDBHelper.h"
#import <objc/runtime.h>
#import "UIViewController+DB.h"
#import "UIView+DB.h"

#define MnaObjectTableBortherViewsKey @"MnaBrotherViews"
#define MnaObjectTableViewControllerKey @"所属viewController"



@interface MnaDBLookViewDetailInfoViewController ()
// 数据源
@property(nonatomic, strong) NSArray *dataSource;

@end

// UI检查工具详细信息
@implementation MnaDBLookViewDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.targetName;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[MnaAdjustsTextTableViewCell class] forCellReuseIdentifier:@"MnaDBLookViewDetailInfoViewController"];
    
    [self.tableView reloadData];
    [self initNavigatoinBar];
}

- (void)initNavigatoinBar {
    if (![self.targetObject isKindOfClass:[UIView class]]) {
        return;
    }
    UIBarButtonItem *rightItem =
        [[UIBarButtonItem alloc] initWithTitle:@"显示当前控件" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)clickRightButton:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(lookViewDetailInfoViewController:didShowSelectedView:)]) {
        [self.delegate lookViewDetailInfoViewController:self didShowSelectedView:(UIView *)self.targetObject];
    }
}

- (void)setTargetObject:(NSObject *)targetObject {
    _targetObject = targetObject;
    Class objClass = self.targetClass;
    if (!objClass) {
        objClass = self.targetObject.class;
        self.targetClass = objClass;
    }
    if (![self.targetObject isKindOfClass:self.targetClass]) {
        return;
    }
    
    if (objClass) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if ([self.targetObject isKindOfClass:[NSArray class]]) {
            NSArray *ary = (NSArray *)self.targetObject;
            for (NSObject * obj in ary) {
                [temp addObject:[NSString stringWithFormat:@"%@", obj.description]];
            }
        } else {
            [temp addObjectsFromArray:[MnaDBHelper getIvarList:objClass]];
            [temp addObjectsFromArray:[MnaDBHelper getProperties:objClass]];
            [temp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [[obj1 lowercaseString] compare:[obj2 lowercaseString]];
            }];
            
            if ([self.targetObject isKindOfClass:[UIView class]]) {
                [temp insertObject:MnaObjectTableViewControllerKey atIndex:0];
                [temp insertObject:MnaObjectTableBortherViewsKey atIndex:0];
                [temp removeObject:@"subviews"];
                [temp insertObject:@"subviews" atIndex:0];
                [temp removeObject:@"superview"];
                [temp insertObject:@"superview" atIndex:0];
            }
            [temp removeObject:@"debugDescription"];
            [temp insertObject:@"debugDescription" atIndex:0];
            if (self.targetClass == [NSObject class]) {
                [temp removeObject:@"superclass"];
                [temp removeObject:@"superclass@p"];
            } else {
                [temp insertObject:@"superclass" atIndex:0];
            }
        }

        self.dataSource = temp;
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MnaAdjustsTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MnaDBLookViewDetailInfoViewController" forIndexPath:indexPath];
    cell.txtLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    header.backgroundColor = [UIColor colorWithWhite:0. alpha:0.75];
    
    UILabel *infoLabel = [UILabel new];
    infoLabel.frame = CGRectMake(0, 0, tableView.frame.size.width - 0, 30);
    infoLabel.font = [UIFont systemFontOfSize:12.];
    infoLabel.minimumScaleFactor = 0.2;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor whiteColor];
    
    infoLabel.text = [NSString stringWithFormat:@"%@<%@>(%p)", self.targetObject.class, self.targetClass, self.targetObject];

    if ([self checkIfIsData:self.targetObject]) {
        infoLabel.text = [NSString stringWithFormat:@"%@\n%@:%@",infoLabel.text, self.targetName, [self checkIfJsonStyle:self.targetObject]];
    }
    [header addSubview:infoLabel];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pptString = [self.dataSource objectAtIndex:indexPath.row];
    NSArray *subStrs = [pptString componentsSeparatedByString:@"<"];
    NSString *pptName = [[subStrs.firstObject stringByReplacingOccurrencesOfString:@"@p" withString:@""]
                         stringByReplacingOccurrencesOfString:@"@i" withString:@""];
    id object = nil;
    Class objClass = nil;
    if ([self.targetObject isKindOfClass:[NSArray class]]) {
        NSArray *ary = (NSArray *)self.targetObject;
        object = [ary objectAtIndex:indexPath.row];
    } else if ([pptName isEqualToString:MnaObjectTableBortherViewsKey]) {
        UIView *view = (UIView *)self.targetObject;
        object = view.superview.subviews;
    } else if ([pptName isEqualToString:MnaObjectTableViewControllerKey]) {
        UIView *view = (UIView *)self.targetObject;
        object = [view dbx_viewController];//[self getViewController:view];
    } else if ([pptName isEqualToString:@"superclass"]) {
        object = self.targetObject;
        objClass = class_getSuperclass(self.targetClass);
    } else {
        object = [self.targetObject valueForKey:pptName];
        objClass = [object class];
    }
    
    MnaDBLookViewDetailInfoViewController *newInfoVC = [[MnaDBLookViewDetailInfoViewController alloc] init];
    newInfoVC.delegate = self.delegate;
    newInfoVC.targetObject = object;
    newInfoVC.targetClass = objClass;
    newInfoVC.targetName = pptName;
    [newInfoVC showFromVC:self];
}

- (BOOL)checkIfIsData:(NSObject *)object {
    if ([object isKindOfClass:[NSString class]]
        || [object isKindOfClass:[NSURL class]]
        || [object isKindOfClass:[NSNumber class]]
        || [object isKindOfClass:[NSValue class]]
        || [object isKindOfClass:[NSDictionary class]]
        || [object isKindOfClass:[NSSet class]]) {
        return YES;
    }
    return NO;
}

- (NSString *)checkIfJsonStyle:(NSObject *)obj {
    if (!obj) return @"<nil>";
    
    NSError *er = nil;
    NSData *data = nil;
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&er];
    } else if ([obj isKindOfClass:[NSString class]]) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:[(NSString *)obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&er];
        if (!er && jsonObj) {
            er = nil;
            data = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&er];
        }
    }
    if (!er && data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return obj.description;
}

//- (UIViewController *)getViewController:(UIView *)view {
//    UIResponder *responder = view;
//    while ((responder = responder.nextResponder)) {
//        if ([responder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController *)responder;
//        }
//    }
//    return nil;
//}

@end

// UI检查工具详细信息Cell
@implementation MnaAdjustsTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.contentView addSubview:self.txtLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _txtLabel.textColor = [UIColor systemPinkColor];
    } else {
        _txtLabel.textColor = [UIColor blackColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _txtLabel.frame = self.contentView.bounds;
}

- (UILabel *)txtLabel {
    if (!_txtLabel) {
        _txtLabel = [UILabel new];
        _txtLabel.font = [UIFont systemFontOfSize:12.];
        _txtLabel.backgroundColor = [UIColor clearColor];
        _txtLabel.textColor = [UIColor blackColor];
        _txtLabel.minimumScaleFactor = 0.3;
        _txtLabel.adjustsFontSizeToFitWidth = YES;
        _txtLabel.numberOfLines = 0;
    }
    return _txtLabel;
}

@end
