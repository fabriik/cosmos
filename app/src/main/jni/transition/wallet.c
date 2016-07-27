//
//  wallet.c
//
//  Created by Mihail Gutan on 12/4/15.
//  Copyright (c) 2015 breadwallet LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#include "wallet.h"
#include "PeerManager.h"
#include "BRPeerManager.h"
#include "BRBIP39Mnemonic.h"
#include "BRBase58.h"
#include <android/log.h>
#include <assert.h>
#include <BRTransaction.h>
#include <BRBIP38Key.h>
#include <BRKey.h>
#include "BRBIP32Sequence.h"
#include "BRTransaction.h"

static JavaVM *_jvmW;
BRWallet *_wallet;
static BRTransaction **_transactions;
static BRTransaction *_privKeyTx;
static uint64_t _privKeyBalance;
static size_t _transactionsCounter = 0;
jclass _walletManagerClass;

static JNIEnv *getEnv() {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getEnv Wallet");
    if (!_jvmW) return NULL;

    JNIEnv *env;
    int status = (*_jvmW)->GetEnv(_jvmW, (void **) &env, JNI_VERSION_1_6);

    if (status < 0) {
        status = (*_jvmW)->AttachCurrentThread(_jvmW, &env, NULL);
        if (status < 0) return NULL;
    }

    return env;
}

//callback for tx publishing
void callback(void *info, int error) {
    JNIEnv *env = getEnv();

    if (!env || _walletManagerClass == NULL) return;

    jmethodID mid = (*env)->GetStaticMethodID(env, _walletManagerClass, "publishCallback",
                                              "(Ljava/lang/String;I)V");

    //call java methods
    if (error) {
        __android_log_print(ANDROID_LOG_ERROR, "Message from callback: ", "publishing Failed: %s",
                            strerror(error));
    }
    else {
        __android_log_print(ANDROID_LOG_ERROR, "Message from callback: ", "publishing Succeeded!");
    }

    (*env)->CallStaticVoidMethod(env, _walletManagerClass, mid,
                                 (*env)->NewStringUTF(env, strerror(error)), error);
}


static void balanceChanged(void *info, uint64_t balance) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "balanceChanged: %d", (int) balance);
    JNIEnv *env = getEnv();

    if (!env || _walletManagerClass == NULL) return;

    jmethodID mid = (*env)->GetStaticMethodID(env, _walletManagerClass, "onBalanceChanged", "(J)V");

    //call java methods
    (*env)->CallStaticVoidMethod(env, _walletManagerClass, mid, balance);
}

static void txAdded(void *info, BRTransaction *tx) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txAdded");
    if (!_wallet || !tx) return;

    JNIEnv *env = getEnv();

    if (!env || _walletManagerClass == NULL) return;

    jmethodID mid = (*env)->GetStaticMethodID(env, _walletManagerClass, "onTxAdded",
                                              "([BIJJLjava/lang/String;)V");

    //call java methods
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",
                        "BRPeerManagerLastBlockHeight(): %d tx->timestamp: %d",
                        tx->blockHeight, tx->timestamp);

    uint8_t buf[BRTransactionSerialize(tx, NULL, 0)];
    size_t len = BRTransactionSerialize(tx, buf, sizeof(buf));
    uint64_t fee = (BRWalletFeeForTx(_wallet, tx) == -1) ? 0 : BRWalletFeeForTx(_wallet, tx);
    jlong amount;

//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "fee: %d", (int)fee);
    if (BRWalletAmountSentByTx(_wallet, tx) == 0) {
        amount = (jlong) BRWalletAmountReceivedFromTx(_wallet, tx);
    }
    else {
        amount = (jlong) (
                (BRWalletAmountSentByTx(_wallet, tx) - BRWalletAmountReceivedFromTx(_wallet, tx) -
                 fee) * -1);
    }

    jbyteArray result = (*env)->NewByteArray(env, (jsize) len);

    (*env)->SetByteArrayRegion(env, result, 0, (jsize) len, (jbyte *) buf);

    UInt256 transactionHash = tx->txHash;
    const char *strHash = u256_hex_encode(transactionHash);
    jstring jstrHash = (*env)->NewStringUTF(env, strHash);

    (*env)->CallStaticVoidMethod(env, _walletManagerClass, mid, result, (jint) tx->blockHeight,
                                 (jlong) tx->timestamp,
                                 (jlong) amount, jstrHash);
}

