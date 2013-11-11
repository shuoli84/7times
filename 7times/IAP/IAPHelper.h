//
// Created by Li Shuo on 13-10-18.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)restoreCompletedTransactions;

- (void)buyProduct:(SKProduct *)product;

- (BOOL)productPurchased:(NSString *)productIdentifier;

@property (nonatomic, copy) void (^transactionFinishBlock)(NSError* error);
@end