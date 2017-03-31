package com.breadwallet.wallet;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.Toast;

import com.breadwallet.R;
import com.breadwallet.BreadWalletApp;
import com.breadwallet.exceptions.BRKeystoreErrorException;
import com.breadwallet.presenter.activities.BreadActivity;
import com.breadwallet.presenter.activities.PinActivity;
import com.breadwallet.presenter.customviews.BRDialogView;
import com.breadwallet.presenter.customviews.BRToast;
import com.breadwallet.presenter.entities.BRMerkleBlockEntity;
import com.breadwallet.presenter.entities.BRPeerEntity;
import com.breadwallet.presenter.entities.BRTransactionEntity;
import com.breadwallet.presenter.entities.CurrencyEntity;
import com.breadwallet.presenter.entities.ImportPrivKeyEntity;
import com.breadwallet.presenter.entities.PaymentRequestEntity;
import com.breadwallet.presenter.entities.TransactionListItem;
import com.breadwallet.presenter.fragments.FragmentBreadSignal;
import com.breadwallet.presenter.interfaces.BRAuthCompletion;
import com.breadwallet.presenter.interfaces.BROnSignalCompletion;
import com.breadwallet.tools.animation.BRAnimator;
import com.breadwallet.tools.animation.BreadDialog;
import com.breadwallet.tools.manager.CurrencyFetchManager;
import com.breadwallet.tools.qrcode.QRUtils;
import com.breadwallet.tools.security.AuthManager;
import com.breadwallet.tools.security.PostAuthenticationProcessor;
import com.breadwallet.tools.sqlite.CurrencyDataSource;
import com.breadwallet.tools.sqlite.MerkleBlockDataSource;
import com.breadwallet.tools.sqlite.PeerDataSource;
import com.breadwallet.tools.sqlite.TransactionDataSource;
import com.breadwallet.tools.threads.PaymentProtocolPostPaymentTask;
import com.breadwallet.tools.util.BRBitcoin;
import com.breadwallet.tools.util.BRConstants;
import com.breadwallet.tools.manager.BRNotificationManager;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.util.BRCurrency;
import com.breadwallet.tools.util.TypesConverter;
import com.breadwallet.tools.util.Utils;
import com.breadwallet.tools.util.WordsReader;
import com.breadwallet.tools.security.KeyStoreManager;
import com.google.firebase.crash.FirebaseCrash;
import com.google.zxing.WriterException;

import junit.framework.Assert;

import java.io.IOException;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static com.breadwallet.R.string.pay;
import static com.breadwallet.R.string.payment_address;
import static com.breadwallet.R.string.request;
import static com.breadwallet.presenter.activities.BreadActivity.app;


/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan <mihail@breadwallet.com> on 12/10/15.
 * Copyright (c) 2016 breadwallet LLC
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

public class BRWalletManager {
    private static final String TAG = BRWalletManager.class.getName();

    private static BRWalletManager instance;
    private static final int WHITE = 0xFFFFFFFF;
    private static final int BLACK = 0xFF000000;
    public List<OnBalanceChanged> balanceListeners;


    public void setBalance(Context context, long balance) {
        if (context == null) {
            Log.e(TAG, "setBalance: FAILED TO SET THE BALANCE");
            return;
        }
        SharedPreferencesManager.putBalance(context, balance);

        refreshAddress(context);
        for (OnBalanceChanged listener : balanceListeners) {
            if (listener != null) listener.onBalanceChanged(balance);
        }
    }

    public long getBalance(Context context) {
        return SharedPreferencesManager.getBalance(context);
    }

    private static int messageId = 0;

    private BRWalletManager() {
        balanceListeners = new ArrayList<>();
    }

    public static BRWalletManager getInstance() {
        if (instance == null) {
            instance = new BRWalletManager();
        }
        return instance;
    }

    public boolean generateRandomSeed(Context ctx) {
        SecureRandom sr = new SecureRandom();
        String[] words = new String[0];
        List<String> list;
        try {
            String languageCode = ctx.getString(R.string.lang);
            list = WordsReader.getWordList(ctx, languageCode);
            words = list.toArray(new String[list.size()]);
        } catch (IOException e) {
            e.printStackTrace();
        }
        byte[] keyBytes = sr.generateSeed(16);
        if (words.length < 2000) {
            RuntimeException ex = new IllegalArgumentException("the list is wrong, size: " + words.length);
            FirebaseCrash.report(ex);
            throw ex;
        }
        if (keyBytes.length == 0) throw new NullPointerException("failed to create the seed");
        byte[] strPhrase = encodeSeed(keyBytes, words);
        if (strPhrase == null || strPhrase.length == 0) {
            RuntimeException ex = new NullPointerException("failed to encodeSeed");
            FirebaseCrash.report(ex);
            throw ex;
        }
        boolean success = false;
        try {
            success = KeyStoreManager.putKeyStorePhrase(strPhrase, ctx, BRConstants.PUT_PHRASE_NEW_WALLET_REQUEST_CODE);
        } catch (BRKeystoreErrorException e) {
            e.printStackTrace();
        }
        if (!success) return false;
        byte[] authKey = getAuthPrivKeyForAPI(keyBytes);
        if (authKey == null || authKey.length == 0) {
            RuntimeException ex = new IllegalArgumentException("authKey is invalid");
            FirebaseCrash.report(ex);
            throw ex;
        }
        KeyStoreManager.putAuthKey(authKey, ctx);
        KeyStoreManager.putWalletCreationTime((int) (System.currentTimeMillis() / 1000), ctx);
        byte[] strBytes = TypesConverter.getNullTerminatedPhrase(strPhrase);
        byte[] pubKey = BRWalletManager.getInstance().getMasterPubKey(strBytes);
        KeyStoreManager.putMasterPublicKey(pubKey, ctx);

        return true;

    }

    public boolean wipeKeyStore(Context context) {
        Log.e(TAG, "wipeKeyStore");
        return KeyStoreManager.resetWalletKeyStore(context);
    }

