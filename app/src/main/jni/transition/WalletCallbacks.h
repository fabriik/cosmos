//
// Created by Mihail Gutan on 12/4/15.
//

#ifndef BREADWALLET_WALLETCALLBACKS_H
#define BREADWALLET_WALLETCALLBACKS_H
#include "jni.h"
#include "BRInt.h"
#include "BRTransaction.h"
#include "BRWallet.h"

extern JNIEnv *env;

void setCallbacks(JNIEnv *env, BRWallet *wallet);
void balanceChanged(void *info, uint64_t balance);
void txAdded(void *info, BRTransaction *tx);
void txUpdated(void *info, const UInt256 txHashes[], size_t count, uint32_t blockHeight, uint32_t timestamp);
void txDeleted(void *info, UInt256 txHash);

#endif //BREADWALLET_WALLETCALLBACKS_H
