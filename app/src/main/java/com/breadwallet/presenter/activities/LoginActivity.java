package com.breadwallet.presenter.activities;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateInterpolator;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.breadwallet.BreadApp;
import com.breadwallet.R;
import com.breadwallet.presenter.activities.camera.ScanQRActivity;
import com.breadwallet.presenter.activities.util.BRActivity;
import com.breadwallet.presenter.customviews.BRDialogView;
import com.breadwallet.presenter.customviews.BRKeyboard;
import com.breadwallet.presenter.interfaces.BRAuthCompletion;
import com.breadwallet.tools.animation.BRAnimator;
import com.breadwallet.tools.animation.BRDialog;
import com.breadwallet.tools.animation.SpringAnimator;
import com.breadwallet.tools.manager.BRSharedPrefs;
import com.breadwallet.tools.security.AuthManager;
import com.breadwallet.tools.security.BRKeyStore;
import com.breadwallet.tools.threads.executor.BRExecutor;
import com.breadwallet.tools.util.BRConstants;
import com.breadwallet.tools.util.Utils;
import com.breadwallet.wallet.WalletsMaster;
import com.breadwallet.wallet.abstracts.BaseWalletManager;
import com.platform.APIClient;


import java.util.ArrayList;
import java.util.List;

import static com.breadwallet.R.color.white;
import static com.breadwallet.tools.util.BRConstants.SCANNER_REQUEST;

public class LoginActivity extends BRActivity implements BreadApp.OnAppBackgrounded {
    private static final String TAG = LoginActivity.class.getName();
    private BRKeyboard keyboard;
    private LinearLayout pinLayout;
    private View dot1;
    private View dot2;
    private View dot3;
    private View dot4;
    private View dot5;
    private View dot6;
    private StringBuilder pin = new StringBuilder();
    private int pinLimit = 6;
    private static LoginActivity app;

    private ImageView unlockedImage;
    private TextView unlockedText;
    private TextView enterPinLabel;
    private LinearLayout offlineButtonsLayout;

    private ImageButton fingerPrint;
    public static boolean appVisible = false;
    private boolean inputAllowed = true;

    private Button leftButton;
    private Button rightButton;


    public static LoginActivity getApp() {
        return app;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pin);
        String pin = BRKeyStore.getPinCode(this);
        if (pin.isEmpty() || (pin.length() != 6 && pin.length() != 4)) {
            Intent intent = new Intent(this, SetPinActivity.class);
            intent.putExtra("noPin", true);
            startActivity(intent);
            if (!LoginActivity.this.isDestroyed()) finish();
            return;
        }

        if (BRKeyStore.getPinCode(this).length() == 4) pinLimit = 4;

        keyboard = findViewById(R.id.brkeyboard);
        pinLayout = findViewById(R.id.pinLayout);
        fingerPrint = findViewById(R.id.fingerprint_icon);

        unlockedImage = findViewById(R.id.unlocked_image);
        unlockedText = findViewById(R.id.unlocked_text);
        enterPinLabel = findViewById(R.id.enter_pin_label);
        offlineButtonsLayout = findViewById(R.id.buttons_layout);

        dot1 = findViewById(R.id.dot1);
        dot2 = findViewById(R.id.dot2);
        dot3 = findViewById(R.id.dot3);
        dot4 = findViewById(R.id.dot4);
        dot5 = findViewById(R.id.dot5);
        dot6 = findViewById(R.id.dot6);

        keyboard.addOnInsertListener(new BRKeyboard.OnInsertListener() {
            @Override
            public void onClick(String key) {
                handleClick(key);
            }
        });
        keyboard.setBRButtonBackgroundResId(R.drawable.keyboard_trans_button);
        keyboard.setBRButtonTextColor(R.color.white);
        keyboard.setShowDot(false);
        keyboard.setBreadground(getDrawable(R.drawable.bread_gradient));
        keyboard.setCustomButtonBackgroundColor(10, getColor(android.R.color.transparent));
        keyboard.setDeleteImage(getDrawable(R.drawable.ic_delete_white));


        BRExecutor.getInstance().forLightWeightBackgroundTasks().execute(new Runnable() {
            @Override
            public void run() {
                //Preload the first time
                WalletsMaster.getInstance(LoginActivity.this).getAllWallets(LoginActivity.this);
            }
        });

        final boolean useFingerprint = AuthManager.isFingerPrintAvailableAndSetup(this) && BRSharedPrefs.getUseFingerprint(this);
//        Log.e(TAG, "onCreate: isFingerPrintAvailableAndSetup: " + useFingerprint);
        fingerPrint.setVisibility(useFingerprint ? View.VISIBLE : View.GONE);

