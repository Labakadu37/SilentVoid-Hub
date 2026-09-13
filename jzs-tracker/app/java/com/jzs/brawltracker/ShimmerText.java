package com.jzs.brawltracker;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Matrix;
import android.graphics.Shader;
import android.view.animation.LinearInterpolator;
import android.widget.TextView;

/**
 * Gold text with a highlight that sweeps across it, left to right.
 *
 * The gradient is wider than the view and slid along by a matrix, so the
 * bright band travels through the letters instead of the whole word pulsing.
 */
final class ShimmerText extends TextView {

    private static final int SWEEP_MS = 2600;

    private final Matrix matrix = new Matrix();
    private ValueAnimator sweep;
    private LinearGradient gradient;
    private float offset;
    private float span;

    ShimmerText(Context context) {
        super(context);
        setIncludeFontPadding(false);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        super.onSizeChanged(w, h, oldW, oldH);
        if (w <= 0) {
            return;
        }
        // A band one view-width wide travelling across two view-widths.
        span = w;
        gradient = new LinearGradient(0f, 0f, span, 0f,
                new int[]{Ui.GOLD, Ui.GOLD, 0xFFFFF3C4, Ui.LIME, Ui.GOLD, Ui.GOLD},
                new float[]{0f, 0.32f, 0.46f, 0.54f, 0.68f, 1f},
                Shader.TileMode.CLAMP);
        getPaint().setShader(gradient);
        restart();
    }

    private void restart() {
        stop();
        sweep = ValueAnimator.ofFloat(-span, span * 2f);
        sweep.setDuration(SWEEP_MS);
        sweep.setRepeatCount(ValueAnimator.INFINITE);
        sweep.setInterpolator(new LinearInterpolator());
        sweep.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                offset = (Float) animation.getAnimatedValue();
                invalidate();
            }
        });
        sweep.start();
    }

    private void stop() {
        if (sweep != null) {
            sweep.cancel();
            sweep = null;
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (gradient != null) {
            matrix.setTranslate(offset, 0f);
            gradient.setLocalMatrix(matrix);
        }
        super.onDraw(canvas);
    }

    @Override
    protected void onDetachedFromWindow() {
        stop();
        super.onDetachedFromWindow();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (gradient != null && sweep == null) {
            restart();
        }
    }
}