    /**
     * true if keychain is available and we know that no wallet exists on it
     */
    public boolean noWallet(Context ctx) {
        byte[] pubkey = KeyStoreManager.getMasterPublicKey(ctx);

        if (pubkey == null || pubkey.length == 0) {
            byte[] phrase;
            try {
                phrase = KeyStoreManager.getKeyStorePhrase(ctx, 0);
                if (phrase == null || phrase.length == 0) {
                    return true;
                }
            } catch (BRKeystoreErrorException e) {
                e.printStackTrace();
                return false;
            }

        }
        return false;
    }

    public boolean noWalletForPlatform(Context ctx) {
        byte[] pubkey = KeyStoreManager.getMasterPublicKey(ctx);
        return pubkey == null || pubkey.length == 0;
    }

    /**
     * true if device passcode is enabled
     */
    public boolean isPasscodeEnabled(Context ctx) {
        KeyguardManager keyguardManager = (KeyguardManager) ctx.getSystemService(Activity.KEYGUARD_SERVICE);
        return keyguardManager.isKeyguardSecure();
    }

    public static boolean refreshAddress(Context ctx) {
        if (ctx == null) return false;
        String address = getReceiveAddress();
        if (Utils.isNullOrEmpty(address)) return false;
        SharedPreferencesManager.putReceiveAddress(ctx, address);
        return true;

    }

    public void wipeWalletButKeystore(final Context ctx) {
        Log.e(TAG, "wipeWalletButKeystore");
        new Thread(new Runnable() {
            @Override
            public void run() {
                BRPeerManager.getInstance().peerManagerFreeEverything();
                walletFreeEverything();
            }
        }).start();

        TransactionDataSource.getInstance(ctx).deleteAllTransactions();
        MerkleBlockDataSource.getInstance(ctx).deleteAllBlocks();
        PeerDataSource.getInstance(ctx).deleteAllPeers();
        SharedPreferencesManager.clearAllPrefs(ctx);
    }

    public boolean confirmSweep(final Context ctx, final String privKey) {
//        if (ctx == null) return false;
//        if (isValidBitcoinBIP38Key(privKey)) {
//            Log.d(TAG, "isValidBitcoinBIP38Key true");
//            ((Activity) ctx).runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//
//                    final AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
////                    builder.setmTitle("password protected key");
//
//                    final View input = ((Activity) ctx).getLayoutInflater().inflate(R.layout.view_bip38password_dialog, null);
//                    // Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
//                    builder.setView(input);
//
//                    final EditText editText = (EditText) input.findViewById(R.id.bip38password_edittext);
//
//                    (new Handler()).postDelayed(new Runnable() {
//                        public void run() {
//                            editText.dispatchTouchEvent(MotionEvent.obtain(SystemClock.uptimeMillis(), SystemClock.uptimeMillis(), MotionEvent.ACTION_DOWN, 0, 0, 0));
//                            editText.dispatchTouchEvent(MotionEvent.obtain(SystemClock.uptimeMillis(), SystemClock.uptimeMillis(), MotionEvent.ACTION_UP, 0, 0, 0));
//
//                        }
//                    }, 100);
//
//                    // Set up the buttons
//                    builder.setPositiveButton(ctx.getString(R.string.ok), new DialogInterface.OnClickListener() {
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//                            if (!((BreadWalletApp) ((Activity) ctx).getApplication()).hasInternetAccess()) {
//                                ((Activity) ctx).runOnUiThread(new Runnable() {
//                                    @Override
//                                    public void run() {
////                                        BreadDialog.showCustomDialog(ctx, ctx.getString(R.string.warning),
////                                                ctx.getString(R.string.not_connected), ctx.getString(R.string.ok));
//                                    }
//                                });
//
//                                return;
//                            }
//                            if (ctx != null)
//                                ((Activity) ctx).runOnUiThread(new Runnable() {
//                                    @Override
//                                    public void run() {
//                                        ((BreadWalletApp) ((Activity) ctx).getApplication()).showCustomToast(ctx,
//                                                ctx.getString(R.string.checking_privkey_balance), BreadActivity.screenParametersPoint.y / 2, Toast.LENGTH_LONG, 1);
//                                    }
//                                });
//                            if (editText == null) return;
//
//                            String pass = editText.getText().toString();
//                            String decryptedKey = decryptBip38Key(privKey, pass);
//
//                            if (decryptedKey.equals("")) {
//                                SpringAnimator.showAnimation(input);
//                                confirmSweep(ctx, privKey);
//                            } else {
//                                confirmSweep(ctx, decryptedKey);
//                            }
//
//                        }
//                    });
//                    builder.setNegativeButton(ctx.getString(R.string.cancel), new DialogInterface.OnClickListener() {
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//                            dialog.cancel();
//                        }
//                    });
//
//                    builder.show();
//                }
//            });
//            return true;
//        } else if (isValidBitcoinPrivateKey(privKey)) {
//            Log.d(TAG, "isValidBitcoinPrivateKey true");
//            new ImportPrivKeyTask(((Activity) ctx)).execute(privKey);
//            return true;
//        } else {
//            Log.e(TAG, "confirmSweep: !isValidBitcoinPrivateKey && !isValidBitcoinBIP38Key");
//            return false;
//        }
        return false;
    }

