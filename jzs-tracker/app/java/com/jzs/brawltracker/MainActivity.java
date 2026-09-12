package com.jzs.brawltracker;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
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

    private static final int TAB_HOME = 0;
    private static final int TAB_BRAWLERS = 1;
    private static final int TAB_CLUB = 2;
    private static final int TAB_RANKINGS = 3;
    private static final String[] TAB_NAMES = {"Home", "Brawlers", "Club", "Rankings"};

    private SharedPreferences prefs;
    private EditText tagInput;
    private TextView status;
    private LinearLayout content;
    private LinearLayout navBar;

    private int tab = TAB_HOME;
    private String tag = "";
    private JSONObject player;
    private JSONArray battles;
    private JSONObject club;
    private JSONArray rankings;

    @Override
    protected void onCreate(Bundle saved) {
        super.onCreate(saved);
        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        setContentView(buildRoot());

        String last = prefs.getString(KEY_LAST_TAG, "");
        if (!last.isEmpty()) {
            tagInput.setText(last);
            search();
        } else {
            showWelcome();
        }
    }

    // ---------------------------------------------------------------- chrome

    private View buildRoot() {
        LinearLayout root = Ui.column(this);
        root.setBackgroundColor(Ui.BG);

        root.addView(buildTopBar());
        root.addView(buildSearchRow());

        status = Ui.text(this, "", 13, Ui.MUTED);
        status.setPadding(Ui.dp(this, 16), Ui.dp(this, 10), Ui.dp(this, 16), 0);
        status.setVisibility(View.GONE);
        root.addView(status);

        content = Ui.column(this);
        int p = Ui.dp(this, 16);
        content.setPadding(p, Ui.dp(this, 14), p, Ui.dp(this, 20));

        ScrollView scroll = new ScrollView(this);
        scroll.setVerticalScrollBarEnabled(false);
        scroll.addView(content);
        scroll.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
        root.addView(scroll);

        navBar = buildNav();
        root.addView(navBar);
        return root;
    }

    private View buildTopBar() {
        LinearLayout bar = Ui.row(this);
        bar.setPadding(Ui.dp(this, 16), Ui.dp(this, 26), Ui.dp(this, 16), Ui.dp(this, 8));

        TextView logo = Ui.heavy(this, "JZS BRAWL", 22, Ui.LIME);
        logo.setLetterSpacing(0.04f);
        bar.addView(logo, new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        TextView version = Ui.text(this, "V69.230", 11, Ui.MUTED);
        version.setPadding(0, Ui.dp(this, 8), Ui.dp(this, 10), 0);
        bar.addView(version);

        TextView key = Ui.badge(this, "CLE", Ui.MUTED, Ui.CARD);
        key.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                promptForToken();
            }
        });
        bar.addView(key);
        return bar;
    }

    private View buildSearchRow() {
        LinearLayout row = Ui.row(this);
        row.setPadding(Ui.dp(this, 16), Ui.dp(this, 4), Ui.dp(this, 16), Ui.dp(this, 4));

        tagInput = new EditText(this);
        tagInput.setHint("#2Y0VLQR9");
        tagInput.setSingleLine(true);
        tagInput.setTextColor(Ui.WHITE);
        tagInput.setHintTextColor(Ui.MUTED);
        tagInput.setTextSize(15);
        tagInput.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        tagInput.setInputType(InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
        tagInput.setBackground(Ui.round(Ui.CARD, Ui.dp(this, 12)));
        int p = Ui.dp(this, 13);
        tagInput.setPadding(p, p, p, p);
        row.addView(tagInput, new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        TextView go = Ui.heavy(this, "GO", 15, Ui.BG);
        go.setBackground(Ui.round(Ui.LIME, Ui.dp(this, 12)));
        go.setPadding(Ui.dp(this, 20), p, Ui.dp(this, 20), p);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.leftMargin = Ui.dp(this, 8);
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

    private LinearLayout buildNav() {
        LinearLayout nav = Ui.row(this);
        nav.setBackgroundColor(Ui.CARD);
        int p = Ui.dp(this, 6);
        nav.setPadding(p, p, p, p);

        for (int i = 0; i < TAB_NAMES.length; i++) {
            nav.addView(navItem(i));
        }
        return nav;
    }

    private View navItem(final int index) {
        TextView t = Ui.bold(this, TAB_NAMES[index], 13, Ui.MUTED);
        t.setGravity(Gravity.CENTER);
        t.setPadding(0, Ui.dp(this, 11), 0, Ui.dp(this, 11));
        t.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        t.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectTab(index);
            }
        });
        return t;
    }

    private void refreshNav() {
        for (int i = 0; i < navBar.getChildCount(); i++) {
            TextView t = (TextView) navBar.getChildAt(i);
            boolean active = i == tab;
            t.setTextColor(active ? Ui.LIME : Ui.MUTED);
            t.setBackground(active ? Ui.round(Ui.CARD_SOFT, Ui.dp(this, 12)) : null);
        }
    }

    private void selectTab(int index) {
        tab = index;
        refreshNav();
        render();
    }

    // ----------------------------------------------------------------- token

    private String token() {
        return prefs.getString(KEY_TOKEN, Config.DEFAULT_TOKEN).trim();
    }

    private void promptForToken() {
        final EditText field = new EditText(this);
        field.setHint("eyJ0eXAiOiJKV1Qi...");
        field.setTextColor(Color.BLACK);

        new AlertDialog.Builder(this)
                .setTitle("Cle API Brawl Stars")
                .setMessage("Cree une cle sur developer.brawlstars.com avec l'IP "
                        + BrawlApi.PROXY_IP + " autorisee, puis colle-la ici.")
                .setView(field)
                .setPositiveButton("Enregistrer", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface d, int which) {
                        prefs.edit().putString(
                                KEY_TOKEN, field.getText().toString().trim()).apply();
                        setStatus("Cle enregistree.", Ui.LIME);
                    }
                })
                .setNegativeButton("Annuler", null)
                .show();
    }

    // ---------------------------------------------------------------- search

    private void search() {
        final String wanted = BrawlApi.normalizeTag(tagInput.getText().toString());
        if (wanted.isEmpty()) {
            setStatus("Entre un tag de joueur.", Ui.LOSS);
            return;
        }
        if (token().isEmpty()) {
            setStatus("Ajoute ta cle API avec le bouton CLE.", Ui.LOSS);
            return;
        }

        hideKeyboard();
        prefs.edit().putString(KEY_LAST_TAG, wanted).apply();
        tag = wanted;
        player = null;
        battles = null;
        club = null;
        rankings = null;
        content.removeAllViews();
        setStatus("Chargement...", Ui.MUTED);

        final BrawlApi api = new BrawlApi(token());
        api.player(wanted, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                player = body;
                setStatus("", Ui.MUTED);
                render();
                api.battlelog(tag, new BrawlApi.Callback() {
                    @Override
                    public void onSuccess(JSONObject log) {
                        battles = log.optJSONArray("items");
                        render();
                    }

                    @Override
                    public void onError(String message) {
                        render();
                    }
                });
            }

            @Override
            public void onError(String message) {
                content.removeAllViews();
                setStatus(message, Ui.LOSS);
            }
        });
    }

    private void loadClub() {
        JSONObject c = player == null ? null : player.optJSONObject("club");
        String clubTag = c == null ? "" : c.optString("tag", "");
        if (clubTag.isEmpty()) {
            return;
        }
        new BrawlApi(token()).club(clubTag, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                club = body;
                if (tab == TAB_CLUB) {
                    render();
                }
            }

            @Override
            public void onError(String message) {
                setStatus(message, Ui.LOSS);
            }
        });
    }

    private void loadRankings() {
        new BrawlApi(token()).globalPlayers(new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                rankings = body.optJSONArray("items");
                if (tab == TAB_RANKINGS) {
                    render();
                }
            }

            @Override
            public void onError(String message) {
                setStatus(message, Ui.LOSS);
            }
        });
    }

    // ---------------------------------------------------------------- render

    private void render() {
        content.removeAllViews();
        refreshNav();

        if (player == null) {
            showWelcome();
            return;
        }
        switch (tab) {
            case TAB_BRAWLERS:
                renderBrawlersTab();
                break;
            case TAB_CLUB:
                renderClubTab();
                break;
            case TAB_RANKINGS:
                renderRankingsTab();
                break;
            default:
                renderHomeTab();
        }
    }

    private void showWelcome() {
        content.removeAllViews();
        LinearLayout card = Ui.card(this);
        card.addView(Ui.label(this, "Bienvenue", Ui.LIME));
        card.addView(Ui.spacer(this, 10));
        card.addView(Ui.heavy(this, "Cherche un joueur", 22, Ui.WHITE));
        card.addView(Ui.spacer(this, 8));
        card.addView(Ui.text(this,
                "Entre un tag de joueur en haut, par exemple #2Y0VLQR9, "
                        + "puis appuie sur GO.", 14, Ui.MUTED));
        content.addView(card);
        refreshNav();
    }

    private void renderHomeTab() {
        content.addView(profileCard());

        if (battles != null) {
            content.addView(trackingCard(Stats.from(battles, tag)));
        }
        JSONObject top = topBrawler();
        if (top != null) {
            content.addView(heroBrawlerCard(top));
        }
        if (battles != null) {
            content.addView(battlesCard());
        }
    }

    private View profileCard() {
        LinearLayout card = Ui.card(this);

        LinearLayout head = Ui.row(this);
        LinearLayout names = Ui.column(this);
        names.addView(Ui.heavy(this, player.optString("name", "?").toUpperCase(), 26, Ui.WHITE));
        names.addView(Ui.text(this, player.optString("tag", ""), 13, Ui.MUTED));
        head.addView(Ui.weighted(names, 1f));

        LinearLayout trophyBox = Ui.column(this);
        trophyBox.setGravity(Gravity.END);
        trophyBox.addView(Ui.heavy(this, Ui.num(player.optLong("trophies")), 26, Ui.GOLD));
        TextView max = Ui.text(this, "max " + Ui.num(player.optLong("highestTrophies")),
                11, Ui.MUTED);
        max.setGravity(Gravity.END);
        trophyBox.addView(max);
        head.addView(trophyBox);
        card.addView(head);

        JSONObject c = player.optJSONObject("club");
        String clubName = c == null ? "" : c.optString("name", "");
        if (!clubName.isEmpty()) {
            TextView club = Ui.bold(this, clubName, 14, Ui.LIME);
            club.setPadding(0, Ui.dp(this, 10), 0, 0);
            card.addView(club);
        }

        card.addView(Ui.divider(this));
        card.addView(Ui.statPair(this,
                "Niveau", String.valueOf(player.optInt("expLevel")), Ui.WHITE,
                "Brawlers", String.valueOf(brawlerList().size()), Ui.WHITE));
        card.addView(Ui.statPair(this,
                "Victoires 3v3", Ui.num(player.optLong("3vs3Victories")), Ui.WIN,
                "Solo", Ui.num(player.optLong("soloVictories")), Ui.WIN));
        card.addView(Ui.statPair(this,
                "Duo", Ui.num(player.optLong("duoVictories")), Ui.WIN,
                "Record", Ui.num(player.optLong("highestTrophies")), Ui.GOLD));
        return card;
    }

    private View trackingCard(Stats s) {
        LinearLayout card = Ui.card(this);

        LinearLayout head = Ui.row(this);
        head.addView(Ui.label(this, "Tracking", Ui.LIME));
        TextView scope = Ui.badge(this,
                "DERNIERS " + s.battles + " COMBATS", Ui.MUTED, Ui.CARD_SOFT);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.leftMargin = Ui.dp(this, 10);
        scope.setLayoutParams(lp);
        head.addView(scope);
        card.addView(head);
        card.addView(Ui.spacer(this, 12));

        card.addView(Ui.statPair(this,
                "Combats", String.valueOf(s.battles), Ui.WHITE,
                "Win Rate", s.winRate() + "%", s.winRate() >= 50 ? Ui.WIN : Ui.LOSS));
        card.addView(Ui.statPair(this,
                "Victoires", String.valueOf(s.wins), Ui.WIN,
                "Defaites", String.valueOf(s.losses), Ui.LOSS));
        card.addView(Ui.statPair(this,
                "Nuls", String.valueOf(s.draws), Ui.DRAW,
                "Star Player", String.valueOf(s.starPlayer), Ui.ORANGE));
        card.addView(Ui.statPair(this,
                "Brawlers joues", String.valueOf(s.brawlersUsed.size()), Ui.PURPLE,
                "Serie", s.streak + "V", Ui.CYAN));

        card.addView(Ui.divider(this));
        card.addView(Ui.statPair(this,
                "Trophees gagnes", Ui.signed(s.trophiesWon), Ui.WIN,
                "Trophees perdus", "-" + Ui.num(s.trophiesLost), Ui.LOSS));
        card.addView(Ui.statLine(this, "Bilan", Ui.signed(s.trophyNet()),
                s.trophyNet() >= 0 ? Ui.WIN : Ui.LOSS));
        return card;
    }

    /** The full-detail card the screenshot leads with, for the top brawler. */
    private View heroBrawlerCard(JSONObject b) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.label(this, "Meilleur brawler", Ui.LIME));
        card.addView(Ui.spacer(this, 14));
        card.addView(brawlerHeader(b, 64));

        JSONArray stars = b.optJSONArray("starPowers");
        JSONArray gadgets = b.optJSONArray("gadgets");
        JSONArray gears = b.optJSONArray("gears");
        card.addView(Ui.spacer(this, 14));
        LinearLayout slots = Ui.row(this);
        slots.addView(slotGroup("Star Powers", count(stars), 2, Ui.GOLD));
        slots.addView(slotGroup("Gadgets", count(gadgets), 2, Ui.WIN));
        slots.addView(slotGroup("Gears", count(gears), 6, Ui.DRAW));
        card.addView(slots);

        int current = b.optInt("currentWinStreak");
        int best = Math.max(b.optInt("maxWinStreak"), 1);
        card.addView(Ui.divider(this));
        LinearLayout streakRow = Ui.row(this);
        streakRow.addView(Ui.weighted(wrap(Ui.bold(this, "Serie en cours", 14, Ui.GOLD)), 1f));
        streakRow.addView(Ui.heavy(this, current + "/" + best, 15, Ui.GOLD));
        card.addView(streakRow);
        card.addView(Ui.meter(this, current / (float) best, Ui.GOLD));
        return card;
    }

    private LinearLayout wrap(View v) {
        LinearLayout l = Ui.column(this);
        l.addView(v);
        return l;
    }

    private static int count(JSONArray a) {
        return a == null ? 0 : a.length();
    }

    /** Owned-vs-empty pips, mirroring the unlock rows in the reference design. */
    private View slotGroup(String title, int owned, int total, int color) {
        LinearLayout col = Ui.column(this);
        col.addView(Ui.text(this, title, 11, Ui.MUTED));
        col.addView(Ui.spacer(this, 6));

        LinearLayout pips = Ui.row(this);
        for (int i = 0; i < total; i++) {
            View pip = new View(this);
            pip.setBackground(Ui.round(i < owned ? color : Ui.CARD_SOFT, Ui.dp(this, 5)));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    Ui.dp(this, 10), Ui.dp(this, 10));
            lp.rightMargin = Ui.dp(this, 5);
            pip.setLayoutParams(lp);
            pips.addView(pip);
        }
        col.addView(pips);
        return Ui.weighted(col, 1f);
    }

    /** Portrait, name, power badge, skin and trophies — the shared brawler row. */
    private View brawlerHeader(JSONObject b, int portraitDp) {
        LinearLayout row = Ui.row(this);

        ImageView portrait = new ImageView(this);
        portrait.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams ip = new LinearLayout.LayoutParams(
                Ui.dp(this, portraitDp), Ui.dp(this, portraitDp));
        ip.rightMargin = Ui.dp(this, 12);
        portrait.setLayoutParams(ip);
        portrait.setBackground(Ui.round(Ui.CARD_SOFT, Ui.dp(this, 12)));
        ImageLoader.brawler(portrait, b.optInt("id"));
        row.addView(portrait);

        LinearLayout info = Ui.column(this);
        LinearLayout nameRow = Ui.row(this);
        nameRow.addView(Ui.heavy(this,
                b.optString("name", "?").toUpperCase(), portraitDp >= 64 ? 21 : 17, Ui.WHITE));
        TextView power = Ui.badge(this, "P" + b.optInt("power"), Ui.BG, Ui.LIME);
        LinearLayout.LayoutParams pl = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        pl.leftMargin = Ui.dp(this, 8);
        power.setLayoutParams(pl);
        nameRow.addView(power);
        info.addView(nameRow);

        JSONObject skin = b.optJSONObject("skin");
        String skinName = skin == null ? "" : skin.optString("name", "");
        LinearLayout sub = Ui.row(this);
        if (!skinName.isEmpty()) {
            sub.addView(Ui.bold(this, MainActivity.pretty(skinName), 12, Ui.DRAW));
            TextView dot = Ui.text(this, "  •  ", 12, Ui.MUTED);
            sub.addView(dot);
        }
        sub.addView(Ui.text(this, "Rang " + b.optInt("rank"), 12, Ui.MUTED));
        info.addView(sub);
        row.addView(Ui.weighted(info, 1f));

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.heavy(this, Ui.num(b.optLong("trophies")),
                portraitDp >= 64 ? 22 : 18, Ui.GOLD));
        TextView max = Ui.text(this, "max " + Ui.num(b.optLong("highestTrophies")),
                11, Ui.MUTED);
        max.setGravity(Gravity.END);
        right.addView(max);
        row.addView(right);
        return row;
    }

    private View battlesCard() {
        LinearLayout card = Ui.card(this);
        Stats s = Stats.from(battles, tag);

        LinearLayout head = Ui.row(this);
        head.addView(Ui.weighted(wrap(Ui.label(this, "Combats", Ui.MUTED)), 1f));
        head.addView(Ui.heavy(this, s.wins + "W", 15, Ui.WIN));
        TextView gap = Ui.text(this, "  ", 15, Ui.MUTED);
        head.addView(gap);
        head.addView(Ui.heavy(this, s.losses + "L", 15, Ui.LOSS));
        card.addView(head);
        card.addView(Ui.spacer(this, 6));

        int limit = Math.min(battles.length(), 25);
        for (int i = 0; i < limit; i++) {
            JSONObject entry = battles.optJSONObject(i);
            if (entry != null) {
                card.addView(battleRow(entry));
            }
        }
        return card;
    }

    private View battleRow(JSONObject entry) {
        JSONObject battle = entry.optJSONObject("battle");
        JSONObject event = entry.optJSONObject("event");

        String mode = pretty(event != null && !event.optString("mode").isEmpty()
                ? event.optString("mode")
                : (battle == null ? "?" : battle.optString("mode", "?")));
        String map = event == null ? "" : event.optString("map", "");

        String outcome = "-";
        int outcomeColor = Ui.MUTED;
        if (battle != null) {
            if (battle.has("result")) {
                String r = battle.optString("result");
                if ("victory".equals(r)) {
                    outcome = "Victoire";
                    outcomeColor = Ui.WIN;
                } else if ("defeat".equals(r)) {
                    outcome = "Defaite";
                    outcomeColor = Ui.LOSS;
                } else {
                    outcome = "Nul";
                    outcomeColor = Ui.DRAW;
                }
            } else if (battle.has("rank")) {
                int rank = battle.optInt("rank");
                outcome = "Rang " + rank;
                outcomeColor = rank <= 4 ? Ui.WIN : Ui.LOSS;
            }
        }

        LinearLayout row = Ui.row(this);
        row.setPadding(0, Ui.dp(this, 9), 0, Ui.dp(this, 9));

        LinearLayout left = Ui.column(this);
        left.addView(Ui.bold(this, mode, 15, Ui.WHITE));
        if (!map.isEmpty()) {
            left.addView(Ui.text(this, map, 12, Ui.MUTED));
        }
        row.addView(Ui.weighted(left, 1f));

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.bold(this, outcome, 14, outcomeColor));
        int change = battle == null ? 0 : battle.optInt("trophyChange");
        if (change != 0) {
            TextView delta = Ui.heavy(this, Ui.signed(change), 12,
                    change > 0 ? Ui.WIN : Ui.LOSS);
            delta.setGravity(Gravity.END);
            right.addView(delta);
        }
        row.addView(right);
        return row;
    }

    // ------------------------------------------------------------ other tabs

    private void renderBrawlersTab() {
        List<JSONObject> list = brawlerList();
        LinearLayout header = Ui.card(this);
        LinearLayout head = Ui.row(this);
        head.addView(Ui.weighted(wrap(Ui.label(this, "Brawlers", Ui.LIME)), 1f));
        head.addView(Ui.heavy(this, String.valueOf(list.size()), 18, Ui.WHITE));
        header.addView(head);
        content.addView(header);

        for (JSONObject b : list) {
            LinearLayout card = Ui.card(this);
            card.setPadding(Ui.dp(this, 14), Ui.dp(this, 12),
                    Ui.dp(this, 14), Ui.dp(this, 12));
            card.addView(brawlerHeader(b, 46));
            content.addView(card);
        }
    }

    private void renderClubTab() {
        JSONObject c = player.optJSONObject("club");
        String clubTag = c == null ? "" : c.optString("tag", "");
        if (clubTag.isEmpty()) {
            content.addView(emptyCard("Aucun club", "Ce joueur n'est dans aucun club."));
            return;
        }
        if (club == null) {
            content.addView(emptyCard(c.optString("name", "Club"), "Chargement..."));
            loadClub();
            return;
        }

        LinearLayout card = Ui.card(this);
        card.addView(Ui.label(this, "Club", Ui.LIME));
        card.addView(Ui.spacer(this, 10));
        card.addView(Ui.heavy(this, club.optString("name", "?").toUpperCase(), 24, Ui.WHITE));
        card.addView(Ui.text(this, club.optString("tag", ""), 13, Ui.MUTED));

        String desc = club.optString("description", "");
        if (!desc.isEmpty()) {
            TextView d = Ui.text(this, desc, 13, Ui.MUTED);
            d.setPadding(0, Ui.dp(this, 10), 0, 0);
            card.addView(d);
        }
        card.addView(Ui.divider(this));
        JSONArray members = club.optJSONArray("members");
        card.addView(Ui.statPair(this,
                "Trophees", Ui.num(club.optLong("trophies")), Ui.GOLD,
                "Requis", Ui.num(club.optLong("requiredTrophies")), Ui.WHITE));
        card.addView(Ui.statPair(this,
                "Membres", (members == null ? 0 : members.length()) + "/30", Ui.WHITE,
                "Type", pretty(club.optString("type", "")), Ui.DRAW));
        content.addView(card);

        if (members == null) {
            return;
        }
        LinearLayout list = Ui.card(this);
        list.addView(Ui.label(this, "Membres", Ui.MUTED));
        list.addView(Ui.spacer(this, 6));
        for (int i = 0; i < members.length(); i++) {
            JSONObject m = members.optJSONObject(i);
            if (m == null) {
                continue;
            }
            LinearLayout row = Ui.row(this);
            row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));
            row.addView(Ui.heavy(this, String.valueOf(i + 1), 13, Ui.MUTED));
            LinearLayout info = Ui.column(this);
            info.setPadding(Ui.dp(this, 12), 0, 0, 0);
            info.addView(Ui.bold(this, m.optString("name", "?"), 15, Ui.WHITE));
            info.addView(Ui.text(this, pretty(m.optString("role", "")), 11, Ui.MUTED));
            row.addView(Ui.weighted(info, 1f));
            row.addView(Ui.heavy(this, Ui.num(m.optLong("trophies")), 15, Ui.GOLD));
            list.addView(row);
        }
        content.addView(list);
    }

    private void renderRankingsTab() {
        if (rankings == null) {
            content.addView(emptyCard("Classement mondial", "Chargement..."));
            loadRankings();
            return;
        }
        LinearLayout card = Ui.card(this);
        card.addView(Ui.label(this, "Top mondial", Ui.LIME));
        card.addView(Ui.spacer(this, 6));

        for (int i = 0; i < rankings.length(); i++) {
            JSONObject p = rankings.optJSONObject(i);
            if (p == null) {
                continue;
            }
            LinearLayout row = Ui.row(this);
            row.setPadding(0, Ui.dp(this, 9), 0, Ui.dp(this, 9));

            int rank = p.optInt("rank", i + 1);
            TextView pos = Ui.heavy(this, String.valueOf(rank), 15,
                    rank <= 3 ? Ui.GOLD : Ui.MUTED);
            pos.setWidth(Ui.dp(this, 34));
            row.addView(pos);

            LinearLayout info = Ui.column(this);
            info.addView(Ui.bold(this, p.optString("name", "?"), 15, Ui.WHITE));
            JSONObject pc = p.optJSONObject("club");
            String cn = pc == null ? "" : pc.optString("name", "");
            info.addView(Ui.text(this, cn.isEmpty() ? p.optString("tag", "") : cn,
                    11, Ui.MUTED));
            row.addView(Ui.weighted(info, 1f));

            row.addView(Ui.heavy(this, Ui.num(p.optLong("trophies")), 15, Ui.GOLD));
            card.addView(row);
        }
        content.addView(card);
    }

    private View emptyCard(String title, String body) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heavy(this, title.toUpperCase(), 20, Ui.WHITE));
        card.addView(Ui.spacer(this, 8));
        card.addView(Ui.text(this, body, 14, Ui.MUTED));
        return card;
    }

    // --------------------------------------------------------------- helpers

    private List<JSONObject> brawlerList() {
        List<JSONObject> list = new ArrayList<>();
        JSONArray arr = player == null ? null : player.optJSONArray("brawlers");
        if (arr == null) {
            return list;
        }
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
        return list;
    }

    private JSONObject topBrawler() {
        List<JSONObject> list = brawlerList();
        return list.isEmpty() ? null : list.get(0);
    }

    /** "gemGrab" -> "Gem Grab", "SHELLY" -> "Shelly". */
    static String pretty(String raw) {
        if (raw == null || raw.isEmpty()) {
            return "";
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
