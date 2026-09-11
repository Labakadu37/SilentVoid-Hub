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

import java.util.ArrayList;
import java.util.List;

/** Le bandeau doré en haut à gauche du lobby. */
@SuppressLint("ViewConstructor")
public final class JzsOverlay extends View {

    private final JzsConfig cfg;
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final List<String> lines = new ArrayList<>();

    private final float margin;
    private final float lineGap;
    private float insetTop;
    private float insetLeft;

    private int pingMs = -1;
    private String region = "";
    private int online = -1;

    public JzsOverlay(Context ctx, JzsConfig cfg) {
        super(ctx);
        this.cfg = cfg;
        setBackgroundColor(0x00000000);

        paint.setColor(cfg.textColor);
        paint.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));
        paint.setTextSize(sp(cfg.textSizeSp));
        paint.setShadowLayer(sp(2f), 0f, sp(1f), cfg.shadowColor);
        setLayerType(LAYER_TYPE_SOFTWARE, paint);

        margin = dp(cfg.marginDp);
        lineGap = sp(cfg.textSizeSp) * 1.35f;
        rebuild();
    }

    /** Appelé depuis le thread des stats. */
    public void updateStats(int pingMs, String region, int online) {
        this.pingMs = pingMs;
        this.region = region == null ? "" : region;
        this.online = online;
        post(() -> {
            rebuild();
            invalidate();
        });
    }

    private void rebuild() {
        lines.clear();
        lines.add(cfg.modName + " " + cfg.version + " (" + cfg.channel + ")");
        lines.add("Telegram: " + cfg.socials);

        if (pingMs >= 0) {
            lines.add(region.isEmpty()
                    ? "Ping: " + pingMs + " ms"
                    : "Ping: " + pingMs + " ms (" + region + ")");
        } else {
            lines.add("Ping: --");
        }

        lines.add(online >= 0 ? "Online: " + online : "Online: --");
    }

    @Override
    public WindowInsets onApplyWindowInsets(WindowInsets insets) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            android.graphics.Insets bars =
                    insets.getInsets(WindowInsets.Type.systemBars() | WindowInsets.Type.displayCutout());
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
        float y = insetTop + margin + sp(cfg.textSizeSp);
        for (String line : lines) {
            canvas.drawText(line, x, y, paint);
            y += lineGap;
        }
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