    public static void showWritePhraseDialog(final Context ctx, final boolean firstTime) {

        if (ctx != null) {
            ((Activity) ctx).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    boolean phraseWroteDown = SharedPreferencesManager.getPhraseWroteDown(ctx);
                    if (phraseWroteDown) return;
                    long now = System.currentTimeMillis() / 1000;
                    long lastMessageShow = SharedPreferencesManager.getPhraseWarningTime(ctx);
                    if (lastMessageShow == 0 || (!firstTime && lastMessageShow > (now - 36 * 60 * 60)))
                        return;//36 * 60 * 60//
                    if (BRWalletManager.getInstance().getBalance(ctx) > SharedPreferencesManager.getLimit(ctx)) {
//                        getInstance(ctx).animateSavePhraseFlow();
                        return;
                    }
                    SharedPreferencesManager.putPhraseWarningTime(ctx, System.currentTimeMillis() / 1000);
                    AlertDialog alert;
                    AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
                    builder.setTitle(ctx.getString(R.string.you_received_bitcoin));
                    builder.setMessage(String.format(ctx.getString(R.string.write_down_phrase),
                            ctx.getString(R.string.write_down_phrase_holder1)));
                    builder.setPositiveButton(ctx.getString(R.string.show_phrase),
                            new DialogInterface.OnClickListener() {
                                public void onClick(final DialogInterface dialog, int which) {
                                    new Thread(new Runnable() {
                                        @Override
                                        public void run() {
                                            dialog.dismiss();
//                                            BRWalletManager.getInstance().animateSavePhraseFlow();
                                        }
                                    }).start();
                                }
                            });
                    builder.setNegativeButton(ctx.getString(R.string.ok),
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            });
                    builder.setCancelable(false);
                    alert = builder.create();
                    alert.show();
                }
            });

        }

    }

    /**
     * Wallet callbacks
     */

    public static void publishCallback(final String message, int error) {
        Log.e(TAG, "publishCallback: " + message + ", err:" + error);
        final BreadActivity app = BreadActivity.app;
        if (app == null) return;
        BRAnimator.showBreadSignal(app, error == 0 ? "Send Confirmation" : "Error", error == 0 ? "Money Sent!" : message, error == 0 ? R.drawable.ic_check_mark_white : R.drawable.ic_error_outline_black_24dp, new BROnSignalCompletion() {
            @Override
            public void onComplete() {
                if (app != null)
                    app.getFragmentManager().popBackStack();
            }
        });

//        PaymentProtocolPostPaymentTask.waiting = false;
//        if (error != 0) {
//            if (!PaymentProtocolPostPaymentTask.waiting && !PaymentProtocolPostPaymentTask.sent) {
//                if (PaymentProtocolPostPaymentTask.pendingErrorMessages.get(PaymentProtocolPostPaymentTask.MESSAGE) != null) {
//                    BreadDialog.showCustomDialog(ctx, PaymentProtocolPostPaymentTask.pendingErrorMessages.get(PaymentProtocolPostPaymentTask.TITLE),
//                            PaymentProtocolPostPaymentTask.pendingErrorMessages.get(PaymentProtocolPostPaymentTask.MESSAGE), ctx.getString(R.string.ok));
//                    PaymentProtocolPostPaymentTask.pendingErrorMessages = null;
//                } else {
//                    BRToast.showCustomToast(BreadActivity.app, message,
//                            BreadActivity.screenParametersPoint.y / 2, Toast.LENGTH_LONG, R.drawable.toast_layout_black);
//                }
//            }
//        } else {
//            PaymentProtocolPostPaymentTask.sent = true;
//        }
    }

    public static void onBalanceChanged(final long balance) {
        Log.d(TAG, "onBalanceChanged:  " + balance);
        BRWalletManager.getInstance().setBalance(BreadActivity.app, balance);

    }

    public static void onTxAdded(byte[] tx, int blockHeight, long timestamp, final long amount, String hash) {
        Log.d(TAG, "onTxAdded: " + String.format("tx.length: %d, blockHeight: %d, timestamp: %d, amount: %d, hash: %s", tx.length, blockHeight, timestamp, amount, hash));

//        if (getInstance().getTxCount() <= 1) {
//            SharedPreferencesManager.putPhraseWarningTime(ctx, System.currentTimeMillis() / 1000);
//            ctx.runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//                    new Handler().postDelayed(new Runnable() {
//                        @Override
//                        public void run() {
//                            showWritePhraseDialog(ctx, true);
//                        }
//                    }, 2000);
//                }
//            });
//
//        }
        final BreadActivity ctx = app;
        if (ctx != null)
            TransactionDataSource.getInstance(ctx).putTransaction(new BRTransactionEntity(tx, blockHeight, timestamp, hash));
        else
            Log.e(TAG, "onTxAdded: ctx is null!");
    }

    private static void showSentReceivedToast(final Context ctx, final String message) {
        messageId++;
        if (ctx != null) {
            ((Activity) ctx).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    final int temp = messageId;
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            if (temp == messageId) {
                                if (BRToast.isToastShown()) {
                                    BRToast.showCustomToast(ctx, message,
                                            BreadWalletApp.DISPLAY_HEIGHT_PX / 2, Toast.LENGTH_LONG, R.drawable.toast_layout_black);
                                    AudioManager audioManager = (AudioManager) ctx.getSystemService(Context.AUDIO_SERVICE);
                                    if (audioManager.getRingerMode() == AudioManager.RINGER_MODE_NORMAL) {
                                        final MediaPlayer mp = MediaPlayer.create(ctx, R.raw.coinflip);
                                        mp.start();

                                    }
                                    messageId = 0;
                                    if (BreadActivity.appInBackground)
                                        BRNotificationManager.sendNotification(ctx, R.drawable.notification_icon, ctx.getString(R.string.app_name), message, 1);
                                }
                            }
                        }
                    }, 1000);

                }
            });

        }
    }

    public static void onTxUpdated(String hash, int blockHeight, int timeStamp) {
        Log.d(TAG, "onTxUpdated: " + String.format("hash: %s, blockHeight: %d, timestamp: %d", hash, blockHeight, timeStamp));
        BreadActivity ctx = app;
        if (ctx != null) {
            TransactionDataSource.getInstance(ctx).updateTxBlockHeight(hash, blockHeight, timeStamp);
        }
    }

    public static void onTxDeleted(String hash, int notifyUser, final int recommendRescan) {
        Log.e(TAG, "onTxDeleted: " + String.format("hash: %s, notifyUser: %d, recommendRescan: %d", hash, notifyUser, recommendRescan));
        final BreadActivity ctx = app;
        if (ctx != null) {
            TransactionDataSource.getInstance(ctx).deleteTxByHash(hash);
            if (notifyUser == 1) {
                ctx.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        AlertDialog alert;
                        AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
                        builder.setTitle(R.string.transaction_rejected);

                        builder.setMessage(recommendRescan == 1 ? ctx.getString(R.string.wallet_out_of_sync_message) : "");
                        if (recommendRescan == 1)
                            builder.setPositiveButton(R.string.rescan,
                                    new DialogInterface.OnClickListener() {
                                        public void onClick(DialogInterface dialog, int which) {
//                                            if (BRAnimator.checkTheMultipressingAvailability()) {
                                            new Thread(new Runnable() {
                                                @Override
                                                public void run() {
                                                    BRPeerManager.getInstance().rescan();
                                                }
                                            }).start();
//                                            }
                                        }
                                    });
                        builder.setNegativeButton(ctx.getString(R.string.cancel),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        dialog.dismiss();
                                    }
                                });
                        alert = builder.create();
                        alert.show();
                    }
                });

            }
        }
    }

    public boolean validatePhrase(Context ctx, String phrase) {
        String[] words = new String[0];
        List<String> list;

        String[] cleanWordList = null;
        try {
            boolean isLocal = true;
            String languageCode = ctx.getString(R.string.lang);
            list = WordsReader.getWordList(ctx, languageCode);

            String[] phraseWords = phrase.split(" ");
            if (!list.contains(phraseWords[0])) {
                isLocal = false;
            }
            if (!isLocal) {
                String lang = WordsReader.getLang(ctx, phraseWords[0]);
                if (lang != null) {
                    list = WordsReader.getWordList(ctx, lang);
                }

            }
            words = list.toArray(new String[list.size()]);
            cleanWordList = WordsReader.cleanWordList(words);
            if (cleanWordList == null) return false;
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (words.length != 2048) {
            RuntimeException ex = new IllegalArgumentException("words.length is not 2048");
            FirebaseCrash.report(ex);
            throw ex;
        }
        return validateRecoveryPhrase(cleanWordList, phrase);
    }

    public void confirmPay(final Context ctx, final PaymentRequestEntity request) {

        if (ctx == null) {
            Log.e(TAG, "confirmPay: context is null");
            return;
        }
        boolean certified = false;
        if (request.cn != null && request.cn.length() != 0) {
            certified = true;
        }
        StringBuilder allAddresses = new StringBuilder();
        for (String s : request.addresses) {
            allAddresses.append(s + ", ");
        }
        allAddresses.delete(allAddresses.length() - 2, allAddresses.length());
        String certification = "";
        if (certified) {
            certification = "certified: " + request.cn + "\n";
            allAddresses = new StringBuilder();
        }

        //DecimalFormat decimalFormat = new DecimalFormat("0.00");
        String iso = SharedPreferencesManager.getIso(ctx);

        float rate = CurrencyDataSource.getInstance(ctx).getCurrencyByIso(iso).rate;
        BRWalletManager m = getInstance();
        long feeForTx = m.feeForTransaction(request.addresses[0], request.amount);
        if (feeForTx == 0) {
            long maxAmount = m.getMaxOutputAmount();
            if (maxAmount == -1) {
                RuntimeException ex = new RuntimeException("getMaxOutputAmount is -1, meaning _wallet is NULL");
                FirebaseCrash.report(ex);
                throw ex;
            }
            if (maxAmount == 0) {
                BreadDialog.showCustomDialog(ctx, "", ctx.getString(R.string.insufficient_funds_for_fee), "Close", null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismiss();
                    }
                }, null, null, 0);

                return;
            }
            feeForTx = m.feeForTransaction(request.addresses[0], maxAmount);
            feeForTx += (getBalance(ctx) - request.amount) % 100;
        }
        final long total = request.amount + feeForTx;
        String formattedAmountBTC = BRCurrency.getFormattedCurrencyString(ctx, "BTC", BRWalletManager.getInstance().getAmount(ctx, "BTC", new BigDecimal(request.amount)));
        String formattedFeeBTC = BRCurrency.getFormattedCurrencyString(ctx, "BTC", BRWalletManager.getInstance().getAmount(ctx, "BTC", new BigDecimal(feeForTx)));
        String formattedTotalBTC = BRCurrency.getFormattedCurrencyString(ctx, "BTC", BRWalletManager.getInstance().getAmount(ctx, "BTC", new BigDecimal(total)));

        String formattedAmount = BRCurrency.getFormattedCurrencyString(ctx, iso, BRWalletManager.getInstance().getAmount(ctx, iso, new BigDecimal(request.amount)));
        String formattedFee = BRCurrency.getFormattedCurrencyString(ctx, iso, BRWalletManager.getInstance().getAmount(ctx, iso, new BigDecimal(feeForTx)));
        String formattedTotal = BRCurrency.getFormattedCurrencyString(ctx, iso, BRWalletManager.getInstance().getAmount(ctx, iso, new BigDecimal(total)));

        //formatted text
        final String message = certification + allAddresses.toString() + "\n\n"
                + "amount: " + formattedAmountBTC + " (" + formattedAmount + ")"
                + "\nnetwork fee: +" + formattedFeeBTC + " (" + formattedFee + ")"
                + "\ntotal: " + formattedTotalBTC + " (" + formattedTotal + ")";

        double minOutput;
        if (request.isAmountRequested) {
            minOutput = BRWalletManager.getInstance().getMinOutputAmountRequested();
        } else {
            minOutput = BRWalletManager.getInstance().getMinOutputAmount();
        }
        //amount can't be less than the min
        if (request.amount < minOutput) {
            final String bitcoinMinMessage = String.format(Locale.getDefault(), ctx.getString(R.string.bitcoin_payment_cant_be_less),
                    BRConstants.bitcoinLowercase + new BigDecimal(minOutput).divide(new BigDecimal("100")));


            BreadDialog.showCustomDialog(ctx, ctx.getString(R.string.payment_failed), bitcoinMinMessage, "Close", null, new BRDialogView.BROnClickListener() {
                @Override
                public void onClick(BRDialogView brDialogView) {
                    brDialogView.dismiss();
                }
            }, null, null, 0);

            return;
        }

        //successfully created the transaction, authenticate user
        AuthManager.getInstance().authPrompt(ctx, "Pin Required", message, false, new BRAuthCompletion() {
            @Override
            public void onComplete() {
                PostAuthenticationProcessor.getInstance().onPublishTxAuth(ctx, false);
            }

            @Override
            public void onCancel() {
                //nothing
            }
        });

    }

    public void handlePay(final Context context, final PaymentRequestEntity paymentRequest) {
        if (paymentRequest == null || paymentRequest.addresses == null || paymentRequest.amount <= 0) {
            Log.e(TAG, "handlePay: WRONG PARAMS");
            return;
        }

        // check if spending is allowed
        if (!SharedPreferencesManager.getAllowSpend(app)) {
            Log.e(TAG, "handlePay: spend not allowed");
            showSpendNotAllowed(app);
            return;
        }
        long minAmount = getMinOutputAmountRequested();
        //check if amount isn't smaller than the min amount
        if (paymentRequest.amount < minAmount) {
            Log.e(TAG, "pay: FAIL: bitcoin payment is less than the minimum.");
            final String bitcoinMinMessage = String.format(Locale.getDefault(), context.getString(R.string.bitcoin_payment_cant_be_less),
                    BRConstants.bitcoinLowercase + new BigDecimal(minAmount).divide(new BigDecimal(100), BRConstants.ROUNDING_MODE));
            BreadDialog.showCustomDialog(context, context.getString(R.string.could_not_make_payment), bitcoinMinMessage, "Cancel", null, new BRDialogView.BROnClickListener() {
                @Override
                public void onClick(BRDialogView brDialogView) {
                    brDialogView.dismiss();
                }
            }, null, null, 0);

            return;
        }

        final BRWalletManager m = BRWalletManager.getInstance();
        byte[] tmpTx = m.tryTransaction(paymentRequest.addresses[0], paymentRequest.amount);
        long feeForTx = m.feeForTransaction(paymentRequest.addresses[0], paymentRequest.amount);


        //try transaction failed so check why
        if (tmpTx == null && paymentRequest.amount <= getBalance(context) && paymentRequest.amount > 0) {
            final long maxOutputAmount = m.getMaxOutputAmount();
            if (maxOutputAmount == -1) {
                RuntimeException ex = new RuntimeException("getMaxOutputAmount is -1, meaning _wallet is NULL");
                FirebaseCrash.report(ex);
                throw ex;
            }
            //check if max you can send isn't smaller than the min amount
            if (maxOutputAmount < getMinOutputAmount()) {
                Log.e(TAG, "pay: FAIL: insufficient funds for fee.");

                BreadDialog.showCustomDialog(context, context.getString(R.string.insufficient_funds), context.getString(R.string.insufficient_funds_for_fee), "Cancel", null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismiss();
                    }
                }, null, null, 0);

                return;
            }

            //offer to change amount, so it would be enough for fee
            final long amountToReduce = paymentRequest.amount - maxOutputAmount;
