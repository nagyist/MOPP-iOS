//
//  SmartCardTokenWrapper.hpp
//  CryptoLib
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

#if __cplusplus

#import "cdoc/Token.h"

#import <Foundation/Foundation.h>

#include <memory>

@protocol AbstractSmartToken;

class SmartCardTokenWrapper: public Token
{
public:
    SmartCardTokenWrapper(const std::string &password, id<AbstractSmartToken> smartToken);
    ~SmartCardTokenWrapper() noexcept;
    virtual std::vector<uchar> cert() const override;
    virtual std::vector<uchar> decrypt(const std::vector<uchar> &data) const override;
    virtual std::vector<uchar> derive(const std::vector<uchar> &publicKey) const override;

    Token* selfPtr() { return this; }

private:
    class Private;
    std::unique_ptr<Private> token;
    static std::vector<uchar> encodeData(const NSData *dataBlock);
};

#endif
