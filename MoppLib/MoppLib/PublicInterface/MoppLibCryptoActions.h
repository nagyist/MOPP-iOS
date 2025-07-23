//
//  MoppLibCryptoActions.h
//  MoppLib
//
/*
 * Copyright 2017 - 2024 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#import <Foundation/Foundation.h>

@class CdocInfo;
@protocol AbstractSmartToken;

typedef void (^FailureBlock)(NSError *error);
typedef void (^VoidBlock)(void);
typedef void (^CdocContainerBlock)(CdocInfo * _Nonnull cdocInfo);
typedef void (^DecryptedDataBlock)(NSDictionary<NSString*,NSData*> * _Nonnull decryptedData);

@interface MoppLibCryptoActions : NSObject

    /**
     * Encrypt data and create CDOC container.
     *
     * @param fullPath      Full path of encrypted file.
     * @param dataFiles     Data files to be encrypted.
     * @param addressees    Addressees of the encrypted file.
     * @param success       Block to be called on successful completion of action.
     * @param failure       Block to be called when action fails. Includes error.
     */
+ (void)encryptData:(NSString *)fullPath withDataFiles:(NSArray*)dataFiles withAddressees:(NSArray*)addressees success:(VoidBlock)success failure:(FailureBlock)failure;


    /**
     * Decrypt CDOC container and get data files.
     *
     * @param fullPath      Full path of encrypted file.
     * @param token          SmartToken object.
     * @param success       Block to be called on successful completion of action. Includes decrypted data as NSMutableDictionary.
     * @param failure       Block to be called when action fails. Includes error.
     */
+ (void)decryptData:(NSString *)fullPath withToken:(id<AbstractSmartToken>)token success:(DecryptedDataBlock)success failure:(FailureBlock)failure;

/**
 * Parse and get info of CDOC container.
 *
 * @param fullPath      Full path of CDOC container file.
 * @param success       Block to be called on successful completion of action. Includes CDOC container info as CdocContainerBlock.
 * @param failure       Block to be called when action fails. Includes error.
 */
+ (void)parseCdocInfo:(NSString *)fullPath success:(CdocContainerBlock)success failure:(FailureBlock)failure;
    @end