//            final AlertDialog.Builder builder = new AlertDialog.Builder(context);
            String iso = SharedPreferencesManager.getIso(context);
//            BigDecimal rate = BigDecimal.valueOf(CurrencyDataSource.getInstance(context).getCurrencyByIso(iso).rate);

            String reduceBits = BRCurrency.getFormattedCurrencyString(context, "BTC", BRWalletManager.getInstance().getAmount(context, "BTC", new BigDecimal(amountToReduce)));
            String reduceFee = BRCurrency.getFormattedCurrencyString(context, iso, BRWalletManager.getInstance().getAmount(context, iso, new BigDecimal(amountToReduce)));
            String reduceBitsMinus = BRCurrency.getFormattedCurrencyString(context, "BTC", BRWalletManager.getInstance().getAmount(context, "BTC", new BigDecimal(amountToReduce).negate()));
            String reduceFeeMinus = BRCurrency.getFormattedCurrencyString(context, iso, BRWalletManager.getInstance().getAmount(context, iso, new BigDecimal(amountToReduce).negate()));

            BreadDialog.showCustomDialog(context, context.getString(R.string.insufficient_funds_for_fee), String.format(context.getString(R.string.reduce_payment_amount_by),
                    reduceBits, reduceFee), String.format("%s (%s)", reduceBitsMinus, reduceFeeMinus), "Cancel", new BRDialogView.BROnClickListener() {
                @Override
                public void onClick(BRDialogView brDialogView) {
                    brDialogView.dismiss();
                }
            }, new BRDialogView.BROnClickListener() {
                @Override
                public void onClick(BRDialogView brDialogView) {
                    byte[] tmpTx2 = m.tryTransaction(paymentRequest.addresses[0], paymentRequest.amount - amountToReduce);
                    if (tmpTx2 != null) {
                        PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx2);
//                        confirmPay(ctx, new PaymentRequestEntity(new String[]{addressHolder}, bigDecimalAmount.longValue() - amountToReduce, cn, tmpTx2, isAmountRequested));
                    } else {
                        Log.e(TAG, "tmpTxObject2 is null!");
                        BRToast.showCustomToast(context, context.getString(R.string.insufficient_funds),
                                BreadActivity.screenParametersPoint.y / 2, Toast.LENGTH_LONG, 0);
                    }
                }
            }, null, 0);

            return;

            //Insufficient funds, show message to user
        } else if (tmpTx == null && paymentRequest.amount >= getBalance(context) && paymentRequest.amount > 0) {
            Log.e(TAG, "pay: FAIL: offer To Change The Amount.");
            BRWalletManager.getInstance().offerToChangeTheAmount(context, context.getString(R.string.insufficient_funds));
            return;
        }

        // payment successful
        PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx);
        Log.d(TAG, "pay: feeForTx: " + feeForTx + ", amount: " + paymentRequest.amount +
                ", getBalance(): " + getBalance(context));
        if ((feeForTx != 0 && paymentRequest.amount + feeForTx < getBalance(context)) || (paymentRequest.isAmountRequested)) {
            Log.d(TAG, "pay: SUCCESS: going to confirmPay");
            confirmPay(context, paymentRequest);
        } else {
            Log.d(TAG, "pay: FAIL: insufficient funds");

            BreadDialog.showCustomDialog(context, "", context.getString(R.string.insufficient_funds), "Close", null, new BRDialogView.BROnClickListener() {
                @Override
                public void onClick(BRDialogView brDialogView) {
                    brDialogView.dismiss();
                }
            }, null, null, 0);


        }

    }

