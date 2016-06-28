package com.breadwallet.presenter.fragments;

import android.Manifest;
import android.app.Activity;
import android.app.Fragment;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.hardware.fingerprint.FingerprintManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.breadwallet.R;
import com.breadwallet.presenter.BreadWalletApp;
import com.breadwallet.presenter.activities.MainActivity;
import com.breadwallet.tools.BRConstants;
import com.breadwallet.tools.BRStringFormatter;
import com.breadwallet.tools.CurrencyManager;
import com.breadwallet.tools.SharedPreferencesManager;
import com.breadwallet.tools.adapter.CurrencyListAdapter;
import com.breadwallet.tools.adapter.MiddleViewAdapter;
import com.breadwallet.tools.animation.FragmentAnimator;
import com.breadwallet.tools.security.PassCodeManager;
import com.breadwallet.wallet.BRPeerManager;

import org.w3c.dom.Text;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on 6/29/15.
 * Copyright (c) 2016 breadwallet llc <mihail@breadwallet.com>
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

public class FragmentSettings extends Fragment {
    private static final String TAG = FragmentSettings.class.getName();
    private MainActivity app;
    private FragmentSettings fragmentSettings;

    @Override
    public View onCreateView(LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        // The last two arguments ensure LayoutParams are inflated
        // properly.

        View rootView = inflater.inflate(
                R.layout.fragment_settings, container, false);

        app = MainActivity.app;
        fragmentSettings = this;
//        FragmentCurrency fragmentCurrency = (FragmentCurrency) getActivity().getFragmentManager().
//                findFragmentByTag(FragmentCurrency.class.getName());
        initList();
        RelativeLayout about = (RelativeLayout) rootView.findViewById(R.id.about);
        TextView currencyName = (TextView) rootView.findViewById(R.id.three_letters_currency);
        RelativeLayout changePassword = (RelativeLayout) rootView.findViewById(R.id.change_password);
        final String tmp = SharedPreferencesManager.getIso(getActivity());
//        Log.e(TAG, "Tmp 3 letters: " + tmp);
        currencyName.setText(tmp);
        RelativeLayout localCurrency = (RelativeLayout) rootView.findViewById(R.id.local_currency);
        RelativeLayout recoveryPhrase = (RelativeLayout) rootView.findViewById(R.id.recovery_phrase);
        RelativeLayout startRecoveryWallet = (RelativeLayout) rootView.findViewById(R.id.start_recovery_wallet);
        RelativeLayout fingerprintLimit = (RelativeLayout) rootView.findViewById(R.id.fingerprint_limit);
        RelativeLayout line5 = (RelativeLayout) rootView.findViewById(R.id.settings_line_5);
        TextView theLimit = (TextView) rootView.findViewById(R.id.fingerprint_limit_text);
        RelativeLayout rescan = (RelativeLayout) rootView.findViewById(R.id.rescan_blockchain);


        theLimit.setText(BRStringFormatter.getFormattedCurrencyString("BTC", PassCodeManager.getInstance().getLimit(getActivity())));
        FingerprintManager mFingerprintManager;
        mFingerprintManager = (FingerprintManager) getActivity().getSystemService(Context.FINGERPRINT_SERVICE);
        boolean useFingerPrint;
        useFingerPrint = ActivityCompat.checkSelfPermission(getActivity(), Manifest.permission.USE_FINGERPRINT) == PackageManager.PERMISSION_GRANTED && mFingerprintManager.isHardwareDetected() && mFingerprintManager.hasEnrolledFingerprints();

        if (!useFingerPrint) {
            fingerprintLimit.setVisibility(View.GONE);
            line5.setVisibility(View.GONE);
        }

        fingerprintLimit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (FragmentAnimator.checkTheMultipressingAvailability()) {
                    ((BreadWalletApp) getActivity().getApplicationContext()).promptForAuthentication(getActivity(), BRConstants.AUTH_FOR_LIMIT, null, null, null, null);
                }
            }
        });

        startRecoveryWallet.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (FragmentAnimator.checkTheMultipressingAvailability()) {
                    FragmentAnimator.pressWipeWallet(app, new FragmentWipeWallet());
                    app.activityButtonsEnable(false);
                }
            }
        });
        recoveryPhrase.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (FragmentAnimator.checkTheMultipressingAvailability()) {

                    new AlertDialog.Builder(getActivity())
                            .setTitle(getResources().getString(R.string.warning))
                            .setMessage(getResources().getString(R.string.dialog_do_not_let_anyone))
                            .setPositiveButton(getResources().getString(R.string.show), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    ((BreadWalletApp) getActivity().getApplicationContext()).promptForAuthentication(getActivity(), BRConstants.AUTH_FOR_PHRASE, null, null, null, null);
                                }
                            })
                            .setNegativeButton(getResources().getString(R.string.cancel), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
//                                    Log.d(TAG, "Canceled the view of the phrase!");
                                }
                            })
                            .show();
                }
            }
        });
        about.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (FragmentAnimator.checkTheMultipressingAvailability()) {
                    FragmentAnimator.animateSlideToLeft(app, new FragmentAbout(), fragmentSettings);
                }
            }
        });
        localCurrency.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (FragmentAnimator.checkTheMultipressingAvailability()) {
                    FragmentAnimator.animateSlideToLeft(app, new FragmentCurrency(), fragmentSettings);
                }
            }
        });
        changePassword.setOnClickListener(new View.OnClickListener() {
                                              @Override
                                              public void onClick(View v) {
                                                  if (FragmentAnimator.checkTheMultipressingAvailability()) {
                                                      final android.app.FragmentManager fm = getActivity().getFragmentManager();
                                                      new PasswordDialogFragment().show(fm, PasswordDialogFragment.class.getName());
                                                  }
                                              }
                                          }

        );

        rescan.setOnClickListener(new View.OnClickListener() {
                                      @Override
                                      public void onClick(View v) {
                                          if (FragmentAnimator.checkTheMultipressingAvailability()) {
                                              new Thread(new Runnable() {
                                                  @Override
                                                  public void run() {
                                                      FragmentAnimator.goToMainActivity(fragmentSettings);
                                                      BRPeerManager.getInstance(getActivity()).rescan();
                                                  }
                                              }).start();
                                          }
                                      }
                                  }

        );

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
//        Log.e(TAG, "In onResume");
        MiddleViewAdapter.resetMiddleView(getActivity(), null);
    }

    @Override
    public void onPause() {
        super.onPause();
//        Log.e(TAG, "In onPause");
    }

    private void initList() {
        CurrencyListAdapter.currencyListAdapter = CurrencyManager.getInstance(getActivity()).getCurrencyAdapterIfReady();
    }

}