        if (useFingerprint)
            fingerPrint.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    AuthManager.getInstance().authPrompt(LoginActivity.this, "", "", false, true, new BRAuthCompletion() {
                        @Override
                        public void onComplete() {
//                            AuthManager.getInstance().authSuccess(LoginActivity.this);
                            unlockWallet();
                        }

                        @Override
                        public void onCancel() {

                        }
                    });
                }
            });

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (fingerPrint != null && useFingerprint)
                    fingerPrint.performClick();
            }
        }, 500);

        BreadApp.addOnBackgroundedListener(this);

    }

    @Override
    protected void onResume() {
        super.onResume();

        appVisible = true;
        app = this;
        inputAllowed = true;

        updateDots();

        BRExecutor.getInstance().forBackgroundTasks().execute(new Runnable() {
            @Override
            public void run() {
                Thread.currentThread().setName("BG:" + TAG + ":initLastWallet");
                WalletsMaster.getInstance(LoginActivity.this).initLastWallet(LoginActivity.this);
            }
        });
        APIClient.getInstance(this).updatePlatform(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        appVisible = false;
    }

    private void handleClick(String key) {
        if (!inputAllowed) {
            Log.e(TAG, "handleClick: input not allowed");
            return;
        }
        if (key == null) {
            Log.e(TAG, "handleClick: key is null! ");
            return;
        }

        if (key.isEmpty()) {
            handleDeleteClick();
        } else if (Character.isDigit(key.charAt(0))) {
            handleDigitClick(Integer.parseInt(key.substring(0, 1)));
        } else {
            Log.e(TAG, "handleClick: oops: " + key);
        }
    }


    private void handleDigitClick(Integer dig) {
        if (pin.length() < pinLimit)
            pin.append(dig);
        updateDots();
    }

    private void handleDeleteClick() {
        if (pin.length() > 0)
            pin.deleteCharAt(pin.length() - 1);
        updateDots();
    }

    @Override
    public void onBackPressed() {
        if (getFragmentManager().getBackStackEntryCount() > 0) {
            super.onBackPressed();
        } else {
            finishAffinity();
        }
    }

    private void unlockWallet() {
        pin = new StringBuilder("");
        offlineButtonsLayout.animate().translationY(-600).setInterpolator(new AccelerateInterpolator());
        pinLayout.animate().translationY(-2000).setInterpolator(new AccelerateInterpolator());
        enterPinLabel.animate().translationY(-1800).setInterpolator(new AccelerateInterpolator());
        keyboard.animate().translationY(2000).setInterpolator(new AccelerateInterpolator());
        unlockedImage.animate().alpha(1f).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {

                        boolean showHomeActivity = (BRSharedPrefs.wasAppBackgroundedFromHome(LoginActivity.this)) ||
                                BRSharedPrefs.isNewWallet(LoginActivity.this);

                        Class toGo = showHomeActivity ? HomeActivity.class : WalletActivity.class;
                        Intent intent = new Intent(LoginActivity.this, toGo);
                        startActivity(intent);
                        overridePendingTransition(R.anim.fade_up, R.anim.fade_down);
                        if (!LoginActivity.this.isDestroyed()) {
                            LoginActivity.this.finish();
                        }
                    }
                }, 400);
            }
        });
        unlockedText.animate().alpha(1f);
    }

    private void showFailedToUnlock() {
        SpringAnimator.failShakeAnimation(LoginActivity.this, pinLayout);
        pin = new StringBuilder("");
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                inputAllowed = true;
                updateDots();
            }
        }, 1000);
    }

    private void updateDots() {
        AuthManager.getInstance().updateDots(this, pinLimit, pin.toString(), dot1, dot2, dot3, dot4, dot5, dot6, R.drawable.ic_pin_dot_white,
                new AuthManager.OnPinSuccess() {
                    @Override
                    public void onSuccess() {
                        inputAllowed = false;
                        if (AuthManager.getInstance().checkAuth(pin.toString(), LoginActivity.this)) {
                            AuthManager.getInstance().authSuccess(LoginActivity.this);
                            unlockWallet();
                        } else {
                            AuthManager.getInstance().authFail(LoginActivity.this);
                            showFailedToUnlock();
                        }
                    }
                });
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {
            case BRConstants.CAMERA_REQUEST_ID: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    BRAnimator.openScanner(this, BRConstants.SCANNER_REQUEST);
                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {
                    Log.e(TAG, "onRequestPermissionsResult: permission isn't granted for: " + requestCode);
                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
    }

    @Override
    public void onBackgrounded() {
        //disconnect all wallets on backgrounded
        List<BaseWalletManager> list = new ArrayList<>(WalletsMaster.getInstance(LoginActivity.this).getAllWallets(LoginActivity.this));
        for (BaseWalletManager w : list) {
            w.disconnect(LoginActivity.this);
        }
    }
}
