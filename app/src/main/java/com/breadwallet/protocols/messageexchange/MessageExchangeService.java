package com.breadwallet.protocols.messageexchange;

import android.content.Context;
import android.support.annotation.VisibleForTesting;
import android.support.annotation.WorkerThread;
import android.util.Base64;
import android.util.Log;

import com.breadwallet.BreadApp;
import com.breadwallet.core.BRCoreKey;
import com.breadwallet.protocols.messageexchange.entities.EncryptedMessage;
import com.breadwallet.protocols.messageexchange.entities.InboxEntry;
import com.breadwallet.protocols.messageexchange.entities.PairingObject;
import com.breadwallet.tools.crypto.Base58;
import com.breadwallet.tools.crypto.CryptoHelper;
import com.breadwallet.tools.manager.BRSharedPrefs;
import com.breadwallet.tools.security.BRKeyStore;
import com.breadwallet.tools.util.Utils;
import com.breadwallet.wallet.WalletsMaster;
import com.breadwallet.wallet.abstracts.BaseWalletManager;
import com.breadwallet.wallet.wallets.CryptoTransaction;
import com.google.protobuf.ByteString;
import com.google.protobuf.InvalidProtocolBufferException;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on <mihail@breadwallet.com> 7/12/18.
 * Copyright (c) 2018 breadwallet LLC
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

public final class MessageExchangeService /*extends Service*/ {
    private static final String TAG = MessageExchangeService.class.getSimpleName();
    private static ByteString mSenderId = null;
    private static ByteString mPairingPublicKey = null;
    private static final int NONCE_SIZE = 12;

    public static final int ENVELOPE_VERSION = 1;
    public static final String SERVICE_PWB = "PWB";

    public enum MessageType {
        LINK,
        PING,
        PONG,
        ACCOUNT_REQUEST,
        ACCOUNT_RESPONSE,
        PAYMENT_REQUEST,
        PAYMENT_RESPONSE,
        CALL_REQUEST,
        CALL_RESPONSE
    }

    private MessageExchangeService() {
    }

    public static Protos.Envelope createEnvelope(ByteString encryptedMessage, MessageType messageType,
                                                 ByteString senderPublicKey, ByteString receiverPublicKey,
                                                 String uniqueId, ByteString nonce) {
        Protos.Envelope envelope = Protos.Envelope.newBuilder()
                .setVersion(ENVELOPE_VERSION)
                .setMessageType(messageType.name())
                .setService(SERVICE_PWB)
                .setEncryptedMessage(encryptedMessage)
                .setSenderPublicKey(senderPublicKey)
                .setReceiverPublicKey(receiverPublicKey)
                .setIdentifier(uniqueId)
                .setSignature(ByteString.EMPTY)
                .setNonce(nonce)
                .build();
        return envelope;

    }

    public static BRCoreKey getPairingKey(Context context, byte[] senderPublicKey, byte[] id) {
        if (Utils.isNullOrEmpty(senderPublicKey) || Utils.isNullOrEmpty(id)) {
            Log.e(TAG, "pairWallet: invalid query parameters");
            return null;
        }
        byte[] authKey = BRKeyStore.getAuthKey(context);
        return new BRCoreKey(authKey).getPairingKey(id);
    }

    public static EncryptedMessage encrypt(BRCoreKey authKey, byte[] senderPublicKey, byte[] data) {
        byte[] nonce = generateRandomNonce();
        byte[] encryptedData = authKey.encryptUsingSharedSecret(senderPublicKey, data, nonce);
        return new EncryptedMessage(encryptedData, nonce);
    }

    public static byte[] decrypt(BRCoreKey authKey, byte[] senderPublicKey, byte[] encryptedMessage, byte[] nonce) {
        return authKey.decryptUsingSharedSecret(senderPublicKey, encryptedMessage, nonce);
    }


    public static void processInboxMessages(Context context, List<InboxEntry> inboxEntries) {
        Log.e(TAG, "processInboxMessages: " + inboxEntries.size());
        List<String> cursors = new ArrayList<>();
        for (InboxEntry inboxEntry : inboxEntries) {
            Protos.Envelope requestEnvelope = getEnvelopeFromInbox(inboxEntry);
            boolean isEnvelopValid = verifyEnvelope(requestEnvelope);
//            if (!isEnvelopValid) {
//                Log.e(TAG, "createResponseEnvelope: verifyEnvelope failed!!!");
//                continue;
//            }
            BRCoreKey authKey = new BRCoreKey(BRKeyStore.getAuthKey(context));
            Protos.Envelope responseEnvelope = createResponseEnvelope(authKey, requestEnvelope);
            if (responseEnvelope == null) {
                Log.e(TAG, "processInboxMessages: responseEnvelope is null!");
                continue;
            }
            cursors.add(inboxEntry.getCursor());
            MessageExchangeNetworkHelper.sendEnvelope(context, responseEnvelope.toByteArray());
        }
        MessageExchangeNetworkHelper.sendAck(context, cursors);
    }

