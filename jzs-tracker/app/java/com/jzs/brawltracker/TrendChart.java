package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.DashPathEffect;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Shader;
import android.view.View;

/**
 * The running trophy total over the recent battle log, as one filled curve.
 *
 * A single story: where the total sat after each battle, relative to where it
 * started. The area under the line is filled with a fading gradient, a dashed
 * rule marks the starting level, and the last point carries a dot. The line is
 * green when the session ended up, red when it ended down.
 *
 * The battle log is the only history the API exposes, so the axis is battles,
 * not days.
 */
final class TrendChart extends View {

    private final Paint line = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint fill = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint zero = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint dot = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Path linePath = new Path();
    private final Path fillPath = new Path();

    private int[] running = new int[0];
    private int lo;
    private int hi;

    TrendChart(Context context) {
        super(context);
        line.setStyle(Paint.Style.STROKE);
        line.setStrokeWidth(Ui.dp(context, 2.5f));
        line.setStrokeCap(Paint.Cap.ROUND);
        line.setStrokeJoin(Paint.Join.ROUND);

        zero.setStyle(Paint.Style.STROKE);
        zero.setStrokeWidth(Math.max(1, Ui.dp(context, 1)));
        zero.setColor(Ui.STROKE);
        zero.setPathEffect(new DashPathEffect(
                new float[]{Ui.dp(context, 4), Ui.dp(context, 4)}, 0));

        dot.setStyle(Paint.Style.FILL);
    }

    /** Per-battle deltas oldest first; the chart plots their running sum. */
    void setDeltas(int[] deltas) {
        int n = deltas == null ? 0 : deltas.length;
        running = new int[n];
        int total = 0;
        lo = 0;
        hi = 0;
        for (int i = 0; i < n; i++) {
            total += deltas[i];
            running[i] = total;
            lo = Math.min(lo, total);
            hi = Math.max(hi, total);
        }
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int n = running.length;
        if (n < 2) {
            return;
        }
        float padX = Ui.dp(getContext(), 2);
        float padY = Ui.dp(getContext(), 10);
        float w = getWidth() - padX * 2;
        float h = getHeight() - padY * 2;

        // Include zero in the range so the starting level is always on screen.
        int span = Math.max(1, hi - lo);
        boolean up = running[n - 1] >= 0;
        int colour = up ? Ui.WIN : Ui.LOSS;

        float[] xs = new float[n];
        float[] ys = new float[n];
        for (int i = 0; i < n; i++) {
            xs[i] = padX + w * i / (n - 1f);
            ys[i] = padY + h - h * (running[i] - lo) / span;
        }
        float zeroY = padY + h - h * (0 - lo) / span;

        // Filled area under the line, fading down from the line colour.
        fillPath.reset();
        fillPath.moveTo(xs[0], getHeight() - padY);
        for (int i = 0; i < n; i++) {
            fillPath.lineTo(xs[i], ys[i]);
        }
        fillPath.lineTo(xs[n - 1], getHeight() - padY);
        fillPath.close();
        fill.setShader(new LinearGradient(0, padY, 0, getHeight() - padY,
                (colour & 0x00FFFFFF) | 0x55000000, (colour & 0x00FFFFFF),
                Shader.TileMode.CLAMP));
        canvas.drawPath(fillPath, fill);

        canvas.drawLine(padX, zeroY, padX + w, zeroY, zero);

        linePath.reset();
        linePath.moveTo(xs[0], ys[0]);
        for (int i = 1; i < n; i++) {
            linePath.lineTo(xs[i], ys[i]);
        }
        line.setColor(colour);
        canvas.drawPath(linePath, line);

        dot.setColor(colour);
        canvas.drawCircle(xs[n - 1], ys[n - 1], Ui.dp(getContext(), 4), dot);
        dot.setColor(Ui.BG);
        canvas.drawCircle(xs[n - 1], ys[n - 1], Ui.dp(getContext(), 1.6f), dot);
    }
}