static void txUpdated(void *info, const UInt256 txHashes[], size_t count, uint32_t blockHeight,
                      uint32_t timestamp) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txUpdated");
    if (!_wallet) return;

    JNIEnv *env = getEnv();

    if (!env || _walletManagerClass == NULL) return;

    jmethodID mid = (*env)->GetStaticMethodID(env, _walletManagerClass, "onTxUpdated",
                                              "(Ljava/lang/String;II)V");

    for (size_t i = 0; i < count; i++) {
        const char *strHash = u256_hex_encode(txHashes[i]);
        jstring JstrHash = (*env)->NewStringUTF(env, strHash);

        (*env)->CallStaticVoidMethod(env, _walletManagerClass, mid, JstrHash, (jint) blockHeight,
                                     (jint) timestamp);
    }
}

static void txDeleted(void *info, UInt256 txHash, int notifyUser, int recommendRescan) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txDeleted");
    if (!_wallet) return;

    JNIEnv *env = getEnv();

    if (!env || _walletManagerClass == NULL) return;

    const char *strHash = u256_hex_encode(txHash);

    //create class
    jmethodID mid = (*env)->GetStaticMethodID(env, _walletManagerClass, "onTxDeleted",
                                              "(Ljava/lang/String;II)V");
//    //call java methods
    (*env)->CallStaticVoidMethod(env, _walletManagerClass, mid, (*env)->NewStringUTF(env, strHash));
}

JNIEXPORT jbyteArray
Java_com_breadwallet_wallet_BRWalletManager_encodeSeed(JNIEnv *env, jobject thiz, jbyteArray seed,
                                                       jobjectArray stringArray) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "encodeSeed");

    int wordsCount = (*env)->GetArrayLength(env, stringArray);
    int seedLength = (*env)->GetArrayLength(env, seed);
    const char *wordList[wordsCount];

    for (int i = 0; i < wordsCount; i++) {
        jstring string = (jstring) (*env)->GetObjectArrayElement(env, stringArray, i);
        const char *rawString = (*env)->GetStringUTFChars(env, string, 0);

        wordList[i] = rawString;
        (*env)->DeleteLocalRef(env, string);
        // Don't forget to call `ReleaseStringUTFChars` when you're done.
    }

    jbyte *byteSeed = (*env)->GetByteArrayElements(env, seed, 0);
    char result[BRBIP39Encode(NULL, 0, wordList, (uint8_t *) byteSeed, (size_t) seedLength)];

    BRBIP39Encode((char *) result, sizeof(result), wordList, (const uint8_t *) byteSeed,
                  (size_t) seedLength);
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "result: %s", result);
    jbyte *phraseJbyte = (jbyte *) result;
    int size = sizeof(result);
    jbyteArray bytePhrase = (*env)->NewByteArray(env, size);
    (*env)->SetByteArrayRegion(env, bytePhrase, 0, size, phraseJbyte);

    return bytePhrase;
}

JNIEXPORT void
Java_com_breadwallet_wallet_BRWalletManager_createWallet(JNIEnv *env, jobject thiz, size_t txCount,
                                                         jbyteArray bytePubKey) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "createWallet");

    jint rs = (*env)->GetJavaVM(env, &_jvmW); // cache the JavaVM pointer
    jclass peerManagerCLass = (*env)->FindClass(env, "com/breadwallet/wallet/BRWalletManager");
    _walletManagerClass = (jclass) (*env)->NewGlobalRef(env, (jobject) peerManagerCLass);

    if (_wallet) return;

    jbyte *pubKeyBytes = (*env)->GetByteArrayElements(env, bytePubKey, 0);
    BRMasterPubKey pubKey = *(BRMasterPubKey *) pubKeyBytes;

    if (rs != JNI_OK) {
        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",
                            "WARNING, GetJavaVM is not JNI_OK");
    }

    if (!_transactions) {
        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",
                            "WARNING, _transactions is NULL, txCount: %zu",
                            txCount);
        txCount = 0;
    }

    BRWallet *w;

    if (txCount > 0) {
        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",
                            "CREATING WALLET FROM TXS - txCount: %zu", txCount);
        w = BRWalletNew(_transactions, txCount, pubKey);
        _transactionsCounter = 0;

        if (_transactions) {
            free(_transactions);
            _transactions = NULL;
        }
    }
    else {
        __android_log_print(ANDROID_LOG_INFO, "Message from C: ", "CREATING EMPTY WALLET");
        w = BRWalletNew(NULL, 0, pubKey);
    }

    BRWalletSetCallbacks(w, NULL, balanceChanged, txAdded, txUpdated, txDeleted);
    _wallet = w;

    if (!_wallet) {
        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "WARNING, _wallet is NULL!");
        return;
    }

    //create class
    jclass clazz = (*env)->FindClass(env, "com/breadwallet/wallet/BRWalletManager");
    jmethodID mid = (*env)->GetStaticMethodID(env, clazz, "onBalanceChanged", "(J)V");
    //call java methods
    (*env)->CallStaticVoidMethod(env, clazz, mid, BRWalletBalance(_wallet));
}

