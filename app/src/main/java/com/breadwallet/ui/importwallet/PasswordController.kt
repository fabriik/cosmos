/**
 * BreadWallet
 *
 * Created by Drew Carlson <drew.carlson@breadwallet.com> on 12/3/19.
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
package com.breadwallet.ui.importwallet

import android.os.Bundle
import android.view.inputmethod.EditorInfo
import com.breadwallet.R
import com.breadwallet.ui.BaseMobiusController
import com.breadwallet.ui.changehandlers.DialogChangeHandler
import com.breadwallet.ui.flowbind.clicks
import com.breadwallet.ui.flowbind.editorActions
import com.breadwallet.ui.flowbind.textChanges
import com.spotify.mobius.Next.dispatch
import com.spotify.mobius.Next.next
import com.spotify.mobius.Update
import com.spotify.mobius.flow.subtypeEffectHandler
import kotlinx.android.synthetic.main.controller_import_password.*
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge

class PasswordController(
    args: Bundle? = null
) : BaseMobiusController<PasswordController.M, PasswordController.E, PasswordController.F>(args) {

    init {
        overridePopHandler(DialogChangeHandler())
        overridePushHandler(DialogChangeHandler())
    }

    override val layoutId = R.layout.controller_import_password
    override val defaultModel = M.DEFAULT
    override val update = Update<M, E, F> { model, event ->
        when (event) {
            is E.OnPasswordChanged -> next(model.copy(password = event.password))
            E.OnConfirmClicked -> dispatch(setOf(F.Confirm(model.password)))
            E.OnCancelClicked -> dispatch(setOf(F.Cancel))
        }
    }

    override val flowEffectHandler
        get() = subtypeEffectHandler<F, E> {
            addConsumerSync(Main, ::handleConfirm)
            addActionSync<F.Cancel>(Main, ::handleCancel)
        }

    override fun bindView(modelFlow: Flow<M>): Flow<E> {
        return merge(
            input_password.editorActions()
                .filter { it == EditorInfo.IME_ACTION_DONE }
                .map { E.OnConfirmClicked },
            input_password.textChanges().map { E.OnPasswordChanged(it) },
            button_confirm.clicks().map { E.OnConfirmClicked },
            button_cancel.clicks().map { E.OnCancelClicked }
        )
    }

    private fun handleConfirm(effect: F.Confirm) {
        (targetController as? Listener)?.onPasswordConfirmed(effect.password)
        router.popController(this)
    }

    private fun handleCancel() {
        (targetController as? Listener)?.onPasswordCancelled()
        router.popController(this)
    }

    interface Listener {
        fun onPasswordConfirmed(password: String)
        fun onPasswordCancelled()
    }

    data class M(val password: String = "") {
        companion object {
            val DEFAULT = M()
        }

        override fun toString() =
            "M(password='***')"
    }

    sealed class E {
        data class OnPasswordChanged(
            val password: String
        ) : E() {
            override fun toString() =
                "OnPasswordChanged()"
        }

        object OnConfirmClicked : E()
        object OnCancelClicked : E()
    }

    sealed class F {
        data class Confirm(
            val password: String
        ) : F() {
            override fun toString() =
                "Confirm()"
        }

        object Cancel : F()
    }
}
