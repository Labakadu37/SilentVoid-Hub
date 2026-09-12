package com.jzs.brawltracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class MainActivity extends Activity {

    private static final String PREFS = "jzs";
    private static final String KEY_TOKEN = "token";
    private static final String KEY_LAST_TAG = "last_tag";

    private SharedPreferences prefs;
    private EditText tagInput;
    private TextView status;
    private LinearLayout results;

    @Override
    protected void onCreate(Bundle saved) {
        super.onCreate(saved);
        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        setContentView(buildRoot());

        String last = prefs.getString(KEY_LAST_TAG, "");
        if (!last.isEmpty()) {
            tagInput.setText(last);
        }
        if (token().isEmpty()) {
            showSetupCard();
        }
    }

    // ---------------------------------------------------------------- layout

    private View buildRoot() {
        LinearLayout root = Ui.column(this);
        root.setBackgroundColor(Ui.BG);
        int pad = Ui.dp(this, 16);
        root.setPadding(pad, Ui.dp(this, 28), pad, 0);

        root.addView(buildHeader());
        root.addView(Ui.spacer(this, 18));
        root.addView(buildSearchRow());

        status = Ui.text(this, "", 13, Ui.MUTED, false);
        status.setPadding(0, Ui.dp(this, 12), 0, 0);
        status.setVisibility(View.GONE);
        root.addView(status);

        results = Ui.column(this);
        results.setPadding(0, Ui.dp(this, 16), 0, 0);

        ScrollView scroll = new ScrollView(this);
        scroll.setVerticalScrollBarEnabled(false);
        scroll.addView(results);
        scroll.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
        root.addView(scroll);
        return root;
    }

    private View buildHeader() {
        LinearLayout row = Ui.row(this);

        LinearLayout titles = Ui.column(this);
        titles.addView(Ui.text(this, getString(R.string.brand), 20, Ui.TEXT, true));
        TextView sub = Ui.text(this, getString(R.string.tagline), 12, Ui.ACCENT, false);
        sub.setPadding(0, Ui.dp(this, 2), 0, 0);
        titles.addView(sub);
        titles.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        row.addView(titles);

        TextView key = Ui.text(this, "Cle API", 12, Ui.TEXT, true);
        key.setBackground(Ui.pill(this, Ui.SURFACE, 18));
        int h = Ui.dp(this, 10);
        key.setPadding(Ui.dp(this, 14), h, Ui.dp(this, 14), h);
        key.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                promptForToken();
            }
        });
        row.addView(key);
        return row;
    }

    private View buildSearchRow() {
        LinearLayout row = Ui.row(this);

        tagInput = new EditText(this);
        tagInput.setHint("#2Y0VLQR9");
        tagInput.setSingleLine(true);
        tagInput.setTextColor(Ui.TEXT);
        tagInput.setHintTextColor(Ui.MUTED);
        tagInput.setTextSize(16);
        tagInput.setInputType(InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
        tagInput.setBackground(Ui.pill(this, Ui.SURFACE, 12));
        int p = Ui.dp(this, 14);
        tagInput.setPadding(p, p, p, p);
        tagInput.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        row.addView(tagInput);

        Button go = new Button(this);
        go.setText("Chercher");
        go.setAllCaps(false);
        go.setTextColor(Ui.BG);
        go.setBackground(Ui.pill(this, Ui.ACCENT, 12));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.leftMargin = Ui.dp(this, 10);
        go.setLayoutParams(lp);
        go.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                search();
            }
        });
        row.addView(go);
        return row;
    }

    // ----------------------------------------------------------------- token

    private String token() {
        return prefs.getString(KEY_TOKEN, Config.DEFAULT_TOKEN).trim();
    }

    private void promptForToken() {
        final EditText field = new EditText(this);
        field.setHint("eyJ0eXAiOiJKV1Qi...");
        field.setText(prefs.getString(KEY_TOKEN, ""));
        field.setTextColor(Color.BLACK);

        new AlertDialog.Builder(this)
                .setTitle("Cle API Brawl Stars")
                .setMessage("Cree une cle sur developer.brawlstars.com en mettant "
                        + BrawlApi.PROXY_IP + " comme IP autorisee, puis colle-la ici.")
                .setView(field)
                .setPositiveButton("Enregistrer", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface d, int which) {
                        prefs.edit().putString(KEY_TOKEN, field.getText().toString().trim()).apply();
                        results.removeAllViews();
                        setStatus("Cle enregistree.", Ui.ACCENT);
                    }
                })
                .setNegativeButton("Annuler", null)
                .show();
    }

    private void showSetupCard() {
        results.removeAllViews();
        LinearLayout card = Ui.card(this);
        card.addView(Ui.text(this, "Configuration requise", 16, Ui.TEXT, true));
        card.addView(Ui.spacer(this, 8));
        card.addView(Ui.text(this,
                "1. Va sur developer.brawlstars.com et cree un compte\n"
                        + "2. Cree une cle API avec l'IP " + BrawlApi.PROXY_IP + "\n"
                        + "3. Appuie sur \"Cle API\" en haut et colle-la",
                13, Ui.MUTED, false));
        card.addView(Ui.spacer(this, 12));
        card.addView(Ui.text(this,
                "Cette IP est celle du proxy RoyaleAPI. Elle est fixe, donc la meme cle "
                        + "marche depuis n'importe quel telephone.", 12, Ui.MUTED, false));
        results.addView(card);
    }

    // ---------------------------------------------------------------- search

    private void search() {
        final String tag = BrawlApi.normalizeTag(tagInput.getText().toString());
        if (tag.isEmpty()) {
            setStatus("Entre un tag de joueur.", Ui.DANGER);
            return;
        }
        if (token().isEmpty()) {
            showSetupCard();
            setStatus("Ajoute d'abord ta cle API.", Ui.DANGER);
            return;
        }

        hideKeyboard();
        prefs.edit().putString(KEY_LAST_TAG, tag).apply();
        results.removeAllViews();
        setStatus("Chargement...", Ui.MUTED);

        final BrawlApi api = new BrawlApi(token());
        api.player(tag, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject player) {
                setStatus("", Ui.MUTED);
                results.removeAllViews();
                renderProfile(player);
                renderBrawlers(player.optJSONArray("brawlers"));
                loadBattles(api, tag);
            }

            @Override
            public void onError(String message) {
                results.removeAllViews();
                setStatus(message, Ui.DANGER);
            }
        });
    }

    private void loadBattles(BrawlApi api, String tag) {
        final LinearLayout card = Ui.card(this);
        card.addView(Ui.text(this, "DERNIERS COMBATS", 11, Ui.MUTED, true));
        card.addView(Ui.spacer(this, 10));
        final TextView loading = Ui.text(this, "Chargement...", 13, Ui.MUTED, false);
        card.addView(loading);
        results.addView(card);

        api.battlelog(tag, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                card.removeView(loading);
                JSONArray items = body.optJSONArray("items");
                if (items == null || items.length() == 0) {
                    card.addView(Ui.text(MainActivity.this,
                            "Aucun combat recent.", 13, Ui.MUTED, false));
                    return;
                }
                int limit = Math.min(items.length(), 25);
                for (int i = 0; i < limit; i++) {
                    JSONObject entry = items.optJSONObject(i);
                    if (entry != null) {
                        card.addView(battleRow(entry));
                    }
                }
            }

            @Override
            public void onError(String message) {
                card.removeView(loading);
                card.addView(Ui.text(MainActivity.this, message, 13, Ui.DANGER, false));
            }
        });
    }

    // --------------------------------------------------------------- render

    private void renderProfile(JSONObject p) {
        LinearLayout card = Ui.card(this);

        card.addView(Ui.text(this, p.optString("name", "?"), 24, Ui.TEXT, true));
        card.addView(Ui.text(this, p.optString("tag", ""), 13, Ui.MUTED, false));

        JSONObject club = p.optJSONObject("club");
        String clubName = club == null ? "" : club.optString("name", "");
        if (!clubName.isEmpty()) {
            TextView c = Ui.text(this, "Club  " + clubName, 13, Ui.ACCENT, false);
            c.setPadding(0, Ui.dp(this, 6), 0, 0);
            card.addView(c);
        }

        card.addView(Ui.spacer(this, 16));

        LinearLayout trophies = Ui.row(this);
        trophies.addView(Ui.stat(this, "TROPHEES", Ui.num(p.optLong("trophies"))));
        trophies.addView(Ui.stat(this, "RECORD", Ui.num(p.optLong("highestTrophies"))));
        trophies.addView(Ui.stat(this, "NIVEAU", String.valueOf(p.optInt("expLevel"))));
        card.addView(trophies);

        card.addView(Ui.spacer(this, 14));

        LinearLayout wins = Ui.row(this);
        wins.addView(Ui.stat(this, "VICTOIRES 3v3", Ui.num(p.optLong("3vs3Victories"))));
        wins.addView(Ui.stat(this, "SOLO", Ui.num(p.optLong("soloVictories"))));
        wins.addView(Ui.stat(this, "DUO", Ui.num(p.optLong("duoVictories"))));
        card.addView(wins);

        results.addView(card);
    }

    private void renderBrawlers(JSONArray arr) {
        if (arr == null || arr.length() == 0) {
            return;
        }
        List<JSONObject> list = new ArrayList<>();
        for (int i = 0; i < arr.length(); i++) {
            JSONObject b = arr.optJSONObject(i);
            if (b != null) {
                list.add(b);
            }
        }
        Collections.sort(list, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject a, JSONObject b) {
                return b.optInt("trophies") - a.optInt("trophies");
            }
        });

        LinearLayout card = Ui.card(this);
        card.addView(Ui.text(this, "BRAWLERS  (" + list.size() + ")", 11, Ui.MUTED, true));
        card.addView(Ui.spacer(this, 10));
        for (JSONObject b : list) {
            card.addView(brawlerRow(b));
        }
        results.addView(card);
    }

    private View brawlerRow(JSONObject b) {
        LinearLayout row = Ui.row(this);
        row.setPadding(0, Ui.dp(this, 7), 0, Ui.dp(this, 7));

        LinearLayout left = Ui.column(this);
        left.addView(Ui.text(this, pretty(b.optString("name", "?")), 14, Ui.TEXT, true));
        left.addView(Ui.text(this,
                "Puissance " + b.optInt("power") + "   Rang " + b.optInt("rank"),
                11, Ui.MUTED, false));
        left.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        row.addView(left);

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.text(this, Ui.num(b.optLong("trophies")), 15, Ui.ACCENT, true));
        right.addView(Ui.text(this,
                "max " + Ui.num(b.optLong("highestTrophies")), 11, Ui.MUTED, false));
        row.addView(right);
        return row;
    }

    private View battleRow(JSONObject entry) {
        JSONObject battle = entry.optJSONObject("battle");
        JSONObject event = entry.optJSONObject("event");

        String mode = pretty(event != null && !event.optString("mode").isEmpty()
                ? event.optString("mode")
                : (battle == null ? "?" : battle.optString("mode", "?")));
        String map = event == null ? "" : event.optString("map", "");

        String outcome;
        int outcomeColor;
        if (battle == null) {
            outcome = "?";
            outcomeColor = Ui.MUTED;
        } else if (battle.has("result")) {
            String r = battle.optString("result");
            if ("victory".equals(r)) {
                outcome = "Victoire";
                outcomeColor = Ui.ACCENT;
            } else if ("defeat".equals(r)) {
                outcome = "Defaite";
                outcomeColor = Ui.DANGER;
            } else {
                outcome = "Egalite";
                outcomeColor = Ui.MUTED;
            }
        } else if (battle.has("rank")) {
            int rank = battle.optInt("rank");
            outcome = "Rang " + rank;
            outcomeColor = rank <= 4 ? Ui.ACCENT : Ui.MUTED;
        } else {
            outcome = "-";
            outcomeColor = Ui.MUTED;
        }

        LinearLayout row = Ui.row(this);
        row.setPadding(0, Ui.dp(this, 7), 0, Ui.dp(this, 7));

        LinearLayout left = Ui.column(this);
        left.addView(Ui.text(this, mode, 14, Ui.TEXT, true));
        if (!map.isEmpty()) {
            left.addView(Ui.text(this, map, 11, Ui.MUTED, false));
        }
        left.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        row.addView(left);

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.text(this, outcome, 14, outcomeColor, true));
        int change = battle == null ? 0 : battle.optInt("trophyChange");
        if (change != 0) {
            right.addView(Ui.text(this, (change > 0 ? "+" : "") + change,
                    11, change > 0 ? Ui.ACCENT : Ui.DANGER, false));
        }
        row.addView(right);
        return row;
    }

    // --------------------------------------------------------------- helpers

    /** "gemGrab" -> "Gem Grab", "SHELLY" -> "Shelly". */
    static String pretty(String raw) {
        if (raw == null || raw.isEmpty()) {
            return "?";
        }
        String s = raw.replace('_', ' ');
        StringBuilder out = new StringBuilder();
        boolean newWord = true;
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            boolean boundary = i > 0 && Character.isUpperCase(ch)
                    && Character.isLowerCase(s.charAt(i - 1));
            if (boundary) {
                out.append(' ');
                newWord = true;
            }
            if (ch == ' ') {
                out.append(ch);
                newWord = true;
            } else {
                out.append(newWord ? Character.toUpperCase(ch) : Character.toLowerCase(ch));
                newWord = false;
            }
        }
        return out.toString();
    }

    private void setStatus(String message, int color) {
        if (message == null || message.isEmpty()) {
            status.setVisibility(View.GONE);
            return;
        }
        status.setText(message);
        status.setTextColor(color);
        status.setVisibility(View.VISIBLE);
    }

    private void hideKeyboard() {
        InputMethodManager imm =
                (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null && getCurrentFocus() != null) {
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
    }
}