JNIEXPORT jbyteArray
Java_com_breadwallet_wallet_BRWalletManager_getMasterPubKey(JNIEnv *env, jobject thiz,
                                                            jbyteArray phrase) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getMasterPubKey");
    (*env)->GetArrayLength(env, phrase);
    jbyte *bytePhrase = (*env)->GetByteArrayElements(env, phrase, 0);
    const char *rawPhrase = (const char *) bytePhrase;
//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "rawPhrase: %s", rawPhrase);
    UInt512 key = UINT512_ZERO;

    BRBIP39DeriveKey(key.u8, rawPhrase, NULL);

    BRMasterPubKey pubKey = BRBIP32MasterPubKey(key.u8, sizeof(key));
    size_t pubKeySize = sizeof(pubKey);
    jbyte *pubKeyBytes = (jbyte *) &pubKey;
    jbyteArray result = (*env)->NewByteArray(env, (jsize) pubKeySize);

    (*env)->SetByteArrayRegion(env, result, 0, (jsize) pubKeySize, (const jbyte *) pubKeyBytes);
    //release everything
    (*env)->ReleaseByteArrayElements(env, phrase, bytePhrase, JNI_ABORT);
    return result;
}

//Call multiple times with all the transactions from the DB
JNIEXPORT void
Java_com_breadwallet_wallet_BRWalletManager_putTransaction(JNIEnv *env, jobject thiz,
                                                           jbyteArray transaction,
                                                           jlong jBlockHeight, jlong jTimeStamp) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "putTransaction");
    if (!_transactions) return;

    int txLength = (*env)->GetArrayLength(env, transaction);
    jbyte *byteTx = (*env)->GetByteArrayElements(env, transaction, 0);

    assert(byteTx != NULL);
    if (!byteTx) return;

    BRTransaction *tmpTx = BRTransactionParse((uint8_t *) byteTx, (size_t) txLength);

    assert(tmpTx != NULL);
    if (!tmpTx) return;
    tmpTx->blockHeight = (uint32_t) jBlockHeight;
    tmpTx->timestamp = (uint32_t) jTimeStamp;
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "tmpTx->timestamp: %u",
                        tmpTx->timestamp);
//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "tmpTx: %s", u256_hex_encode(tmpTx->txHash));
    _transactions[_transactionsCounter++] = tmpTx;
}

JNIEXPORT void JNICALL
Java_com_breadwallet_wallet_BRWalletManager_createTxArrayWithCount(JNIEnv *env, jobject thiz,
                                                                   int txCount) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "createTxArrayWithCount: %d",
                        txCount);
    _transactions = calloc((size_t) txCount, sizeof(*_transactions));
    _transactionsCounter = 0;

    // need to call free(transactions);
}

JNIEXPORT jstring JNICALL Java_com_breadwallet_wallet_BRWalletManager_getReceiveAddress(JNIEnv *env,
                                                                                        jobject thiz) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getReceiveAddress");
    if (!_wallet) return NULL;

    BRAddress receiveAddress = BRWalletReceiveAddress(_wallet);

    return (*env)->NewStringUTF(env, receiveAddress.s);
}

