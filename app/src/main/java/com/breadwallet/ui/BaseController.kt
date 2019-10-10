/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 8/12/19.
 * Copyright (c) 2019 breadwallet LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.breadwallet.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.widget.toast
import com.bluelinelabs.conductor.Controller
import kotlinx.android.extensions.LayoutContainer
import kotlinx.android.synthetic.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.cancelChildren
import org.kodein.di.KodeinAware
import org.kodein.di.android.closestKodein
import org.kodein.di.android.kodein

/**
 * A simple controller that automatically inflates the
 * [layoutId] and implements [LayoutContainer].
 */
@Suppress("TooManyFunctions")
abstract class BaseController(
    args: Bundle? = null
) : Controller(args), KodeinAware, LayoutContainer {

    protected val controllerScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    protected val viewAttachScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    protected val viewCreatedScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    /** Provides the root Application Kodein instance. */
    override val kodein by closestKodein {
        checkNotNull(applicationContext) {
            "Controller cannot access Kodein bindings until attached to an Activity."
        }
    }

    final override var containerView: View? = null
        private set

    /** The layout id to be used for inflating this controller's view. */
    open val layoutId: Int = -1

    /** Called when the view has been inflated and [containerView] is set. */
    open fun onCreateView(view: View) {
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup): View {
        check(layoutId > 0) { "Must set layoutId or override onCreateView." }
        return inflater.inflate(layoutId, container, false).apply {
            containerView = this
            onCreateView(this)
        }
    }

    override fun onDestroyView(view: View) {
        super.onDestroyView(view)
        viewCreatedScope.coroutineContext.cancelChildren()
        clearFindViewByIdCache()
    }

    override fun onDetach(view: View) {
        super.onDetach(view)
        viewAttachScope.coroutineContext.cancelChildren()
    }

    override fun onDestroy() {
        super.onDestroy()
        controllerScope.coroutineContext.cancelChildren()
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> argOptional(key: String, default: T? = null): T? =
        (args[key] as T) ?: default

    /** Returns the value for [key] stored in the [args] [Bundle] as [T]. */
    @Suppress("UNCHECKED_CAST")
    fun <T> arg(key: String, default: T? = null): T =
        checkNotNull(args[key] ?: default) {
            "No value for $key and no default provided (or it was null)."
        } as T

    /** Display a [Toast] message of [resId] with a short duration. */
    fun toast(resId: Int) = checkNotNull(applicationContext).toast(resId, Toast.LENGTH_SHORT)

    /** Display a [Toast] message of [text] with a short duration. */
    fun toast(text: String) = checkNotNull(applicationContext).toast(text, Toast.LENGTH_SHORT)

    /** Display a [Toast] message of [resId] with a long duration. */
    fun toastLong(resId: Int) = checkNotNull(applicationContext).toast(resId, Toast.LENGTH_LONG)

    /** Display a [Toast] message of [text] with a long duration. */
    fun toastLong(text: String) = checkNotNull(applicationContext).toast(text, Toast.LENGTH_LONG)
}
