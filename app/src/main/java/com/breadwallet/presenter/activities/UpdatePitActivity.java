package com.breadwallet.presenter.activities;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.breadwallet.R;
import com.breadwallet.presenter.customviews.BRKeyboard;
import com.breadwallet.presenter.interfaces.BROnSignalCompletion;
import com.breadwallet.tools.animation.BRAnimator;
import com.breadwallet.tools.animation.SpringAnimator;
import com.breadwallet.tools.security.AuthManager;
import com.breadwallet.tools.security.KeyStoreManager;

public class UpdatePitActivity extends Activity {
    private static final String TAG = UpdatePitActivity.class.getName();
    private BRKeyboard keyboard;
    private View dot1;
    private View dot2;
    private View dot3;
    private View dot4;
    private View dot5;
    private View dot6;
    private StringBuilder pin = new StringBuilder();
    private int pinLimit = 6;
    //    private boolean allowInserting = true;
    private TextView title;
    private TextView description;
    int mode = ENTER_PIN;
    public static final int ENTER_PIN = 1;
    public static final int ENTER_NEW_PIN = 2;
    public static final int RE_ENTER_NEW_PIN = 3;

    private LinearLayout pinLayout;
    private String curNewPin = "";
    public static boolean appVisible = false;
    private static UpdatePitActivity app;

    public static UpdatePitActivity getApp() {
        return app;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pin_template);

        keyboard = (BRKeyboard) findViewById(R.id.brkeyboard);
        title = (TextView) findViewById(R.id.title);
        description = (TextView) findViewById(R.id.description);
        pinLayout = (LinearLayout) findViewById(R.id.pinLayout);
        if (KeyStoreManager.getPinCode(this).length() == 4) pinLimit = 4;
        setMode(ENTER_PIN);
        title.setText("Update PIN");
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
        keyboard.setShowDot(false);

    }

    @Override
    protected void onResume() {
        super.onResume();
        updateDots();
        appVisible = true;
        app = this;
        ActivityUTILS.init(this);
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
        super.onBackPressed();
        overridePendingTransition(R.anim.enter_from_left, R.anim.exit_to_right);
    }

    private void updateDots() {

        AuthManager.getInstance().updateDots(this, pinLimit, pin.toString(), dot1, dot2, dot3, dot4, dot5, dot6, R.drawable.ic_pin_dot_gray, new AuthManager.OnPinSuccess() {
            @Override
            public void onSuccess() {
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        goNext();
                    }
                }, 100);
            }
        });

    }

    private void goNext() {
        Log.e(TAG, "goNext: mode: " + mode);
        switch (mode) {
            case ENTER_PIN:
                if (AuthManager.getInstance().checkAuth(pin.toString(), this)) {
                    setMode(ENTER_NEW_PIN);
                    pinLimit = 6;
                } else {
                    SpringAnimator.failShakeAnimation(this, pinLayout);
                }
                pin = new StringBuilder("");
                updateDots();
                break;
            case ENTER_NEW_PIN:
                setMode(RE_ENTER_NEW_PIN);
                curNewPin = pin.toString();
                pin = new StringBuilder("");
                updateDots();
                break;

            case RE_ENTER_NEW_PIN:
                if (curNewPin.equalsIgnoreCase(pin.toString())) {
                    Log.e(TAG, "goNext: SUCCESS");
                    AuthManager.getInstance().setPinCode(pin.toString(), this);
                    BRAnimator.showBreadSignal(this, "PIN Set", "Use your PIN to login and send money.", R.drawable.ic_check_mark_white, new BROnSignalCompletion() {
                        @Override
                        public void onComplete() {
                            BRAnimator.startBreadActivity(UpdatePitActivity.this, false);
                        }
                    });
                } else {
                    SpringAnimator.failShakeAnimation(this, pinLayout);
                    setMode(ENTER_NEW_PIN);
                    pinLimit = KeyStoreManager.getPinCode(this).length();
                }
                pin = new StringBuilder("");
                updateDots();
                break;
        }
    }

    private void setMode(int mode) {
        String text = "";
        this.mode = mode;
        switch (mode) {
            case ENTER_PIN:
                text = "Enter your current PIN.";
                break;
            case ENTER_NEW_PIN:
                text = "Enter your new PIN.";
                break;
            case RE_ENTER_NEW_PIN:
                text = "Re-Enter your new PIN.";
                break;
        }
        description.setText(text);
        SpringAnimator.springView(description);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
    }
}