JNIEXPORT jobjectArray JNICALL Java_com_breadwallet_wallet_BRWalletManager_getTransactions(
        JNIEnv *env, jobject thiz) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getTransactions");
    if (!_wallet) return NULL;
    if (BRWalletTransactions(_wallet, NULL, 0) == 0) return NULL;
    //Retrieve the txs array

    size_t txCount = BRWalletTransactions(_wallet, NULL, 0);
    BRTransaction **transactions_sqlite = calloc(BRWalletTransactions(_wallet, NULL, 0),
                                                 sizeof(BRTransaction *));

    txCount = BRWalletTransactions(_wallet, transactions_sqlite, txCount);

    //Find the class and populate the array of objects of this class
    jclass txClass = (*env)->FindClass(env,
                                       "com/breadwallet/presenter/entities/TransactionListItem");
    jobjectArray txObjects = (*env)->NewObjectArray(env, (jsize) txCount, txClass, 0);
    jobjectArray globalTxs = (*env)->NewGlobalRef(env, txObjects);
    jmethodID txObjMid = (*env)->GetMethodID(env, txClass, "<init>",
                                             "(JILjava/lang/String;JJJ[Ljava/lang/String;[Ljava/lang/String;J[J)V");
    jclass stringClass = (*env)->FindClass(env, "java/lang/String");

    for (int i = 0; i < txCount; i++) {
        if (!_wallet) return NULL;

        jlong JtimeStamp = transactions_sqlite[i]->timestamp;
        jint JblockHeight = transactions_sqlite[i]->blockHeight;
        UInt256 txid = transactions_sqlite[i]->txHash;
        jstring JtxHash = (*env)->NewStringUTF(env, u256_hex_encode(txid));
        jlong Jsent = (jlong) BRWalletAmountSentByTx(_wallet, transactions_sqlite[i]);
        jlong Jreceived = (jlong) BRWalletAmountReceivedFromTx(_wallet, transactions_sqlite[i]);
        jlong Jfee = (jlong) BRWalletFeeForTx(_wallet, transactions_sqlite[i]);
        int outCountTemp = (int) transactions_sqlite[i]->outCount;
        jlongArray JoutAmounts = (*env)->NewLongArray(env, outCountTemp);
        jobjectArray JtoAddresses = (*env)->NewObjectArray(env, outCountTemp, stringClass, 0);

//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "JtoAddresses: %d",
//                            (*env)->GetArrayLength(env, JtoAddresses));

        int outCountAfterFilter = 0;

        for (int j = 0; j < outCountTemp; j++) {
            if (Jsent > 0) {
                if (!BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {
                    jstring str = (*env)->NewStringUTF(env,
                                                       transactions_sqlite[i]->outputs[j].address);
                    (*env)->SetObjectArrayElement(env, JtoAddresses, outCountAfterFilter, str);
                    (*env)->SetLongArrayRegion(env, JoutAmounts, outCountAfterFilter++, 1,
                                               (const jlong *) &transactions_sqlite[i]->outputs[j].amount);
                    (*env)->DeleteLocalRef(env, str);
                }

            }
            else if (BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {
                jstring str = (*env)->NewStringUTF(env, transactions_sqlite[i]->outputs[j].address);
                (*env)->SetObjectArrayElement(env, JtoAddresses, outCountAfterFilter, str);
                (*env)->SetLongArrayRegion(env, JoutAmounts, outCountAfterFilter++, 1,
                                           (const jlong *) &transactions_sqlite[i]->outputs[j].amount);
                (*env)->DeleteLocalRef(env, str);
            }
        }

        int inCountTemp = (int) transactions_sqlite[i]->inCount;
        jobjectArray JfromAddresses = (*env)->NewObjectArray(env, inCountTemp, stringClass, 0);

//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "JfromAddresses: %d", (*env)->GetArrayLength(env, JfromAddresses));

        int inCountAfterFilter = 0;

        for (int j = 0; j < inCountTemp; j++) {
            if (Jsent > 0) {
                jstring str = (*env)->NewStringUTF(env, transactions_sqlite[i]->inputs[j].address);

                (*env)->SetObjectArrayElement(env, JfromAddresses, inCountAfterFilter++, str);
                (*env)->DeleteLocalRef(env, str);
            }
            else {
                jstring str = (*env)->NewStringUTF(env, transactions_sqlite[i]->inputs[j].address);

                (*env)->SetObjectArrayElement(env, JfromAddresses, inCountAfterFilter++, str);
                (*env)->DeleteLocalRef(env, str);
            }
        }

        jlong JbalanceAfterTx = (jlong) BRWalletBalanceAfterTx(_wallet, transactions_sqlite[i]);

        jobject txObject = (*env)->NewObject(env, txClass, txObjMid, JtimeStamp, JblockHeight,
                                             JtxHash, Jsent,
                                             Jreceived, Jfee, JtoAddresses, JfromAddresses,
                                             JbalanceAfterTx,
                                             JoutAmounts);

        (*env)->SetObjectArrayElement(env, globalTxs, (jsize) (txCount - 1 - i), txObject);
        (*env)->DeleteLocalRef(env, txObject);
        (*env)->DeleteLocalRef(env, JfromAddresses);
        (*env)->DeleteLocalRef(env, JtoAddresses);
        (*env)->DeleteLocalRef(env, JoutAmounts);
        (*env)->DeleteLocalRef(env, JtxHash);
    }

    if (transactions_sqlite) {
        free(transactions_sqlite);
        transactions_sqlite = NULL;
    }

    return globalTxs;
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_validateAddress(JNIEnv *env, jobject obj,
                                                            jstring address) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "validateAddress");

    const char *str = (*env)->GetStringUTFChars(env, address, NULL);
    int result = BRAddressIsValid(str);

    (*env)->ReleaseStringUTFChars(env, address, str);
    return (jboolean) (result ? JNI_TRUE : JNI_FALSE);

}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_addressContainedInWallet(JNIEnv *env, jobject obj,
                                                                     jstring address) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "addressContainedInWallet");
    if (!_wallet) return JNI_FALSE;

    const char *str = (*env)->GetStringUTFChars(env, address, NULL);
    int result = BRWalletContainsAddress(_wallet, str);

    (*env)->ReleaseStringUTFChars(env, address, str);
    return (jboolean) (result ? JNI_TRUE : JNI_FALSE);
}

