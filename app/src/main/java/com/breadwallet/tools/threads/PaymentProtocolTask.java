package com.breadwallet.tools.threads;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.util.Log;

import com.breadwallet.BreadWalletApp;
import com.breadwallet.R;
import com.breadwallet.presenter.activities.BreadActivity;
import com.breadwallet.presenter.activities.PinActivity;
import com.breadwallet.presenter.customviews.BRDialogView;
import com.breadwallet.presenter.entities.PaymentRequestEntity;
import com.breadwallet.presenter.entities.PaymentRequestWrapper;
import com.breadwallet.exceptions.CertificateChainNotFound;
import com.breadwallet.presenter.interfaces.BRAuthCompletion;
import com.breadwallet.tools.animation.BreadDialog;
import com.breadwallet.tools.manager.CurrencyFetchManager;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.security.AuthManager;
import com.breadwallet.tools.security.BitcoinUrlHandler;
import com.breadwallet.tools.security.PostAuthenticationProcessor;
import com.breadwallet.tools.sqlite.CurrencyDataSource;
import com.breadwallet.tools.util.BRConstants;
import com.breadwallet.tools.util.BRCurrency;
import com.breadwallet.tools.util.BRExchange;
import com.breadwallet.tools.util.ByteReader;
import com.breadwallet.tools.security.X509CertificateValidator;
import com.breadwallet.tools.util.CustomLogger;
import com.breadwallet.wallet.BRWalletManager;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.util.List;
import java.util.Locale;


/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan <mihail@breadwallet.com> on 5/9/16.
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

public class PaymentProtocolTask extends AsyncTask<String, String, String> {
    public static final String TAG = PaymentProtocolTask.class.getName();
    HttpURLConnection urlConnection;
    String certName = null;
    PaymentRequestWrapper paymentRequest = null;
    int certified = 0;
    Activity app;

