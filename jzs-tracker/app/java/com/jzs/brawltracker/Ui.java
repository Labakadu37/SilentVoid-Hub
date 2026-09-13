package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Dark palette and the building blocks every screen is assembled from. */
final class Ui {

    static final int BG = Color.parseColor("#07090B");
    static final int CARD = Color.parseColor("#12151A");
    static final int CARD_SOFT = Color.parseColor("#1B2027");
    static final int STROKE = Color.parseColor("#232A33");

    static final int LIME = Color.parseColor("#C3F53C");
    static final int GOLD = Color.parseColor("#FFB020");
    static final int WIN = Color.parseColor("#4ADE80");
    static final int LOSS = Color.parseColor("#FF5F5F");
    static final int DRAW = Color.parseColor("#5AB0FF");
    static final int ORANGE = Color.parseColor("#FF9F40");
    static final int PURPLE = Color.parseColor("#B47CFF");
    static final int CYAN = Color.parseColor("#4DD9E8");

    static final int WHITE = Color.parseColor("#F2F5F8");
    static final int MUTED = Color.parseColor("#7D8793");

    /** Corner radii are small on purpose — the layout reads squarer that way. */
    private static final int CARD_RADIUS = 12;
    private static final int CHIP_RADIUS = 6;

    private Ui() {
    }