JNIEXPORT jlong JNICALL
Java_com_breadwallet_wallet_BRWalletManager_getMinOutputAmount(JNIEnv *env, jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getMinOutputAmount");

    if (!_wallet) return 0;
    return (jlong) BRWalletMinOutputAmount(_wallet);
}

JNIEXPORT jlong JNICALL
Java_com_breadwallet_wallet_BRWalletManager_getMinOutputAmountRequested(JNIEnv *env, jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getMinOutputAmountRequested");
    return (jlong) TX_MIN_OUTPUT_AMOUNT;
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_addressIsUsed(JNIEnv *env, jobject obj,
                                                          jstring address) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "addressIsUsed");
    if (!_wallet) return JNI_FALSE;

    const char *str = (*env)->GetStringUTFChars(env, address, NULL);
    int result = BRWalletAddressIsUsed(_wallet, str);

    (*env)->ReleaseStringUTFChars(env, address, str);
    return (jboolean) (result ? JNI_TRUE : JNI_FALSE);
}


JNIEXPORT jlong JNICALL
Java_com_breadwallet_wallet_BRWalletManager_getMaxOutputAmount(JNIEnv *env, jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getMaxOutputAmount");
    return (jlong) BRWalletMaxOutputAmount(_wallet);
}

JNIEXPORT jint JNICALL
Java_com_breadwallet_wallet_BRWalletManager_feeForTransaction(JNIEnv *env, jobject obj,
                                                              jstring address, jlong amount) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "feeForTransaction");
    if (!_wallet) return 0;

    const char *rawAddress = (*env)->GetStringUTFChars(env, address, NULL);
    BRTransaction *tx = BRWalletCreateTransaction(_wallet, (uint64_t) amount, rawAddress);

    return tx ? (jint) BRWalletFeeForTx(_wallet, tx) : 0;
}

JNIEXPORT jbyteArray JNICALL
Java_com_breadwallet_wallet_BRWalletManager_tryTransaction(JNIEnv *env, jobject obj,
                                                           jstring jAddress, jlong jAmount) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "tryTransaction");
    if (!_wallet) return 0;

    const char *rawAddress = (*env)->GetStringUTFChars(env, jAddress, NULL);
    BRTransaction *tx = BRWalletCreateTransaction(_wallet, (uint64_t) jAmount, rawAddress);

    if (!tx) return NULL;

    size_t len = BRTransactionSerialize(tx, NULL, 0);
    uint8_t *buf = malloc(len);

    len = BRTransactionSerialize(tx, buf, len);

    jbyteArray result = (*env)->NewByteArray(env, (jsize) len);

    (*env)->SetByteArrayRegion(env, result, 0, (jsize) len, (jbyte *) buf);
    free(buf);
    return result;
}

