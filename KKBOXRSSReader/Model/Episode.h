//
//  Episode.h
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Episode : NSObject
{
    NSDate *publishedDate;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *imgURL;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, strong, nullable) NSData *content;

- (id)initWithTitle:(NSString *)title contentURL:(NSURL *)contentURL publishedDate:(NSDate *)publishedDate imageURL:(NSURL *)url description:(NSString *)description;
- (NSString *)pubDateString;

@end

NS_ASSUME_NONNULL_END