    public static void checkInboxAndRespond(Context context) {
        List<InboxEntry> inboxEntries = MessageExchangeNetworkHelper.fetchInbox(context);
        processInboxMessages(context, inboxEntries);
    }

    /**
     * @param envelope the envelope to verify
     * @return true if valid
     */
    public static boolean verifyEnvelope(Protos.Envelope envelope) {
        byte[] signature = envelope.getSignature().toByteArray();
        byte[] senderPublicKey = envelope.getSenderPublicKey().toByteArray();
        envelope = envelope.toBuilder().setSignature(ByteString.EMPTY).build();
        byte[] envelopeDoubleSha256 = CryptoHelper.doubleSha256(envelope.toByteArray());
        if (Utils.isNullOrEmpty(signature)) {
            Log.e(TAG, "verifyEnvelope: signature missing.");
            return false;
        }
        BRCoreKey key = BRCoreKey.compactSignRecoverKey(envelopeDoubleSha256, signature);
        byte[] recoveredPubKey = key.getPubKey();
        return Arrays.equals(senderPublicKey, recoveredPubKey);
    }

    public static Protos.Envelope createResponseEnvelope(BRCoreKey authKey, Protos.Envelope requestEnvelope) {
        int version = requestEnvelope.getVersion();
        String service = requestEnvelope.getService();
        String expiration = requestEnvelope.getExpiration();
        String messageType = requestEnvelope.getMessageType();
        ByteString encryptedMessage = requestEnvelope.getEncryptedMessage();
        ByteString senderPublicKey = requestEnvelope.getSenderPublicKey();
        ByteString receiverPublicKey = requestEnvelope.getReceiverPublicKey();
        String identifier = requestEnvelope.getIdentifier();
        ByteString nonce = requestEnvelope.getNonce();
        ByteString signature = requestEnvelope.getSignature();

        try {
            requestEnvelope = requestEnvelope.toBuilder().setSignature(ByteString.EMPTY).build();
            byte[] pubKey = authKey.getPubKey();
            byte[] decryptedMessageBytes = decrypt(authKey, senderPublicKey.toByteArray(), encryptedMessage.toByteArray(), nonce.toByteArray());
            MessageType requestMessageType = MessageType.valueOf(messageType);
            ByteString messageResponse = generateResponseMessage(authKey, decryptedMessageBytes, requestMessageType);
            EncryptedMessage responseEncryptedMessage = encrypt(authKey, senderPublicKey.toByteArray(), messageResponse.toByteArray());
            MessageType responseMessageType = getResponseMessageType(requestMessageType);
            byte[] responseSignature = authKey.compactSign(CryptoHelper.doubleSha256(requestEnvelope.toByteArray()));
            Protos.Envelope responseEnvelope = createEnvelope(ByteString.copyFrom(responseEncryptedMessage.getEncryptedData()),
                    responseMessageType, ByteString.copyFrom(pubKey), senderPublicKey, identifier,
                    ByteString.copyFrom(responseEncryptedMessage.getNonce()));
            responseEnvelope = responseEnvelope.toBuilder().setSignature(ByteString.copyFrom(responseSignature)).build();
            return responseEnvelope;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private static Protos.Envelope getEnvelopeFromInbox(InboxEntry entry) {
        Protos.Envelope requestEnvelope = null;
        try {
            byte[] envelopeData = Base64.decode(entry.getMessage(), Base64.NO_WRAP);
            requestEnvelope = Protos.Envelope.parseFrom(envelopeData);
        } catch (InvalidProtocolBufferException e) {
            e.printStackTrace();
            return null;
        }
        return requestEnvelope;
    }

    private static MessageType getResponseMessageType(MessageType requestMessageType) {
        switch (requestMessageType) {
            case LINK:
                return MessageType.LINK;
            case PING:
                return MessageType.PONG;
            case ACCOUNT_REQUEST:
                return MessageType.ACCOUNT_RESPONSE;
            case PAYMENT_REQUEST:
                return MessageType.PAYMENT_RESPONSE;
            case CALL_REQUEST:
                return MessageType.CALL_RESPONSE;
        }
        return null;
    }

    private static ByteString generateResponseMessage(BRCoreKey authKey, byte[] requestDecryptedMessage, MessageType requestMessageType) {
        try {
            switch (requestMessageType) {
                case LINK:
                    byte[] pubKey = authKey.getPubKey();
                    Protos.Link linkMessage = Protos.Link.parseFrom(requestDecryptedMessage);
                    mSenderId = linkMessage.getId();
                    mPairingPublicKey = linkMessage.getPublicKey();
                    //don't respond, at this point we received what we need for our paring, wait for other messages.
//                resultMessage = createLinkMessage(pubKey, Protos.Status.ACCEPTED, mSenderId);
                    return null;
                case PING:
                    return Protos.Pong.newBuilder().setPong("This is the message of the day.").build().getPongBytes();
                case ACCOUNT_REQUEST:
                    return generateAccountResponse(requestDecryptedMessage);
                case PAYMENT_REQUEST:
                    return generatePaymentResponse(requestDecryptedMessage);
                case CALL_REQUEST:
                    return generateCallResponse(requestDecryptedMessage);
                default:
                    Log.e(TAG, "Request type not recognized:" + requestMessageType.name());
            }
        } catch (InvalidProtocolBufferException e) {
            Log.e(TAG, "Error parsing protobuf for " + requestMessageType.name() + "message.", e);
            // TODO: SHIV re-throw?
        }
        return null;
    }

    private static ByteString createLinkMessage(byte[] pubKey, Protos.Status status, ByteString senderId) {
        return Protos.Link.newBuilder().setPublicKey(ByteString.copyFrom(pubKey))
                .setStatus(status).setId(senderId).build().toByteString();
    }

    @VisibleForTesting
    protected static ByteString generateAccountResponse(byte[] requestDecryptedMessage) throws InvalidProtocolBufferException {
        Protos.AccountRequest request = Protos.AccountRequest.parseFrom(requestDecryptedMessage);

        String currencyCode = request.getScope();
        Context context = BreadApp.getBreadContext(); // TODO: SHIV remove once we have a service.
        BaseWalletManager walletManager = WalletsMaster.getInstance(context).getWalletByIso(context, currencyCode);

        Protos.AccountResponse.Builder responseBuilder = Protos.AccountResponse.newBuilder().setScope(currencyCode);
        if (walletManager == null) {
            responseBuilder.setStatus(Protos.Status.REJECTED);
        } else {
            String address = walletManager.getAddress();

            if (address == null) {
                responseBuilder.setStatus(Protos.Status.REJECTED);
            } else {
                responseBuilder.setAddress(address)
                        .setStatus(Protos.Status.ACCEPTED);
            }
        }

        return responseBuilder.build().toByteString();
    }

    private static ByteString generatePaymentResponse(byte[] requestDecryptedMessage) throws InvalidProtocolBufferException {
        Protos.PaymentRequest request = Protos.PaymentRequest.parseFrom(requestDecryptedMessage);

        String currencyCode = request.getScope();
        Context context = BreadApp.getBreadContext(); // TODO: SHIV remove once we have a service.
        BaseWalletManager walletManager = WalletsMaster.getInstance(context).getWalletByIso(context, currencyCode);

        // TODO: SHIV transact
//        String network = request.getNetwork(); // a network designation
//        String address = request.getAddress(); // the receive address for the desired payment
//        BigDecimal amount = new BigDecimal(Integer.parseInt(request.getAmount())); // the desired amount expressed as an integer in the lowest currency denomination
//        String memo = request.getMemo(); // optionally a request may include a memo, the receiver can retain if necessary

        CryptoTransaction transaction = walletManager.createTransaction(new BigDecimal(request.getAmount()), request.getAddress());
        boolean transactionSuccessful = true;
        // Investigate PostAuth.getInstance().onPublishTxAuth(); ???

        Protos.PaymentResponse.Builder responseBuilder = Protos.PaymentResponse.newBuilder().setScope(currencyCode);

        if (transactionSuccessful) {
            responseBuilder.setStatus(Protos.Status.ACCEPTED)
                    .setTransactionId(transaction.getHash());
        } else {
            responseBuilder.setStatus(Protos.Status.REJECTED);
        }

        return responseBuilder.build().toByteString();
    }

    private static ByteString generateCallResponse(byte[] requestDecryptedMessage) throws InvalidProtocolBufferException {
        Protos.CallRequest request = Protos.CallRequest.parseFrom(requestDecryptedMessage);

        String currencyCode = request.getScope();
        Context context = BreadApp.getBreadContext(); // TODO: SHIV remove once we have a service.
        BaseWalletManager walletManager = WalletsMaster.getInstance(context).getWalletByIso(context, currencyCode);

        // TODO: SHIV transact
// message_type = "CALL_REQUEST"
//        message CallRequest {
//            required string scope = 1;      // should be a currency code eg "ETH" or "BRD"
//            optional string network = 2 [default = "mainnet"];  // a network designation
//                required string address = 3;    // the smart contract address
//                required string abi = 4;        // the abi-encoded parameters to send to the smart contract
//                required string amount = 5;     // the desired amount expressed as an integer in the lowest currency denomination
//                optional string memo = 6;       // optionally a request may include a memo, the receiver can retain if necessary
//        }


        CryptoTransaction transaction = walletManager.createTransaction(new BigDecimal(request.getAmount()), request.getAddress());
        boolean transactionSuccessful = true;

        Protos.CallResponse.Builder responseBuilder = Protos.CallResponse.newBuilder().setScope(currencyCode);

        if (transactionSuccessful) {
            responseBuilder.setStatus(Protos.Status.ACCEPTED)
                    .setTransactionId(transaction.getHash());
        } else {
            responseBuilder.setStatus(Protos.Status.REJECTED);
        }

        return responseBuilder.build().toByteString();
    }

    @WorkerThread
    public static void startPairing(final Context context, PairingObject pairingObject) {
        BRCoreKey authCorekey = new BRCoreKey(BRKeyStore.getAuthKey(context));
        byte[] pubKey = authCorekey.getPubKey();
        try {
            ByteString message = createLinkMessage(pubKey, Protos.Status.ACCEPTED, ByteString.copyFrom(pairingObject.getId(), StandardCharsets.UTF_8.name()));
            byte[] ephemeralKey = BRCoreKey.decodeHex(pairingObject.getPublicKeyHex());
            EncryptedMessage encryptedMessage = encrypt(authCorekey, ephemeralKey, message.toByteArray());
            ByteString encryptedMessageByteString = ByteString.copyFrom(encryptedMessage.getEncryptedData());
            Protos.Envelope envelope = createEnvelope(encryptedMessageByteString, MessageType.LINK, ByteString.copyFrom(pubKey)
                    , ByteString.copyFrom(ephemeralKey), BRSharedPrefs.getDeviceId(context), ByteString.copyFrom(encryptedMessage.getNonce()));
            BRCoreKey pairingKey = getPairingKey(context, ephemeralKey, pairingObject.getId().getBytes());
            byte[] signature = authCorekey.compactSign(CryptoHelper.doubleSha256(envelope.toByteArray()));
            envelope = envelope.toBuilder().setSignature(ByteString.copyFrom(signature)).build();
            Log.e(TAG, "startPairing: " + envelope.toString());
            final byte[] envelopeData = envelope.toByteArray();
            //network call
            MessageExchangeNetworkHelper.sendEnvelope(context, envelopeData);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

    }

    public static byte[] generateRandomNonce() {
        byte[] nonce = new byte[NONCE_SIZE];
        new Random().nextBytes(nonce);
        return nonce;
    }

    public static void sendTestPing(Context context) {
        Log.e(TAG, "sendTestPing: sending");
        byte[] pubKey = Base58.decode("iRbNunsoS9P3VeGg4T2qMsXgxd3zaveva47v4vgKtQ2m");
        String identifier = "Mihail";
        ByteString message = Protos.Ping.newBuilder().setPing("Hi Dan, you're so awesome.").build().getPingBytes();
        BRCoreKey authKey = new BRCoreKey(BRKeyStore.getAuthKey(context));
        byte[] myPubKey = authKey.getPubKey();

        MessageType requestMessageType = MessageType.PING;
        EncryptedMessage responseEncryptedMessage = encrypt(authKey, pubKey, message.toByteArray());
        BRCoreKey privateKey = new BRCoreKey(BRKeyStore.getAuthKey(context));
        Protos.Envelope envelope = createEnvelope(ByteString.copyFrom(responseEncryptedMessage.getEncryptedData()),
                requestMessageType, ByteString.copyFrom(myPubKey), ByteString.copyFrom(pubKey),
                identifier, ByteString.copyFrom(responseEncryptedMessage.getNonce()));
        byte[] responseSignature = privateKey.compactSign(CryptoHelper.doubleSha256(envelope.toByteArray()));
        envelope = envelope.toBuilder().setSignature(ByteString.copyFrom(responseSignature)).build();
        MessageExchangeNetworkHelper.sendEnvelope(context, envelope.toByteArray());
        Log.e(TAG, "sendTestPing: DONE.");
    }

}