JNIEXPORT jboolean JNICALL Java_com_breadwallet_wallet_BRWalletManager_isCreated(JNIEnv *env,
                                                                                 jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "wallet isCreated %s",
                        _wallet ? "yes" : "no");
    return (jboolean) (_wallet ? JNI_TRUE : JNI_FALSE);
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_transactionIsVerified(JNIEnv *env, jobject obj,
                                                                  jstring jtxHash) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "transactionIsVerified");
    if (!_wallet) return JNI_FALSE;

    const char *txHash = (*env)->GetStringUTFChars(env, jtxHash, NULL);
    UInt256 txHashResult = u256_hex_decode(txHash);
    BRTransaction *tx = BRWalletTransactionForHash(_wallet, txHashResult);

    if (!tx) return JNI_FALSE;

    int result = BRWalletTransactionIsVerified(_wallet, tx);

    return (jboolean) (result ? JNI_TRUE : JNI_FALSE);
}


JNIEXPORT jlong JNICALL
Java_com_breadwallet_wallet_BRWalletManager_bitcoinAmount(JNIEnv *env, jobject thiz,
                                                          jlong localAmount, double price) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "bitcoinAmount");
    return (jlong) BRBitcoinAmount(localAmount, price);
}

JNIEXPORT jlong
Java_com_breadwallet_wallet_BRWalletManager_localAmount(JNIEnv *env, jobject thiz, jlong amount,
                                                        double price) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "localAmount");
    return (jlong) BRLocalAmount(amount, price);
}

JNIEXPORT void JNICALL
Java_com_breadwallet_wallet_BRWalletManager_walletFreeEverything(JNIEnv *env, jobject thiz) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "walletFreeEverything");

    if (_wallet) {
        BRWalletFree(_wallet);
        _wallet = NULL;
    }

    if (_transactions) {
        _transactions = NULL;
    }
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_validateRecoveryPhrase(JNIEnv *env, jobject obj,
                                                                   jobjectArray stringArray,
                                                                   jstring jPhrase) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "validateRecoveryPhrase");

    int wordsCount = (*env)->GetArrayLength(env, stringArray);
    char *wordList[wordsCount];

    for (int i = 0; i < wordsCount; i++) {
        jstring string = (jstring) (*env)->GetObjectArrayElement(env, stringArray, i);
        const char *rawString = (*env)->GetStringUTFChars(env, string, 0);

        wordList[i] = malloc(strlen(rawString) + 1);
        strcpy(wordList[i], rawString);
        (*env)->ReleaseStringUTFChars(env, string, rawString);
        (*env)->DeleteLocalRef(env, string);
    }

    (*env)->GetArrayLength(env, jPhrase);
     jbyte *bytePhrase = (*env)->GetByteArrayElements(env, jPhrase, 0); 
    const char *str = (const char *) bytePhrase;
    int result = BRBIP39PhraseIsValid((const char **) wordList, str);

    (*env)->ReleaseByteArrayElements(env, jPhrase, bytePhrase, JNI_ABORT);

    return (jboolean) (result ? JNI_TRUE : JNI_FALSE);
}

JNIEXPORT jstring JNICALL
Java_com_breadwallet_wallet_BRWalletManager_getFirstAddress(JNIEnv *env, jobject thiz,
                                                            jbyteArray bytePubKey) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getFirstAddress");

    BRAddress address = BR_ADDRESS_NONE;
    jbyte *pubKeyBytes = (*env)->GetByteArrayElements(env, bytePubKey, 0);
    BRMasterPubKey mpk = *(BRMasterPubKey *) pubKeyBytes;
    uint8_t pubKey[33];
    BRKey key;

    BRBIP32PubKey(pubKey, sizeof(pubKey), mpk, 0, 0);
    BRKeySetPubKey(&key, pubKey, sizeof(pubKey));
    BRKeyAddress(&key, address.s, sizeof(address));
    return (*env)->NewStringUTF(env, address.s);
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_publishSerializedTransaction(JNIEnv *env, jobject thiz,
                                                                         jbyteArray serializedTransaction,
                                                                         jbyteArray phrase) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "publishSerializedTransaction");
    if (!_peerManager) return JNI_FALSE;

    int txLength = (*env)->GetArrayLength(env, serializedTransaction);
    jbyte *byteTx = (*env)->GetByteArrayElements(env, serializedTransaction, 0);
    BRTransaction *tmpTx = BRTransactionParse((uint8_t *) byteTx, (size_t) txLength);

    if (!tmpTx) return JNI_FALSE;

    (*env)->GetArrayLength(env, phrase);
     jbyte *bytePhrase = (*env)->GetByteArrayElements(env, phrase, 0); 
    const char *rawString = (const char *) bytePhrase;
    UInt512 key = UINT512_ZERO;
    BRBIP39DeriveKey(key.u8, rawString, NULL);

    size_t seedSize = sizeof(key);

    BRWalletSignTransaction(_wallet, tmpTx, key.u8, seedSize);
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "BRTransactionIsSigned(tmpTx): %d",
                        BRTransactionIsSigned(tmpTx));
    if (!tmpTx) return JNI_FALSE;
    BRPeerManagerPublishTx(_peerManager, tmpTx, NULL, callback);
    (*env)->ReleaseByteArrayElements(env, phrase, bytePhrase, JNI_ABORT);
    return JNI_TRUE;
}