//    public void pay(final Context ctx, final String addressHolder, final BigDecimal bigDecimalAmount, final String cn, final boolean isAmountRequested) {
////        Log.e(TAG, "pay: " + String.format("addressHolder: %s, bigDecimalAmount: %s, cn: %s, isAmountRequested: %b", addressHolder, bigDecimalAmount == null ? null : bigDecimalAmount.toPlainString(), cn, isAmountRequested));
////        if (addressHolder == null || bigDecimalAmount == null) return;
////        if (addressHolder.length() < 20) return;
////        if (!SharedPreferencesManager.getAllowSpend(app)) {
////            showSpendNotAllowed(app);
////            return;
////        }
//
////        int unit = BRConstants.CURRENT_UNIT_BITS;
////        String divideBy = "100";
////        if (ctx != null)
////            unit = SharedPreferencesManager.getCurrencyUnit(ctx);
////        if (unit == BRConstants.CURRENT_UNIT_MBITS) divideBy = "100000";
////        if (unit == BRConstants.CURRENT_UNIT_BITCOINS) divideBy = "100000000";
//////        final long amountAsLong = bigDecimal.longValue();
////        if (bigDecimalAmount.longValue() < 0) return;
////        final CurrencyFetchManager cm = CurrencyFetchManager.getInstance(ctx);
////        long minAmount = getMinOutputAmountRequested();
////        if (bigDecimalAmount.longValue() < minAmount) {
////            Log.e(TAG, "pay: FAIL: bitcoin payment is less then the minimum.");
////            final AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
////            final String bitcoinMinMessage = String.format(Locale.getDefault(), ctx.getString(R.string.bitcoin_payment_cant_be_less),
////                    BRConstants.bitcoinLowercase + new BigDecimal(minAmount).divide(new BigDecimal(divideBy)));
////            builder.setMessage(bitcoinMinMessage)
////                    .setTitle(R.string.could_not_make_payment)
////                    .setCancelable(false)
////                    .setNegativeButton(ctx.getString(R.string.ok), new DialogInterface.OnClickListener() {
////                        @Override
////                        public void onClick(DialogInterface dialog, int which) {
////                            dialog.cancel();
////                        }
////                    });
////            AlertDialog alert = builder.create();
////            alert.show();
////            return;
////        }
//
////        final BRWalletManager m = BRWalletManager.getInstance();
////        byte[] tmpTx = m.tryTransaction(addressHolder, bigDecimalAmount.longValue());
////        long feeForTx = m.feeForTransaction(addressHolder, bigDecimalAmount.longValue());
//
//        if (tmpTx == null && bigDecimalAmount.longValue() <= getBalance() && bigDecimalAmount.longValue() > 0) {
////            final long maxAmountDouble = m.getMaxOutputAmount();
////            if (maxAmountDouble == -1) {
////                RuntimeException ex = new RuntimeException("getMaxOutputAmount is -1, meaning _wallet is NULL");
////                FirebaseCrash.report(ex);
////                throw ex;
////            }
////            if (maxAmountDouble < getMinOutputAmount()) {
////                Log.e(TAG, "pay: FAIL: insufficient funds for fee.");
////                final AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
////                builder.setmMessage("")
////                        .setmTitle(R.string.insufficient_funds_for_fee)
////                        .setCancelable(false)
////                        .setNegativeButton(ctx.getString(R.string.ok), new DialogInterface.OnClickListener() {
////                            @Override
////                            public void onClick(DialogInterface dialog, int which) {
////                                dialog.cancel();
////                            }
////                        });
////                AlertDialog alert = builder.create();
////                alert.show();
////
////                return;
////            }
////
////            final long amountToReduce = bigDecimalAmount.longValue() - maxAmountDouble;
////            final AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
////            String reduceBits = BRCurrency.getFormattedCurrencyString(ctx, "BTC", amountToReduce);
////            String reduceFee = BRCurrency.getExchangeForAmount(SharedPreferencesManager.getRate(ctx), SharedPreferencesManager.getIso(ctx), new BigDecimal(amountToReduce), ctx);
////            String reduceBitsMinus = BRCurrency.getFormattedCurrencyString(ctx, "BTC", -amountToReduce);
////            String reduceFeeMinus = BRCurrency.getExchangeForAmount(SharedPreferencesManager.getRate(ctx), SharedPreferencesManager.getIso(ctx), new BigDecimal(-amountToReduce), ctx);
////
////            builder.setmMessage(String.format(ctx.getString(R.string.reduce_payment_amount_by), reduceBits, reduceFee))
////                    .setmTitle(R.string.insufficient_funds_for_fee)
////                    .setCancelable(false)
////                    .setNegativeButton(ctx.getString(R.string.cancel), new DialogInterface.OnClickListener() {
////                        @Override
////                        public void onClick(DialogInterface dialog, int which) {
////                            dialog.cancel();
////                        }
////                    })
////                    .setPositiveButton(String.format("%s (%s)", reduceBitsMinus, reduceFeeMinus), new DialogInterface.OnClickListener() {
////                        public void onClick(DialogInterface dialog, int id) {
////                            byte[] tmpTx2 = m.tryTransaction(addressHolder, bigDecimalAmount.longValue() - amountToReduce);
////                            if (tmpTx2 != null) {
//////                                PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx2);
////                                confirmPay(ctx, new PaymentRequestEntity(new String[]{addressHolder}, bigDecimalAmount.longValue() - amountToReduce, cn, tmpTx2, isAmountRequested));
////                            } else {
////                                Log.e(TAG, "tmpTxObject2 is null!");
////                                ((BreadWalletApp) ((Activity) ctx).getApplication()).showCustomToast(ctx, ctx.getString(R.string.insufficient_funds),
////                                        BreadActivity.screenParametersPoint.y / 2, Toast.LENGTH_LONG, 0);
////                            }
////                        }
////                    });
////            AlertDialog alert = builder.create();
////            alert.show();
////            alert.getButton(AlertDialog.BUTTON_POSITIVE).setAllCaps(false);
////            return;
//        } else if (tmpTx == null && bigDecimalAmount.longValue() >= getBalance() && bigDecimalAmount.longValue() > 0) {
////
//////            FragmentScanResult.address = addressHolder;
////            if (!BreadWalletApp.unlocked) {
////                Log.e(TAG, "pay: FAIL: insufficient funds, but let the user auth first then tell");
////                //let it fail but the after the auth let the user know there is not enough money
////                confirmPay(ctx, new PaymentRequestEntity(new String[]{addressHolder}, bigDecimalAmount.longValue(), cn, null, isAmountRequested));
////                return;
////            } else {
////                Log.e(TAG, "pay: FAIL: offer To Change The Amount.");
////                BRWalletManager.getInstance().offerToChangeTheAmount(ctx, ctx.getString(R.string.insufficient_funds));
////                return;
////            }
//
//        }
//        PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx);
//        Log.d(TAG, "pay: feeForTx: " + feeForTx + ", amountAsDouble: " + bigDecimalAmount.longValue() +
//                ", CurrencyFetchManager.getInstance(this).getBalance(): " + getBalance());
//        if ((feeForTx != 0 && bigDecimalAmount.longValue() + feeForTx < getBalance()) || (isAmountRequested && !BreadWalletApp.unlocked)) {
//            Log.d(TAG, "pay: SUCCESS: going to confirmPay");
//            confirmPay(ctx, new PaymentRequestEntity(new String[]{addressHolder}, bigDecimalAmount.longValue(), cn, tmpTx, isAmountRequested));
//        } else {
//            Log.d(TAG, "pay: FAIL: insufficient funds");
//            AlertDialog.Builder builder = new AlertDialog.Builder(ctx);
//            builder.setmMessage(ctx.getString(R.string.insufficient_funds))
//                    .setCancelable(false)
//                    .setPositiveButton("ok", new DialogInterface.OnClickListener() {
//                        public void onClick(DialogInterface dialog, int id) {
//                            dialog.cancel();
//                        }
//                    });
//            AlertDialog alert = builder.create();
//            alert.show();
//        }
//
//    }