    static int dp(Context c, int value) {
        return Math.round(TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, value, c.getResources().getDisplayMetrics()));
    }

    // ------------------------------------------------------------------ text

    static TextView text(Context c, String value, int sp, int color) {
        TextView t = new TextView(c);
        t.setText(value);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, sp);
        t.setTextColor(color);
        t.setIncludeFontPadding(false);
        return t;
    }

    static TextView heavy(Context c, String value, int sp, int color) {
        TextView t = text(c, value, sp, color);
        t.setTypeface(Typeface.create("sans-serif-black", Typeface.NORMAL));
        return t;
    }

    static TextView bold(Context c, String value, int sp, int color) {
        TextView t = text(c, value, sp, color);
        t.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        return t;
    }

    static TextView label(Context c, String value, int color) {
        TextView t = text(c, value.toUpperCase(), 11, color);
        t.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        t.setLetterSpacing(0.16f);
        return t;
    }

    // --------------------------------------------------------------- layouts

    static LinearLayout column(Context c) {
        LinearLayout l = new LinearLayout(c);
        l.setOrientation(LinearLayout.VERTICAL);
        return l;
    }

    static LinearLayout row(Context c) {
        LinearLayout l = new LinearLayout(c);
        l.setOrientation(LinearLayout.HORIZONTAL);
        l.setGravity(Gravity.CENTER_VERTICAL);
        return l;
    }

    static GradientDrawable round(int color, int radiusPx) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(radiusPx);
        return d;
    }

    /** Filled panel with a hairline edge, which is what gives cards their shape. */
    static GradientDrawable panel(Context c, int fill, int strokeColor, int radiusDp) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(fill);
        d.setCornerRadius(dp(c, radiusDp));
        d.setStroke(Math.max(1, dp(c, 1) / 2), strokeColor);
        return d;
    }

    static LinearLayout card(Context c) {
        LinearLayout l = column(c);
        l.setBackground(panel(c, CARD, STROKE, CARD_RADIUS));
        int p = dp(c, 15);
        l.setPadding(p, p, p, p);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.bottomMargin = dp(c, 11);
        l.setLayoutParams(lp);
        return l;
    }

    static View spacer(Context c, int heightDp) {
        View v = new View(c);
        v.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, heightDp)));
        return v;
    }

    static View divider(Context c) {
        View v = new View(c);
        v.setBackgroundColor(STROKE);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, Math.max(1, dp(c, 1) / 2));
        lp.topMargin = dp(c, 12);
        lp.bottomMargin = dp(c, 12);
        v.setLayoutParams(lp);
        return v;
    }

    static LinearLayout weighted(LinearLayout l, float weight) {
        l.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, weight));
        return l;
    }

    // ------------------------------------------------------------ components

    static ImageView icon(Context c, int drawableRes, int sizeDp, int rightMarginDp) {
        ImageView v = new ImageView(c);
        v.setImageResource(drawableRes);
        v.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                dp(c, sizeDp), dp(c, sizeDp));
        lp.rightMargin = dp(c, rightMarginDp);
        v.setLayoutParams(lp);
        return v;
    }

    /**
     * Section heading: a lime rule, the title, and an optional trailing view.
     * The rule is what keeps sections distinguishable once cards stack up.
     */
    static LinearLayout heading(Context c, String title, View trailing) {
        LinearLayout r = row(c);

        View rule = new View(c);
        rule.setBackground(round(LIME, dp(c, 2)));
        LinearLayout.LayoutParams rl = new LinearLayout.LayoutParams(
                dp(c, 3), dp(c, 13));
        rl.rightMargin = dp(c, 8);
        rule.setLayoutParams(rl);
        r.addView(rule);

        r.addView(weighted(wrap(c, label(c, title, WHITE)), 1f));
        if (trailing != null) {
            r.addView(trailing);
        }
        return r;
    }

    static LinearLayout wrap(Context c, View v) {
        LinearLayout l = column(c);
        l.addView(v);
        return l;
    }

    static TextView chip(Context c, String value, int fg, int bg) {
        TextView t = bold(c, value, 11, fg);
        t.setBackground(round(bg, dp(c, CHIP_RADIUS)));
        t.setPadding(dp(c, 7), dp(c, 4), dp(c, 7), dp(c, 4));
        return t;
    }

    /** A trophy icon followed by its count, the pairing used all over the app. */
    static LinearLayout trophy(Context c, long value, int sp, int color) {
        LinearLayout r = row(c);
        r.addView(icon(c, R.drawable.trophy, sp + 3, 4));
        r.addView(heavy(c, num(value), sp, color));
        return r;
    }

    /**
     * A labelled figure sized to share its row with siblings. Stacking the
     * label over the value keeps long French labels from colliding.
     */
    static LinearLayout tile(Context c, String label, String value, int valueColor) {
        LinearLayout col = column(c);
        col.setBackground(panel(c, CARD_SOFT, STROKE, 9));
        int p = dp(c, 10);
        col.setPadding(p, dp(c, 9), p, dp(c, 9));
        col.addView(label(c, label, MUTED));
        col.addView(spacer(c, 5));
        col.addView(heavy(c, value, 17, valueColor));
        return col;
    }

    /** Lays tiles out in a row with even gaps. */
    static LinearLayout tileRow(Context c, View... tiles) {
        LinearLayout r = row(c);
        for (int i = 0; i < tiles.length; i++) {
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
            if (i > 0) {
                lp.leftMargin = dp(c, 8);
            }
            tiles[i].setLayoutParams(lp);
            r.addView(tiles[i]);
        }
        LinearLayout.LayoutParams outer = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        outer.topMargin = dp(c, 8);
        r.setLayoutParams(outer);
        return r;
    }

    /** Filled track used for meters such as win rate and streaks. */
    static View meter(Context c, float fraction, int color) {
        LinearLayout track = new LinearLayout(c);
        track.setBackground(round(CARD_SOFT, dp(c, 3)));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, 7));
        lp.topMargin = dp(c, 8);
        track.setLayoutParams(lp);

        float f = Math.max(0f, Math.min(1f, fraction));
        View fill = new View(c);
        fill.setBackground(round(color, dp(c, 3)));
        fill.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.MATCH_PARENT, f));
        track.addView(fill);

        if (f < 1f) {
            View rest = new View(c);
            rest.setLayoutParams(new LinearLayout.LayoutParams(
                    0, ViewGroup.LayoutParams.MATCH_PARENT, 1f - f));
            track.addView(rest);
        }
        return track;
    }

    // ----------------------------------------------------------------- utils

    /** 12345 -> "12 345", so big trophy counts stay readable. */
    static String num(long n) {
        String s = String.valueOf(Math.abs(n));
        StringBuilder out = new StringBuilder();
        int count = 0;
        for (int i = s.length() - 1; i >= 0; i--) {
            out.append(s.charAt(i));
            if (++count % 3 == 0 && i > 0) {
                out.append(' ');
            }
        }
        if (n < 0) {
            out.append('-');
        }
        return out.reverse().toString();
    }

    static String signed(long n) {
        return (n > 0 ? "+" : "") + num(n);
    }
}