    //params[0] = uri, params[1] = label
    @Override
    protected String doInBackground(String... params) {
        app = BreadWalletApp.getBreadContext();
        InputStream in;
        try {
            Log.e(TAG, "the uri: " + params[0]);
            URL url = new URL(params[0]);
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestProperty("Accept", "application/bitcoin-paymentrequest");
            urlConnection.setConnectTimeout(3000);
            urlConnection.setReadTimeout(3000);
            urlConnection.setUseCaches(false);
            in = urlConnection.getInputStream();

            if (in == null) {
                Log.e(TAG, "The inputStream is null!");
                return null;
            }
            byte[] serializedBytes = ByteReader.readBytesFromStream(in);
            if (serializedBytes == null || serializedBytes.length == 0) {
                Log.e(TAG, "serializedBytes are null!!!");
                return null;
            }

            paymentRequest = BitcoinUrlHandler.parsePaymentRequest(serializedBytes);

            if (paymentRequest == null || paymentRequest.error == PaymentRequestWrapper.INVALID_REQUEST_ERROR) {
                Log.e(TAG, "paymentRequest is null!!!");
                BreadDialog.showCustomDialog(app, "", app.getString(R.string.invalid_request), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismissWithAnimation();
                    }
                }, null, null, 0);
                paymentRequest = null;
                return null;
            } else if (paymentRequest.error == PaymentRequestWrapper.INSUFFICIENT_FUNDS_ERROR) {
                Log.e(TAG, "insufficient amount!!!");
                BreadDialog.showCustomDialog(app, "", app.getString(R.string.insufficient_funds), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismissWithAnimation();
                    }
                }, null, null, 0);
                paymentRequest = null;
                return null;
            } else if (paymentRequest.error == PaymentRequestWrapper.SIGNING_FAILED_ERROR) {
                Log.e(TAG, "failed to sign tx!!!");
                Log.e(TAG, "insufficient amount!!!");
                BreadDialog.showCustomDialog(app, "", app.getString(R.string.failed_to_sign_tx), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismissWithAnimation();
                    }
                }, null, null, 0);
                paymentRequest = null;
                return null;
            } else if (paymentRequest.error == PaymentRequestWrapper.REQUEST_TOO_LONG_ERROR) {
                Log.e(TAG, "failed to sign tx!!!");
                BreadDialog.showCustomDialog(app, "", app.getString(R.string.payment_request_message_too_large), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismissWithAnimation();
                    }
                }, null, null, 0);
                paymentRequest = null;
                return null;
            } else if (paymentRequest.error == PaymentRequestWrapper.AMOUNTS_ERROR) {
                Log.e(TAG, "failed to sign tx!!!");
                BreadDialog.showCustomDialog(app, "", app.getString(R.string.could_not_transmit_payment), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                    @Override
                    public void onClick(BRDialogView brDialogView) {
                        brDialogView.dismissWithAnimation();
                    }
                }, null, null, 0);
                paymentRequest = null;
                return null;
            }

            //Logging
            StringBuilder allAddresses = new StringBuilder();
            for (String s : paymentRequest.addresses) {
                allAddresses.append(s).append(", ");
                if (!BRWalletManager.validateAddress(s)) {
                    if (app != null)
                        BreadDialog.showCustomDialog(app, app.getString(R.string.error), String.format(app.getString(R.string.invalid_address_with_holder), s), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                            @Override
                            public void onClick(BRDialogView brDialogView) {
                                brDialogView.dismissWithAnimation();
                            }
                        }, null, null, 0);
                    paymentRequest = null;
                    return null;
                }
            }
            allAddresses.delete(allAddresses.length() - 2, allAddresses.length());

            CustomLogger.logThis("Signature", String.valueOf(paymentRequest.signature.length),
                    "pkiType", paymentRequest.pkiType, "pkiData", String.valueOf(paymentRequest.pkiData.length));
            CustomLogger.logThis("network", paymentRequest.network, "time", String.valueOf(paymentRequest.time),
                    "expires", String.valueOf(paymentRequest.expires), "memo", paymentRequest.memo,
                    "paymentURL", paymentRequest.paymentURL, "merchantDataSize",
                    String.valueOf(paymentRequest.merchantData.length), "address", allAddresses.toString(),
                    "amount", String.valueOf(paymentRequest.amount));
            //end logging
            if (paymentRequest.expires != 0 && paymentRequest.time > paymentRequest.expires) {
                Log.e(TAG, "Request is expired");
                if (app != null)
                    BreadDialog.showCustomDialog(app, app.getString(R.string.error), app.getString(R.string.expired_request), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                        @Override
                        public void onClick(BRDialogView brDialogView) {
                            brDialogView.dismissWithAnimation();
                        }
                    }, null, null, 0);
                paymentRequest = null;
                return null;
            }
            List<X509Certificate> certList = X509CertificateValidator.getCertificateFromBytes(serializedBytes);
            certName = X509CertificateValidator.certificateValidation(certList, paymentRequest);

        } catch (Exception e) {
            if (e instanceof java.net.UnknownHostException) {
                if (app != null)
                    BreadDialog.showCustomDialog(app, app.getString(R.string.error), app.getString(R.string.unknown_host), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                        @Override
                        public void onClick(BRDialogView brDialogView) {
                            brDialogView.dismissWithAnimation();
                        }
                    }, null, null, 0);
                paymentRequest = null;
            } else if (e instanceof FileNotFoundException) {
                if (app != null)
                    BreadDialog.showCustomDialog(app, app.getString(R.string.error), app.getString(R.string.bad_payment_request), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                        @Override
                        public void onClick(BRDialogView brDialogView) {
                            brDialogView.dismissWithAnimation();
                        }
                    }, null, null, 0);
                paymentRequest = null;
            } else if (e instanceof SocketTimeoutException) {
                if (app != null)
                    BreadDialog.showCustomDialog(app, app.getString(R.string.error), app.getString(R.string.connection_timed_out), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                        @Override
                        public void onClick(BRDialogView brDialogView) {
                            brDialogView.dismissWithAnimation();
                        }
                    }, null, null, 0);
                paymentRequest = null;
            } else if (e instanceof CertificateChainNotFound) {
                Log.e(TAG, "No certificates!", e);
            } else {
                if (app != null)
                    BreadDialog.showCustomDialog(app, app.getString(R.string.warning), app.getString(R.string.could_not_transmit_payment), app.getString(R.string.ok), null, new BRDialogView.BROnClickListener() {
                        @Override
                        public void onClick(BRDialogView brDialogView) {
                            brDialogView.dismissWithAnimation();
                        }
                    }, null, null, 0);

                paymentRequest = null;
            }
            e.printStackTrace();
        } finally {
            if (urlConnection != null) urlConnection.disconnect();
        }
        if (paymentRequest == null) return null;
        if (!paymentRequest.pkiType.equals("none") && certName == null) {
            certified = 2;
        } else if (!paymentRequest.pkiType.equals("none") && certName != null) {
            certified = 1;
        }
        certName = extractCNFromCertName(certName);
        if (certName == null || certName.isEmpty())
            certName = params[1];
        if (certName == null || certName.isEmpty())
            certName = paymentRequest.addresses[0];
        return null;
    }

    @Override
    protected void onPostExecute(String result) {
        super.onPostExecute(result);

        if (app == null) return;
        if (paymentRequest == null || paymentRequest.addresses == null ||
                paymentRequest.addresses.length == 0 || paymentRequest.amount == 0) {
            return;
        }
        final String certification;
        if (certified == 0) {
            certification = certName + "\n";
        } else {
            if (certName == null || certName.isEmpty()) {
                certification = "\u274C " + certName + "\n";
                new AlertDialog.Builder(app)
                        .setTitle("")
                        .setMessage(R.string.payee_not_certified)
                        .setNegativeButton(app.getString(R.string.ignore), new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                continueWithThePayment(app, certification);
                            }
                        }).setPositiveButton(app.getString(R.string.cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .show();
                return;
            } else {
                certification = "\uD83D\uDD12 " + certName + "\n";
            }

        }

        continueWithThePayment(app, certification);

    }

    private String extractCNFromCertName(String str) {
        if (str == null || str.length() < 4) return null;
        String cn = "CN=";
        int index = -1;
        int endIndex = -1;
        for (int i = 0; i < str.length() - 3; i++) {
            if (str.substring(i, i + 3).equalsIgnoreCase(cn)) {
                index = i + 3;
            }
            if (index != -1) {
                if (str.charAt(i) == ',') {
                    endIndex = i;
                    break;
                }

            }
        }
        String cleanCN = str.substring(index, endIndex);
//            Log.e(TAG, "cleanCN: " + cleanCN);
        return (index != -1 && endIndex != -1) ? cleanCN : null;
    }

    private void continueWithThePayment(final Activity app, String certification) {

        StringBuilder allAddresses = new StringBuilder();
        for (String s : paymentRequest.addresses) {
            allAddresses.append(s + ", ");
        }
        allAddresses.delete(allAddresses.length() - 2, allAddresses.length());
        String memo = (!paymentRequest.memo.isEmpty() ? "\n" : "") + paymentRequest.memo;
        allAddresses = new StringBuilder();

        //DecimalFormat decimalFormat = new DecimalFormat("0.00");
        String iso = SharedPreferencesManager.getIso(app);
        float rate = CurrencyDataSource.getInstance(app).getCurrencyByIso(iso).rate;
        CurrencyFetchManager cm = CurrencyFetchManager.getInstance(app);

        double minOutput = BRWalletManager.getInstance().getMinOutputAmount();
        if (paymentRequest.amount < minOutput) {
            final String bitcoinMinMessage = String.format(Locale.getDefault(), app.getString(R.string.bitcoin_payment_cant_be_less),
                    BRConstants.bitcoinLowercase + new BigDecimal(minOutput).divide(new BigDecimal("100")));
            app.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    new android.app.AlertDialog.Builder(app)
                            .setTitle(app.getString(R.string.payment_failed))
                            .setMessage(bitcoinMinMessage)
                            .setPositiveButton(app.getString(R.string.ok), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            })
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .show();
                }
            });

            return;
        }
        final long total = paymentRequest.amount + paymentRequest.fee;

        final PaymentRequestEntity request = new PaymentRequestEntity(paymentRequest.addresses, paymentRequest.amount, certName, false);

        BigDecimal bigAm = BRExchange.getAmountFromSatoshis(app, iso, new BigDecimal(paymentRequest.amount));
        BigDecimal bigFee = BRExchange.getAmountFromSatoshis(app, iso, new BigDecimal(paymentRequest.fee));
        BigDecimal bigTotal = BRExchange.getAmountFromSatoshis(app, iso, new BigDecimal(paymentRequest.fee));
        final String message = certification + memo + allAddresses.toString() + "\n\n" + "amount: " + BRCurrency.getFormattedCurrencyString(app, iso, bigAm)
                + "\nnetwork fee: +" + BRCurrency.getFormattedCurrencyString(app, iso, bigFee)
                + "\ntotal: " + BRCurrency.getFormattedCurrencyString(app, "BTC", bigTotal);

        app.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AuthManager.getInstance().authPrompt(app, "Confirmation", message, false, new BRAuthCompletion() {
                    @Override
                    public void onComplete() {
                        PostAuthenticationProcessor.getInstance().setTmpPaymentRequest(paymentRequest);
                        PostAuthenticationProcessor.getInstance().onPaymentProtocolRequest(app, false);
                    }

                    @Override
                    public void onCancel() {
                        Log.e(TAG, "onCancel: ");
                    }
                });
            }
        });
    }

}
