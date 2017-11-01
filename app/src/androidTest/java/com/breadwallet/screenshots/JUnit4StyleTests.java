package com.breadwallet.screenshots;

import android.os.Build;
import android.support.test.espresso.IdlingPolicies;
import android.support.test.rule.ActivityTestRule;

import com.breadwallet.R;
import com.breadwallet.presenter.activities.BreadActivity;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.util.concurrent.TimeUnit;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.UiAutomatorScreenshotStrategy;
import tools.fastlane.screengrab.locale.LocaleTestRule;
import tools.fastlane.screengrab.locale.LocaleUtil;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on <mihail@breadwallet.com> 10/31/17.
 * Copyright (c) 2017 breadwallet LLC
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
@RunWith(JUnit4.class)
public class JUnit4StyleTests {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<BreadActivity> activityRule = new ActivityTestRule<>(BreadActivity.class);

    @BeforeClass
    public static void beforeClass() {
        IdlingPolicies.setMasterPolicyTimeout(600, TimeUnit.SECONDS);
        IdlingPolicies.setIdlingResourceTimeout(600, TimeUnit.SECONDS);
    }


    @Before
    public void setUp(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());
        }
        activityRule.getActivity();
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());
    }

    @After
    public void tearDown(){
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());
    }

    @Test
    public void testTakeScreenshot() {
        Screengrab.screenshot("transaction_list");

//        onView(withId(R.id.fab)).perform(click());
//
//        Screengrab.screenshot("after_button_click");
    }
}