//    public void askForPasscode(Context ctx) {
//        if (ctx == null) return;
//        final String pass = KeyStoreManager.getPinCode(ctx);
//        if (pass == null || pass.length() != 4) {
//            ((BreadWalletApp) ((Activity) ctx).getApplication()).authPrompt(ctx, BRConstants.AUTH_FOR_GENERAL, null, null, null, null, true);
//        }
//
//    }

    public void setUpTheWallet(final Context ctx) {
        Log.d(TAG, "setUpTheWallet...");
        Assert.assertNotNull(ctx);
        if (ctx == null) return;
        BRWalletManager m = BRWalletManager.getInstance();
        final BRPeerManager pm = BRPeerManager.getInstance();

        if (!m.isCreated()) {
            List<BRTransactionEntity> transactions = TransactionDataSource.getInstance(ctx).getAllTransactions();
            int transactionsCount = transactions.size();
            if (transactionsCount > 0) {
                m.createTxArrayWithCount(transactionsCount);
                for (BRTransactionEntity entity : transactions) {
                    m.putTransaction(entity.getBuff(), entity.getBlockheight(), entity.getTimestamp());
                }
            }

            byte[] pubkeyEncoded = KeyStoreManager.getMasterPublicKey(ctx);

            //Save the first address for future check
            m.createWallet(transactionsCount, pubkeyEncoded);
            String firstAddress = BRWalletManager.getFirstAddress(pubkeyEncoded);
            SharedPreferencesManager.putFirstAddress(ctx, firstAddress);
            long fee = SharedPreferencesManager.getFeePerKb(ctx);
            if (fee == 0) fee = BRConstants.DEFAULT_FEE_PER_KB;
            BRWalletManager.getInstance().setFeePerKb(fee);
        }

        if (!pm.isCreated()) {
            List<BRMerkleBlockEntity> blocks = MerkleBlockDataSource.getInstance(ctx).getAllMerkleBlocks();
            List<BRPeerEntity> peers = PeerDataSource.getInstance(ctx).getAllPeers();
            final int blocksCount = blocks.size();
            final int peersCount = peers.size();
            if (blocksCount > 0) {
                pm.createBlockArrayWithCount(blocksCount);
                for (BRMerkleBlockEntity entity : blocks) {
                    pm.putBlock(entity.getBuff(), entity.getBlockHeight());
                }
            }
            if (peersCount > 0) {
                pm.createPeerArrayWithCount(peersCount);
                for (BRPeerEntity entity : peers) {
                    pm.putPeer(entity.getAddress(), entity.getPort(), entity.getTimeStamp());
                }
            }
            Log.d(TAG, "blocksCount before connecting: " + blocksCount);
            Log.d(TAG, "peersCount before connecting: " + peersCount);

            int walletTimeString = KeyStoreManager.getWalletCreationTime(ctx);
            Log.e(TAG, "setUpTheWallet: walletTimeString: " + walletTimeString);
            pm.create(walletTimeString, blocksCount, peersCount);

        }
        pm.connect();
        if (SharedPreferencesManager.getStartHeight(ctx) == 0)
            new Thread(new Runnable() {
                @Override
                public void run() {
                    SharedPreferencesManager.putStartHeight(ctx, BRPeerManager.getCurrentBlockHeight());
                }
            }).start();
    }

    public boolean generateQR(Context ctx, String bitcoinURL, ImageView qrcode) {
        if (qrcode == null || bitcoinURL == null || bitcoinURL.isEmpty()) return false;
        WindowManager manager = (WindowManager) ctx.getSystemService(Activity.WINDOW_SERVICE);
        Display display = manager.getDefaultDisplay();
        Point point = new Point();
        display.getSize(point);
        int width = point.x;
        int height = point.y;
        int smallerDimension = width < height ? width : height;
        smallerDimension = (int) (smallerDimension * 0.5f);
        Bitmap bitmap = null;
        try {
            bitmap = QRUtils.encodeAsBitmap(bitcoinURL, smallerDimension);
        } catch (WriterException e) {
            e.printStackTrace();
            return false;
        }
//        qrcode.setPadding(1, 1, 1, 1);
//        qrcode.setBackgroundResource(R.color.gray);
        qrcode.setImageBitmap(bitmap);
        return true;

    }

    //returns BTC, mBTC or bits, depending on the user preference
    public BigDecimal getBitcoin(double rate, long amount) {
        return BRBitcoin.getBitcoinAmount(new BigDecimal(bitcoinAmount(amount, rate)));
    }

    //return the exchange for the specified rate
    public BigDecimal getExchange(double rate, long amount) {
        return new BigDecimal(localAmount(new BigDecimal(amount).longValue(), rate));
    }

    //figures out the current amount by the specified iso, amount is satoshis
    public BigDecimal getAmount(Context app, String iso, BigDecimal amount) {
        BigDecimal result;
        if (iso.equalsIgnoreCase("BTC")) {
            result = BRBitcoin.getBitcoinAmount(amount);
        } else {
            //multiply by 100 because core function localAmount accepts the smallest amount e.g. cents
            CurrencyEntity ent = CurrencyDataSource.getInstance(app).getCurrencyByIso(iso);
            if (ent == null) return new BigDecimal(0);
            BigDecimal rate = new BigDecimal(ent.rate).multiply(new BigDecimal(100));
            result = getExchange(rate.doubleValue(), amount.longValue()).divide(new BigDecimal(100), 2, BRConstants.ROUNDING_MODE);
        }
        return result;
    }

    public void offerToChangeTheAmount(Context app, String title) {
//
//        new AlertDialog.Builder(app)
//                .setmTitle(title)
//                .setmMessage(R.string.change_payment_amount)
//                .setPositiveButton(R.string.change, new DialogInterface.OnClickListener() {
//                    public void onClick(DialogInterface dialog, int which) {
//
//                        BRAnimator.animateScanResultFragment();
//                    }
//                }).setNegativeButton(app.getString(R.string.cancel), new DialogInterface.OnClickListener() {
//            @Override
//            public void onClick(DialogInterface dialog, int which) {
//                dialog.dismiss();
//            }
//        })
//                .setIcon(android.R.drawable.ic_dialog_alert)
//                .show();
    }

