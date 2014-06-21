//
//  DZNEmptyDataSetView.m
//  DZNEmptyDataSet
//  https://github.com/dzenbot/DZNEmptyDataSet
//
//  Created by Ignacio Romero Zurbuchen on 6/1/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNEmptyDataSetView.h"

@interface DZNEmptyDataSetView ()
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic) BOOL didConfigureConstraints;
@end

@implementation DZNEmptyDataSetView
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel, detailLabel = _detailLabel, imageView = _imageView, button = _button;

- (instancetype)init
{
    self =  [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    self.frame = self.superview.bounds;
}


#pragma mark - Getter Methods

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:27.0];
        _titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [UILabel new];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.backgroundColor = [UIColor clearColor];
        
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = NO;
        
        [_contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.adjustsImageWhenHighlighted = YES;
        _button.userInteractionEnabled = YES;
        
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:_button];
    }
    return _button;
}


#pragma mark - Setter Methods

- (void)setCustomView:(UIView *)view
{
    [self invalidateContent];
    
    _customView = view;
    _customView.translatesAutoresizingMaskIntoConstraints = !CGRectIsEmpty(view.frame);
    
    [_contentView addSubview:_customView];
}


#pragma mark - Action Methods

- (void)didTapButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZNEmptyDataSetDidTapButtonNotification object:nil];
}

- (void)invalidateContent
{
    [_titleLabel removeFromSuperview];
    [_detailLabel removeFromSuperview];
    [_imageView removeFromSuperview];
    [_button removeFromSuperview];
    [_customView removeFromSuperview];
    
    _titleLabel = nil;
    _detailLabel = nil;
    _imageView = nil;
    _button = nil;
    _customView = nil;
}


#pragma mark - UIView Constraints & Layout Methods

- (void)updateConstraintsIfNeeded
{
    [super updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [_contentView removeConstraints:_contentView.constraints];
    
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithDictionary:NSDictionaryOfVariableBindings(self,_contentView)];
    
    if (!self.didConfigureConstraints) {
        self.didConfigureConstraints = YES;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self]-(<=0)-[_contentView]"
                                                                     options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self]-(<=0)-[_contentView]"
                                                                     options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    }
    
    if (_customView) {
        if (_customView) [views setObject:_customView forKey:@"_customView"];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_customView]|" options:0 metrics:nil views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_customView]|" options:0 metrics:nil views:views]];
        return;
    }
    
    CGFloat width = (self.frame.size.width > 0) ? self.frame.size.width : [UIScreen mainScreen].bounds.size.width;
    
    NSInteger multiplier = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 16 : 4;
    NSNumber *padding = @(roundf(width/multiplier));
    NSNumber *imgWidth = @(roundf(_imageView.image.size.width));
    NSNumber *imgHeight = @(roundf(_imageView.image.size.height));
    NSNumber *trailing = @(roundf((width-[imgWidth floatValue])/2.0));
    
    NSDictionary *metrics = NSDictionaryOfVariableBindings(padding,trailing,imgWidth,imgHeight);
    
    if (_titleLabel.superview) {
        [views setObject:_titleLabel forKey:@"_titleLabel"];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[_titleLabel]-padding-|"
                                                                             options:0 metrics:metrics views:views]];
    }
    
    if (_detailLabel.superview) {
        [views setObject:_detailLabel forKey:@"_detailLabel"];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[_detailLabel]-padding-|"
                                                                             options:0 metrics:metrics views:views]];
    }
    
    if (_imageView) {
        [views setObject:_imageView forKey:@"_imageView"];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-trailing-[_imageView(imgWidth)]-trailing-|"
                                                                             options:0 metrics:metrics views:views]];
    }
    
    if (_button) {
        [views setObject:_button forKey:@"_button"];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[_button]-padding-|"
                                                                             options:0 metrics:metrics views:views]];
    }
    
    NSMutableString *format = [NSMutableString new];
    NSMutableArray *subviews = [NSMutableArray new];
    
    if (_imageView.image) [subviews addObject:@"[_imageView(imgHeight)]"];
    if (_titleLabel.attributedText.string.length > 0) [subviews addObject:@"[_titleLabel]"];
    if (_detailLabel.attributedText.string.length > 0) [subviews addObject:@"[_detailLabel]"];
    if ([_button attributedTitleForState:UIControlStateNormal].string.length > 0) [subviews addObject:@"[_button]"];
    
    [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [format appendString:obj];
        if (idx < subviews.count-1) {
            if (_verticalSpace > 0) [format appendFormat:@"-%.f-", _verticalSpace];
            else [format appendString:@"-11-"];
        }
    }];
    
    if (format.length > 0) {
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|%@|", format]
                                                                             options:0 metrics:metrics views:views]];
    }
}

@end
