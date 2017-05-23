package com.breadwallet.presenter.activities;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
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

import com.breadwallet.R;
import com.breadwallet.presenter.customviews.BRDialogView;
import com.breadwallet.presenter.customviews.BRKeyboard;
import com.breadwallet.presenter.interfaces.BRAuthCompletion;
import com.breadwallet.tools.animation.BRAnimator;
import com.breadwallet.tools.animation.BreadDialog;
import com.breadwallet.tools.animation.SpringAnimator;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.security.AuthManager;
import com.breadwallet.tools.security.BitcoinUrlHandler;
import com.breadwallet.tools.security.KeyStoreManager;
import com.breadwallet.tools.security.PostAuthenticationProcessor;
import com.breadwallet.tools.util.BRConstants;
import com.breadwallet.wallet.BRWalletManager;
import com.platform.APIClient;

import static com.breadwallet.R.color.white;
import static com.breadwallet.tools.util.BRConstants.PLATFORM_ON;

public class PinActivity extends Activity {
    private static final String TAG = PinActivity.class.getName();
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
    private static PinActivity app;

    private ImageView unlockedImage;
    private TextView unlockedText;
    private TextView enterPinLabel;
    private LinearLayout offlineButtonsLayout;

    private ImageButton fingerPrint;
    public static boolean appVisible = false;

    private Button leftButton;
    private Button rightButton;

    static {
        System.loadLibrary("core");
    }

    public static PinActivity getApp() {
        return app;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pin);
        String pin = KeyStoreManager.getPinCode(this);
        if (pin.isEmpty() || (pin.length() != 6 && pin.length() != 4)) {
            Intent intent = new Intent(this, IntroSetPitActivity.class);
            intent.putExtra("noPin", true);
            startActivity(intent);
            if (!PinActivity.this.isDestroyed()) finish();
            return;
        }

        if (KeyStoreManager.getPinCode(this).length() == 4) pinLimit = 4;

        keyboard = (BRKeyboard) findViewById(R.id.brkeyboard);
        pinLayout = (LinearLayout) findViewById(R.id.pinLayout);
        fingerPrint = (ImageButton) findViewById(R.id.fingerprint_icon);

        unlockedImage = (ImageView) findViewById(R.id.unlocked_image);
        unlockedText = (TextView) findViewById(R.id.unlocked_text);
        enterPinLabel = (TextView) findViewById(R.id.enter_pin_label);
        offlineButtonsLayout = (LinearLayout) findViewById(R.id.buttons_layout);

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

        leftButton = (Button) findViewById(R.id.left_button);
        rightButton = (Button) findViewById(R.id.right_button);

        setUpOfflineButtons();

        leftButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                BRAnimator.showReceiveFragment(PinActivity.this, false);
//                chooseWordsSize(true);
            }
        });

        rightButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                try {
                    // Check if the camera permission is granted
                    if (ContextCompat.checkSelfPermission(app,
                            Manifest.permission.CAMERA)
                            != PackageManager.PERMISSION_GRANTED) {
                        // Should we show an explanation?
                        if (ActivityCompat.shouldShowRequestPermissionRationale(app,
                                Manifest.permission.CAMERA)) {
                            BreadDialog.showCustomDialog(app, "Permission Required.",
                                    app.getString(R.string.CameraPlugin_allowCameraAccess_Android), "close", null, new BRDialogView.BROnClickListener() {
                                        @Override
                                        public void onClick(BRDialogView brDialogView) {
                                            brDialogView.dismiss();
                                        }
                                    }, null, null, 0);
                        } else {
                            // No explanation needed, we can request the permission.
                            ActivityCompat.requestPermissions(app,
                                    new String[]{Manifest.permission.CAMERA},
                                    BRConstants.CAMERA_REQUEST_ID);
                        }
                    } else {
                        // Permission is granted, open camera
                        Intent intent = new Intent(app, ScanQRActivity.class);
                        app.startActivityForResult(intent, 123);
                        app.overridePendingTransition(R.anim.fade_up, 0);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        boolean useFingerprint = AuthManager.isFingerPrintAvailableAndSetup(this) && SharedPreferencesManager.getUseFingerprint(this);
        Log.e(TAG, "onCreate: isFingerPrintAvailableAndSetup: " + useFingerprint);
        fingerPrint.setVisibility(useFingerprint ? View.VISIBLE : View.GONE);

        if (useFingerprint)
            fingerPrint.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    AuthManager.getInstance().authPrompt(PinActivity.this, "", "", false, new BRAuthCompletion() {
                        @Override
                        public void onComplete() {
                            BRAnimator.startBreadActivity(PinActivity.this, false);
                        }

                        @Override
                        public void onCancel() {

                        }
                    });
                }
            });

    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.e(TAG, "onResume: ");
        updateDots();
        appVisible = true;
        app = this;
        ActivityUTILS.init(this);
        if (!BRWalletManager.getInstance().isCreated()) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    BRWalletManager.getInstance().setUpTheWallet(PinActivity.this);
                }
            }).start();
        }
        if (PLATFORM_ON)
            APIClient.getInstance(this).updatePlatform();
    }

    @Override
    protected void onPause() {
        super.onPause();
        appVisible = false;
    }

    private void handleClick(String key) {
        if (key == null) {
            Log.e(TAG, "handleClick: key is null! ");
            return;
        }
        if (key.length() > 1) {
            Log.e(TAG, "handleClick: key is longer: " + key);
            return;
        }

        if (key.isEmpty()) {
            handleDeleteClick();
        } else if (Character.isDigit(key.charAt(0))) {
            handleDigitClick(Integer.parseInt(key));
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
        }
    }

    private void unlockWallet() {
        pin = new StringBuilder("");
        offlineButtonsLayout.animate().translationY(-600).setInterpolator(new AccelerateInterpolator());
        pinLayout.animate().translationY(-2000).setInterpolator(new AccelerateInterpolator());
        enterPinLabel.animate().translationY(-1800).setInterpolator(new AccelerateInterpolator());
        keyboard.animate().translationY(1000).setInterpolator(new AccelerateInterpolator());
        unlockedImage.animate().alpha(1f).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Intent intent = new Intent(PinActivity.this, BreadActivity.class);
                        startActivity(intent);
                        overridePendingTransition(R.anim.fade_up, R.anim.fade_down);
                        if (!PinActivity.this.isDestroyed()) {
                            PinActivity.this.finish();
                        }
                    }
                }, 700);
            }
        });
        unlockedText.animate().alpha(1f);
    }

    private void showFailedToUnlock() {
        Log.e(TAG, "showFailedToUnlock: ");
        SpringAnimator.failShakeAnimation(PinActivity.this, pinLayout);
        pin = new StringBuilder("");
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                updateDots();
            }
        }, 1000);
    }

    private void updateDots() {
        Log.e(TAG, "updateDots: " + pin.toString());
        AuthManager.getInstance().updateDots(this, pinLimit, pin.toString(), dot1, dot2, dot3, dot4, dot5, dot6, R.drawable.ic_pin_dot_white,
                new AuthManager.OnPinSuccess() {
                    @Override
                    public void onSuccess() {
                        Log.e(TAG, "onSuccess: ");
                        if (AuthManager.getInstance().checkAuth(pin.toString(), PinActivity.this)) {
                            AuthManager.getInstance().authSuccess(PinActivity.this);
                            unlockWallet();
                        } else {
                            AuthManager.getInstance().authFail(PinActivity.this);
                            showFailedToUnlock();
                        }
                    }
                });
    }

    private void setUpOfflineButtons() {
        int activeColor = getColor(white);
        GradientDrawable leftDrawable = (GradientDrawable) leftButton.getBackground().getCurrent();
        GradientDrawable rightDrawable = (GradientDrawable) rightButton.getBackground().getCurrent();

        int rad = 30;
        int stoke = 2;

        leftDrawable.setCornerRadii(new float[]{rad, rad, 0, 0, 0, 0, rad, rad});
        rightDrawable.setCornerRadii(new float[]{0, 0, rad, rad, rad, rad, 0, 0});

        leftDrawable.setStroke(stoke, activeColor, 0, 0);
        rightDrawable.setStroke(stoke, activeColor, 0, 0);
        leftButton.setTextColor(activeColor);
        rightButton.setTextColor(activeColor);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, final Intent data) {

        // 123 is the qrCode result
        switch (requestCode) {
            case 123:
                if (resultCode == Activity.RESULT_OK) {
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            Log.e(TAG, "run: result got back!");
                            String result = data.getStringExtra("result");
                            if (BitcoinUrlHandler.isBitcoinUrl(result))
                                BitcoinUrlHandler.processRequest(PinActivity.this, result);
                            else if (BitcoinUrlHandler.isBitId(result))
                                BitcoinUrlHandler.tryBitIdUri(PinActivity.this, result, null);
                            else
                                Log.e(TAG, "onActivityResult: not bitcoin address NOR bitID");
                        }
                    }, 500);

                }
                break;
            case BRConstants.PAY_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            PostAuthenticationProcessor.getInstance().onPublishTxAuth(PinActivity.this, true);
                        }
                    }).start();
                }
                break;

            case BRConstants.PAYMENT_PROTOCOL_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    PostAuthenticationProcessor.getInstance().onPaymentProtocolRequest(this, true);
                }
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {
            case BRConstants.CAMERA_REQUEST_ID: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    BRAnimator.openCamera(this);
                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {

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

}
