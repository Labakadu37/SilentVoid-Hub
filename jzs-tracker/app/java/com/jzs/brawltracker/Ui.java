package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Dark palette and the building blocks every screen is assembled from. */
final class Ui {

    static final int BG = Color.parseColor("#000000");
    static final int CARD = Color.parseColor("#16181C");
    static final int CARD_SOFT = Color.parseColor("#1F2329");
    static final int DIVIDER = Color.parseColor("#24282E");

    static final int LIME = Color.parseColor("#C3F53C");
    static final int GOLD = Color.parseColor("#FFC61A");
    static final int WIN = Color.parseColor("#4ADE80");
    static final int LOSS = Color.parseColor("#FF6B6B");
    static final int DRAW = Color.parseColor("#5AB0FF");
    static final int ORANGE = Color.parseColor("#FF9F40");
    static final int PURPLE = Color.parseColor("#B47CFF");
    static final int CYAN = Color.parseColor("#4DD9E8");

    static final int WHITE = Color.parseColor("#FFFFFF");
    static final int MUTED = Color.parseColor("#8E959E");

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

    /** Heavy condensed face — the look the stat numbers and names lean on. */
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

    /** Small tracking-wide uppercase label, as used above each section. */
    static TextView label(Context c, String value, int color) {
        TextView t = text(c, value.toUpperCase(), 12, color);
        t.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        t.setLetterSpacing(0.14f);
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

    static LinearLayout card(Context c) {
        LinearLayout l = column(c);
        l.setBackground(round(CARD, dp(c, 18)));
        int p = dp(c, 18);
        l.setPadding(p, p, p, p);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.bottomMargin = dp(c, 14);
        l.setLayoutParams(lp);
        return l;
    }

    static GradientDrawable round(int color, int radiusPx) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(radiusPx);
        return d;
    }

    static View spacer(Context c, int heightDp) {
        View v = new View(c);
        v.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, heightDp)));
        return v;
    }

    static View divider(Context c) {
        View v = new View(c);
        v.setBackgroundColor(DIVIDER);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, Math.max(1, dp(c, 1) / 2));
        lp.topMargin = dp(c, 14);
        lp.bottomMargin = dp(c, 14);
        v.setLayoutParams(lp);
        return v;
    }

    static LinearLayout weighted(LinearLayout l, float weight) {
        l.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, weight));
        return l;
    }

    // ------------------------------------------------------------ components

    /** Rounded colour chip, e.g. the "P11" power badge. */
    static TextView badge(Context c, String value, int fg, int bg) {
        TextView t = bold(c, value, 12, fg);
        t.setBackground(round(bg, dp(c, 7)));
        t.setPadding(dp(c, 8), dp(c, 4), dp(c, 8), dp(c, 4));
        return t;
    }

    /**
     * One "Label ....... Value" line. Two of these side by side make the
     * two-column grid the tracking panel uses.
     */
    static LinearLayout statLine(Context c, String label, String value, int valueColor) {
        LinearLayout r = row(c);
        r.setPadding(0, dp(c, 6), 0, dp(c, 6));

        TextView l = text(c, label, 14, MUTED);
        r.addView(l, new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        TextView v = heavy(c, value, 16, valueColor);
        r.addView(v);
        return r;
    }

    /** Two stat lines sharing a row, each taking half the width. */
    static LinearLayout statPair(Context c, String l1, String v1, int c1,
                                 String l2, String v2, int c2) {
        LinearLayout r = row(c);
        LinearLayout left = column(c);
        left.addView(statLine(c, l1, v1, c1));
        r.addView(weighted(left, 1f));

        LinearLayout gap = column(c);
        gap.setLayoutParams(new LinearLayout.LayoutParams(dp(c, 18), 1));
        r.addView(gap);

        LinearLayout right = column(c);
        right.addView(statLine(c, l2, v2, c2));
        r.addView(weighted(right, 1f));
        return r;
    }

    /** Filled track used for the win-streak meter. */
    static View meter(Context c, float fraction, int color) {
        LinearLayout track = new LinearLayout(c);
        track.setBackground(round(CARD_SOFT, dp(c, 5)));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, 9));
        lp.topMargin = dp(c, 8);
        track.setLayoutParams(lp);

        View fill = new View(c);
        fill.setBackground(round(color, dp(c, 5)));
        float f = Math.max(0f, Math.min(1f, fraction));
        fill.setLayoutParams(new LinearLayout.LayoutParams(0,
                ViewGroup.LayoutParams.MATCH_PARENT, f));
        track.addView(fill);

        if (f < 1f) {
            View rest = new View(c);
            rest.setLayoutParams(new LinearLayout.LayoutParams(0,
                    ViewGroup.LayoutParams.MATCH_PARENT, 1f - f));
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
