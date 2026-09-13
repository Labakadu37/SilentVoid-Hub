package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.view.View;

/**
 * Trophy movement across the recent battle log: a bar per battle showing what
 * it gained or cost, and a line tracing the running total over them.
 *
 * The battle log is the only history the API exposes, so the horizontal axis
 * is battles rather than days.
 */
final class TrendChart extends View {

    private final Paint bar = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint line = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint baseline = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Path path = new Path();

    /** Per-battle trophy deltas, oldest first. */
    private int[] deltas = new int[0];
    private int[] running = new int[0];
    private int runMin;
    private int runMax;
    private int peakDelta = 1;

    TrendChart(Context context) {
        super(context);
        line.setStyle(Paint.Style.STROKE);
        line.setStrokeWidth(Ui.dp(context, 2));
        line.setStrokeCap(Paint.Cap.ROUND);
        line.setStrokeJoin(Paint.Join.ROUND);
        line.setColor(Ui.LIME);

        baseline.setStrokeWidth(Math.max(1, Ui.dp(context, 1) / 2));
        baseline.setColor(Ui.STROKE);
    }

    void setDeltas(int[] values) {
        deltas = values == null ? new int[0] : values;
        running = new int[deltas.length];

        int total = 0;
        runMin = 0;
        runMax = 0;
        peakDelta = 1;
        for (int i = 0; i < deltas.length; i++) {
            total += deltas[i];
            running[i] = total;
            runMin = Math.min(runMin, total);
            runMax = Math.max(runMax, total);
            peakDelta = Math.max(peakDelta, Math.abs(deltas[i]));
        }
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (deltas.length == 0) {
            return;
        }
        float w = getWidth();
        float h = getHeight();
        float barZone = h * 0.42f;
        float lineZone = h - barZone - Ui.dp(getContext(), 8);

        // Bars: each battle's gain or loss, mirrored around a centre line.
        float slot = w / deltas.length;
        float barW = Math.max(Ui.dp(getContext(), 2), slot * 0.55f);
        float mid = lineZone + Ui.dp(getContext(), 8) + barZone / 2f;
        canvas.drawLine(0, mid, w, mid, baseline);

        for (int i = 0; i < deltas.length; i++) {
            if (deltas[i] == 0) {
                continue;
            }
            float cx = slot * (i + 0.5f);
            float height = (barZone / 2f) * Math.abs(deltas[i]) / peakDelta;
            bar.setColor(deltas[i] > 0 ? Ui.WIN : Ui.LOSS);
            float top = deltas[i] > 0 ? mid - height : mid;
            canvas.drawRect(cx - barW / 2f, top, cx + barW / 2f, top + height, bar);
        }

        // Line: the running total, scaled to whatever range it covered.
        int span = Math.max(1, runMax - runMin);
        path.reset();
        for (int i = 0; i < running.length; i++) {
            float x = running.length == 1 ? w / 2f : w * i / (running.length - 1f);
            float y = lineZone - lineZone * (running[i] - runMin) / (float) span;
            if (i == 0) {
                path.moveTo(x, y);
            } else {
                path.lineTo(x, y);
            }
        }
        line.setColor(running[running.length - 1] >= 0 ? Ui.WIN : Ui.LOSS);
        canvas.drawPath(path, line);
    }
}