JNIEXPORT jlong JNICALL Java_com_breadwallet_wallet_BRWalletManager_getTotalSent(JNIEnv *env,
                                                                                 jobject obj) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getTotalSent");
    if (!_wallet) return 0;
    return (jlong) BRWalletTotalSent(_wallet);
}

JNIEXPORT void JNICALL Java_com_breadwallet_wallet_BRWalletManager_setFeePerKb(JNIEnv *env,
                                                                               jobject obj,
                                                                               jlong fee) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "setFeePerKb");
    if (!_wallet) return;
    BRWalletSetFeePerKb(_wallet, (uint64_t) fee);
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_isValidBitcoinPrivateKey(JNIEnv *env, jobject instance,
                                                                     jstring key) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "isValidBitcoinPrivateKey");

    const char *privKey = (*env)->GetStringUTFChars(env, key, NULL);
    int result = BRPrivKeyIsValid(privKey);

    (*env)->ReleaseStringUTFChars(env, key, privKey);
    return (jboolean) ((result == 1) ? JNI_TRUE : JNI_FALSE);
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_isValidBitcoinBIP38Key(JNIEnv *env, jobject instance,
                                                                   jstring key) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "isValidBitcoinBIP38Key");

    const char *privKey = (*env)->GetStringUTFChars(env, key, NULL);
    int result = BRBIP38KeyIsValid(privKey);

    (*env)->ReleaseStringUTFChars(env, key, privKey);
    return (jboolean) ((result == 1) ? JNI_TRUE : JNI_FALSE);
}

JNIEXPORT jstring JNICALL
Java_com_breadwallet_wallet_BRWalletManager_getAddressFromPrivKey(JNIEnv *env, jobject instance,
                                                                  jstring privKey) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getAddressFromPrivKey");

    const char *rawPrivKey = (*env)->GetStringUTFChars(env, privKey, NULL);
    BRKey key;
    BRAddress addr;

    BRKeySetPrivKey(&key, rawPrivKey);
    BRKeyAddress(&key, addr.s, sizeof(addr));

    jstring result = (*env)->NewStringUTF(env, addr.s);
    return result;
}

JNIEXPORT jstring JNICALL
Java_com_breadwallet_wallet_BRWalletManager_decryptBip38Key(JNIEnv *env, jobject instance,
                                                            jstring privKey,
                                                            jstring pass) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "decryptBip38Key");

    BRKey key;
    const char *rawPrivKey = (*env)->GetStringUTFChars(env, privKey, NULL);
    const char *rawPass = (*env)->GetStringUTFChars(env, pass, NULL);
    int result = BRKeySetBIP38Key(&key, rawPrivKey, rawPass);

    if (result) {
        char pk[BRKeyPrivKey(&key, NULL, 0)];

        BRKeyPrivKey(&key, pk, sizeof(pk));
        return (*env)->NewStringUTF(env, pk);
    }
    else return (*env)->NewStringUTF(env, "");
}

JNIEXPORT void JNICALL Java_com_breadwallet_wallet_BRWalletManager_createInputArray(JNIEnv *env,
                                                                                    jobject thiz) {
    if (_privKeyTx) {
        BRTransactionFree(_privKeyTx);
        _privKeyTx = NULL;
    }

    _privKeyBalance = 0;
    _privKeyTx = BRTransactionNew();
}

