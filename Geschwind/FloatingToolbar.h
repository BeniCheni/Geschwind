//
//  FloatingToolbar.h
//  Geschwind
//
//  Created by Beni Cheni on 4/13/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloatingToolbar;

@protocol FloatingToolbarDelegate <NSObject>

@optional

- (void)didSelectButtonWithTitle:(NSString *)title;
- (void)floatingToolbar:(FloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
//- (void)floatingToolbar:(FloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale centerLocation:(CGPoint)center;
- (void)didHoldButtonsWithColors:(NSArray *)buttons colors:(NSMutableArray *)colectCollection;

@end

@interface FloatingToolbar : UIView

@property (nonatomic, weak)id <FloatingToolbarDelegate> delegate;

- (instancetype)initWithFourTitles:(NSArray *)titles;
- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@end