//    public void animateSavePhraseFlow() {
//        PhraseFlowActivity.screenParametersPoint = IntroActivity.screenParametersPoint;
//        if (PhraseFlowActivity.screenParametersPoint == null ||
//                PhraseFlowActivity.screenParametersPoint.y == 0 ||
//                PhraseFlowActivity.screenParametersPoint.x == 0)
//            PhraseFlowActivity.screenParametersPoint = MainActivity.screenParametersPoint;
//        Intent intent;
//        intent = new Intent(ctx, PhraseFlowActivity.class);
//        ctx.startActivity(intent);
//        if (!ctx.isDestroyed()) {
//            ctx.finish();
//        }
//    }

    private static void showSpendNotAllowed(final Context app) {
//        Log.d(TAG, "showSpendNotAllowed");
//        ((Activity) ctx).runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                AlertDialog.Builder builder = new AlertDialog.Builder(app);
//                builder.setmTitle(R.string.syncing_in_progress)
//                        .setmMessage(R.string.wait_for_sync_to_finish)
//                        .setNegativeButton(app.getString(R.string.ok), new DialogInterface.OnClickListener() {
//                            @Override
//                            public void onClick(DialogInterface dialog, int which) {
//                                dialog.cancel();
//                            }
//                        });
//                AlertDialog alert = builder.create();
//                alert.show();
//            }
//        });
    }


    public void startBreadActivity(Activity from, boolean auth) {
        Log.e(TAG, "startBreadActivity: from: " + from);
        Intent intent;
        if (auth) {
            intent = new Intent(from, PinActivity.class);
            from.startActivity(intent);
            if (!from.isDestroyed()) {
                from.finish();
            }
        } else {
            intent = new Intent(from, BreadActivity.class);
            from.startActivity(intent);
            if (!from.isDestroyed()) {
                from.finish();
            }
        }
    }

    public void addBalanceChangedListener(OnBalanceChanged listener) {
        if (balanceListeners == null) {
            Log.e(TAG, "addBalanceChangedListener: statusUpdateListeners is null");
            return;
        }
        if (!balanceListeners.contains(listener))
            balanceListeners.add(listener);
    }

    public void removeListener(OnBalanceChanged listener) {
        if (balanceListeners == null) {
            Log.e(TAG, "addBalanceChangedListener: statusUpdateListeners is null");
            return;
        }
        balanceListeners.remove(listener);

    }

    public interface OnBalanceChanged {
        void onBalanceChanged(long balance);
    }

    private native byte[] encodeSeed(byte[] seed, String[] wordList);

    public native void createWallet(int transactionCount, byte[] pubkey);

    public native void putTransaction(byte[] transaction, long blockHeight, long timeStamp);

    public native void createTxArrayWithCount(int count);

    public native byte[] getMasterPubKey(byte[] normalizedString);

    public static native String getReceiveAddress();

    public native TransactionListItem[] getTransactions();

    public static native boolean validateAddress(String address);

    public native boolean addressContainedInWallet(String address);

    public native boolean addressIsUsed(String address);

    public native int feeForTransaction(String addressHolder, long amountHolder);

    public native long getMinOutputAmount();

    public native long getMaxOutputAmount();

    public native boolean isCreated();

    public native boolean transactionIsVerified(String txHash);

    public native byte[] tryTransaction(String addressHolder, long amountHolder);

    // returns the given amount (in satoshis) in local currency units (i.e. pennies, pence)
    // price is local currency units per bitcoin
    public native long localAmount(long amount, double price);

    // returns the given local currency amount in satoshis
    // price is local currency units (i.e. pennies, pence) per bitcoin
    public native long bitcoinAmount(long localAmount, double price);

    public native void walletFreeEverything();

    private native boolean validateRecoveryPhrase(String[] words, String phrase);

    public native static String getFirstAddress(byte[] mpk);

    public native boolean publishSerializedTransaction(byte[] serializedTransaction, byte[] phrase);

    public native long getTotalSent();

    public native long setFeePerKb(long fee);

    public native boolean isValidBitcoinPrivateKey(String key);

    public native boolean isValidBitcoinBIP38Key(String key);

    public native String getAddressFromPrivKey(String key);

    public native void createInputArray();

    public native void addInputToPrivKeyTx(byte[] hash, int vout, byte[] script, long amount);

    public native boolean confirmKeySweep(byte[] tx, String key);

    public native ImportPrivKeyEntity getPrivKeyObject();

    public native String decryptBip38Key(String privKey, String pass);

    public native String reverseTxHash(String txHash);

    public native int getTxCount();

    public native long getMinOutputAmountRequested();

    public static native byte[] getAuthPrivKeyForAPI(byte[] seed);

    public static native String getAuthPublicKeyForAPI(byte[] privKey);

    public static native byte[] getSeedFromPhrase(byte[] phrase);

    public static native boolean isTestNet();

}