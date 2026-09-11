package org.jzs.brawl;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.os.Build;
import android.util.TypedValue;
import android.view.View;
import android.view.WindowInsets;

/** Le bandeau doré en haut à gauche du lobby. */
@SuppressLint("ViewConstructor")
public final class JzsOverlay extends View {

    private final JzsConfig cfg;
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private final float margin;
    private final float lineGap;
    private final float textSize;
    private float insetTop;
    private float insetLeft;

    /* Écrits depuis le thread des stats, lus depuis onDraw : volatile suffit,
     * les lignes sont recomposées à chaque dessin plutôt que partagées. */
    private volatile int pingMs = -1;
    private volatile String region = "";
    private volatile int online = -1;

    public JzsOverlay(Context ctx, JzsConfig cfg) {
        super(ctx);
        this.cfg = cfg;

        textSize = sp(cfg.textSizeSp);
        margin = dp(cfg.marginDp);
        lineGap = textSize * 1.35f;

        paint.setColor(cfg.textColor);
        paint.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));
        paint.setTextSize(textSize);
        paint.setShadowLayer(sp(2f), 0f, sp(1f), cfg.shadowColor);
        setLayerType(LAYER_TYPE_SOFTWARE, paint);
    }

    /** Appelable depuis n'importe quel thread. */
    public void updateStats(int pingMs, String region, int online) {
        this.pingMs = pingMs;
        this.region = region == null ? "" : region;
        this.online = online;
        postInvalidate();
    }

    private String pingLine() {
        if (pingMs < 0) return "Ping: --";
        String r = region;
        return r.isEmpty() ? "Ping: " + pingMs + " ms" : "Ping: " + pingMs + " ms (" + r + ")";
    }

    @Override
    public WindowInsets onApplyWindowInsets(WindowInsets insets) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            android.graphics.Insets bars = insets.getInsets(
                    WindowInsets.Type.systemBars() | WindowInsets.Type.displayCutout());
            insetTop = bars.top;
            insetLeft = bars.left;
        } else {
            insetTop = insets.getSystemWindowInsetTop();
            insetLeft = insets.getSystemWindowInsetLeft();
        }
        invalidate();
        return insets;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        float x = insetLeft + margin;
        float y = insetTop + margin + textSize;

        canvas.drawText(cfg.modName + " " + cfg.version + " (" + cfg.channel + ")", x, y, paint);
        y += lineGap;
        canvas.drawText("Telegram: " + cfg.socials, x, y, paint);
        y += lineGap;
        canvas.drawText(pingLine(), x, y, paint);
        y += lineGap;
        canvas.drawText(online >= 0 ? "Online: " + online : "Online: --", x, y, paint);
    }

    private float sp(float v) {
        return TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP, v, getResources().getDisplayMetrics());
    }

    private float dp(float v) {
        return TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, v, getResources().getDisplayMetrics());
    }
}
