package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

/** Small builders so screens can be assembled without layout XML. */
final class Ui {

    static final int BG = Color.parseColor("#0B0F14");
    static final int SURFACE = Color.parseColor("#141A21");
    static final int ACCENT = Color.parseColor("#00E5A0");
    static final int TEXT = Color.parseColor("#ECF1F5");
    static final int MUTED = Color.parseColor("#8A97A5");
    static final int DANGER = Color.parseColor("#FF6B6B");

    private Ui() {
    }

    static int dp(Context c, int value) {
        return Math.round(TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, value, c.getResources().getDisplayMetrics()));
    }

    static TextView text(Context c, String value, int size, int color, boolean bold) {
        TextView t = new TextView(c);
        t.setText(value);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, size);
        t.setTextColor(color);
        if (bold) {
            t.setTypeface(t.getTypeface(), android.graphics.Typeface.BOLD);
        }
        return t;
    }

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
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(SURFACE);
        bg.setCornerRadius(dp(c, 14));
        l.setBackground(bg);
        int p = dp(c, 16);
        l.setPadding(p, p, p, p);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.bottomMargin = dp(c, 12);
        l.setLayoutParams(lp);
        return l;
    }

    static GradientDrawable pill(Context c, int color, int radiusDp) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(dp(c, radiusDp));
        return d;
    }

    /** A label above a value, sized to share a row equally with its siblings. */
    static LinearLayout stat(Context c, String label, String value) {
        LinearLayout col = column(c);
        col.addView(text(c, label, 11, MUTED, false));
        TextView v = text(c, value, 17, TEXT, true);
        v.setPadding(0, dp(c, 2), 0, 0);
        col.addView(v);
        LinearLayout.LayoutParams lp =
                new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        col.setLayoutParams(lp);
        return col;
    }

    static View spacer(Context c, int heightDp) {
        View v = new View(c);
        v.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(c, heightDp)));
        return v;
    }

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
}
