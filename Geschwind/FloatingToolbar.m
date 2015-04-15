//
//  FloatingToolbar.m
//  Geschwind
//
//  Created by Beni Cheni on 4/13/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import "FloatingToolbar.h"

@interface FloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation FloatingToolbar

- (instancetype)initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [UILabel new];
            label.userInteractionEnabled = NO;
            label.alpha = 0.15;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = [self.currentTitles objectAtIndex:currentTitleIndex];
            label.backgroundColor = [self.colors objectAtIndex:currentTitleIndex];
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
    }
    
    return self;
}

- (void)layoutSubviews {
    // Set the frames for the 4 labels.
    // | 0 | 1 |
    // | 2 | 3 |
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX & labelY for each label
        if (currentLabelIndex < 2) {
            // label 0 or 1 on top row of the 2x2 layout
            labelY = 0;
        } else {
            // label 2 or 3 on botton row
            labelY = labelHeight;
        }
        
        if (currentLabelIndex % 2 == 0) {
            // label 0 or 2 on left column
            labelX = 0;
        } else {
            // label 1 or 3 on right column
            labelX = labelWidth;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark = Touch Handling

- (void)tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

- (void)panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

#pragma mark = Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 0.85 : 0.15;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
