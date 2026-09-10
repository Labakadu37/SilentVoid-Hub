# ─────────────────────────────────────────────────────────────────────────────
#  JZSOverlay.smali
#  Affiche "JZS Brawl v69.230 - (release)" + "Telegram: t.me/jzbrawl"
#  en texte doré (#FFD700) en haut à gauche de l'écran.
#
#  Injection : appelé depuis l'onStart() de MainActivity (via patch_apk.py)
#      invoke-static {p0}, Lcom/jzsbrawl/JZSOverlay;->setup(Landroid/app/Activity;)V
# ─────────────────────────────────────────────────────────────────────────────

.class public Lcom/jzsbrawl/JZSOverlay;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

# Référence à l'Activity pour créer les vues sur le bon contexte
.field private activity:Landroid/app/Activity;

# ─── Constructeur ─────────────────────────────────────────────────────────────
.method public constructor <init>(Landroid/app/Activity;)V
    .registers 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/jzsbrawl/JZSOverlay;->activity:Landroid/app/Activity;
    return-void
.end method

# ─── Point d'entrée statique appelé depuis MainActivity.onStart ───────────────
.method public static setup(Landroid/app/Activity;)V
    .registers 5

    # Crée une instance de JZSOverlay (qui est un Runnable)
    new-instance v0, Lcom/jzsbrawl/JZSOverlay;
    invoke-direct {v0, p0}, Lcom/jzsbrawl/JZSOverlay;-><init>(Landroid/app/Activity;)V

    # Handler sur le main looper pour exécuter sur l'UI thread
    new-instance v1, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v2
    invoke-direct {v1, v2}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    # postDelayed(runnable, 1500ms) : laisse le jeu se charger d'abord
    const-wide/16 v3, 0x5DC
    invoke-virtual {v1, v0, v3, v4}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method

# ─── run() : crée le layout texte et l'ajoute à la fenêtre ──────────────────
.method public run()V
    .registers 14

    iget-object v0, p0, Lcom/jzsbrawl/JZSOverlay;->activity:Landroid/app/Activity;
    if-eqz v0, :end

    # ── LinearLayout vertical ────────────────────────────────────────────────
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, v0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    # setOrientation(VERTICAL = 1)
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    # setPadding(12, 90, 0, 0) — décalage depuis le haut pour passer sous la barre du jeu
    const/16 v2, 0xC
    const/16 v3, 0x5A
    const/4 v4, 0x0
    const/4 v5, 0x0
    invoke-virtual {v1, v2, v3, v4, v5}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    # setBackgroundColor(TRANSPARENT = 0)
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    # ── Couleur OR : Color.parseColor("#FFD700") ─────────────────────────────
    const-string v2, "#FFD700"
    invoke-static {v2}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v7

    # Couleur noire pour l'ombre
    const-string v2, "#000000"
    invoke-static {v2}, Landroid/graphics/Color;->parseColor(Ljava/lang/String;)I
    move-result v8

    # ── Ligne 1 : "JZS Brawl v69.230 - (release)" ───────────────────────────
    const-string v9, "JZS Brawl v69.230 - (release)"
    invoke-static {v0, v1, v9, v7, v8}, Lcom/jzsbrawl/JZSOverlay;->addLine(Landroid/app/Activity;Landroid/widget/LinearLayout;Ljava/lang/String;II)V

    # ── Ligne 2 : "Telegram: t.me/jzbrawl" ──────────────────────────────────
    const-string v9, "Telegram: t.me/jzbrawl"
    invoke-static {v0, v1, v9, v7, v8}, Lcom/jzsbrawl/JZSOverlay;->addLine(Landroid/app/Activity;Landroid/widget/LinearLayout;Ljava/lang/String;II)V

    # ── LayoutParams : WRAP_CONTENT x WRAP_CONTENT, haut-gauche ─────────────
    new-instance v3, Landroid/view/ViewGroup$LayoutParams;
    const/16 v4, -0x2   # WRAP_CONTENT = -2
    const/16 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/view/ViewGroup$LayoutParams;-><init>(II)V

    # activity.addContentView(layout, params) — pas besoin de permission
    invoke-virtual {v0, v1, v3}, Landroid/app/Activity;->addContentView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    :end
    return-void
.end method

# ─── Helper : crée et ajoute un TextView doré ────────────────────────────────
.method private static addLine(Landroid/app/Activity;Landroid/widget/LinearLayout;Ljava/lang/String;II)V
    .registers 9
    # p0 = activity, p1 = layout, p2 = text, p3 = goldColor, p4 = shadowColor

    new-instance v0, Landroid/widget/TextView;
    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    # setText
    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # setTextColor(gold)
    invoke-virtual {v0, p3}, Landroid/widget/TextView;->setTextColor(I)V

    # setTextSize(13f)
    const/high16 v1, 0x41500000   # 13.0f
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    # setShadowLayer(2f, 1f, 1f, black) — contour noir pour lisibilité
    const/high16 v1, 0x40000000   # 2.0f
    const/high16 v2, 0x3F800000   # 1.0f
    const/high16 v3, 0x3F800000   # 1.0f
    invoke-virtual {v0, v1, v2, v3, p4}, Landroid/widget/TextView;->setShadowLayer(FFFI)V

    # setBackground(null) = fond transparent
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # layout.addView(tv)
    invoke-virtual {p1, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    return-void
.end method