JNIEXPORT void JNICALL
Java_com_breadwallet_wallet_BRWalletManager_addInputToPrivKeyTx(JNIEnv *env, jobject thiz,
                                                                jbyteArray hash, int vout,
                                                                jbyteArray script, jlong amount) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "addInputToPrivKeyTx");
    _privKeyBalance += amount;

    jsize hashLength = (*env)->GetArrayLength(env, hash);
    jsize scriptLength = (*env)->GetArrayLength(env, script);

    if (hashLength > 256 || !_privKeyTx) return;

    jbyte *rawHash = (*env)->GetByteArrayElements(env, hash, 0);
    jbyte *rawScript = (*env)->GetByteArrayElements(env, script, 0);
    UInt256 reversedHash = UInt256Reverse((*(UInt256 *) rawHash));

    BRTransactionAddInput(_privKeyTx, reversedHash, (uint32_t) vout, (const uint8_t *) rawScript,
                          (size_t) scriptLength, NULL, 0, TXIN_SEQUENCE);
}

JNIEXPORT jobject JNICALL Java_com_breadwallet_wallet_BRWalletManager_getPrivKeyObject(JNIEnv *env,
                                                                                       jobject thiz) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getPrivKeyObject");
    if (!_privKeyTx) return NULL;

    jclass importPrivKeyClass = (*env)->FindClass(env,
                                                  "com/breadwallet/presenter/entities/ImportPrivKeyEntity");
    BRAddress address = BRWalletChangeAddress(_wallet);
    uint8_t script[BRAddressScriptPubKey(NULL, 0, address.s)];
    size_t scriptLen = BRAddressScriptPubKey(script, sizeof(script), address.s);

    BRTransactionAddOutput(_privKeyTx, 0, script, scriptLen);

    uint64_t fee = BRWalletFeeForTxSize(_wallet, BRTransactionSize(_privKeyTx));

    _privKeyTx->outputs[0].amount = _privKeyBalance - fee;

    jmethodID txObjMid = (*env)->GetMethodID(env, importPrivKeyClass, "<init>", "([BJJ)V");

    uint8_t buf[BRTransactionSerialize(_privKeyTx, NULL, 0)];
    size_t len = BRTransactionSerialize(_privKeyTx, buf, sizeof(buf));
    jbyteArray result = (*env)->NewByteArray(env, (jsize) len);

    (*env)->SetByteArrayRegion(env, result, 0, (jsize) len, (jbyte *) buf);

    jobject txObject = (*env)->NewObject(env, importPrivKeyClass, txObjMid, result,
                                         _privKeyBalance - fee, fee);
    return txObject;
}

JNIEXPORT jboolean JNICALL
Java_com_breadwallet_wallet_BRWalletManager_confirmKeySweep(JNIEnv *env, jobject thiz,
                                                            jbyteArray tx, jstring privKey) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "confirmKeySweep");
    if (!_peerManager) return JNI_FALSE;

    int txLength = (*env)->GetArrayLength(env, tx);
    jbyte *byteTx = (*env)->GetByteArrayElements(env, tx, 0);
    BRTransaction *tmpTx = BRTransactionParse((uint8_t *) byteTx, (size_t) txLength);

    if (!tmpTx) return JNI_FALSE;

    const char *rawString = (*env)->GetStringUTFChars(env, privKey, 0);
    BRKey key;

    BRKeySetPrivKey(&key, rawString);
    BRTransactionSign(tmpTx, &key, 1);
    if (!tmpTx || !BRTransactionIsSigned(tmpTx)) return JNI_FALSE;

    uint8_t buf[BRTransactionSerialize(tmpTx, NULL, 0)];
    size_t len = BRTransactionSerialize(tmpTx, buf, sizeof(buf));

    BRPeerManagerPublishTx(_peerManager, tmpTx, NULL, callback);
    return JNI_TRUE;
}

JNIEXPORT jstring JNICALL
Java_com_breadwallet_wallet_BRWalletManager_reverseTxHash(JNIEnv *env, jobject thiz,
                                                          jstring txHash) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "reverseTxHash");

    const char *rawString = (*env)->GetStringUTFChars(env, txHash, 0);
    UInt256 theHash = u256_hex_decode(rawString);
    UInt256 reversedHash = UInt256Reverse(theHash);

    return (*env)->NewStringUTF(env, u256_hex_encode(reversedHash));
}

JNIEXPORT jint JNICALL Java_com_breadwallet_wallet_BRWalletManager_getTxCount(JNIEnv *env,
                                                                              jobject thiz) {
    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "reverseTxHash");
    if (!_wallet) return 0;
    return (jint) BRWalletTransactions(_wallet, NULL, 0);
}