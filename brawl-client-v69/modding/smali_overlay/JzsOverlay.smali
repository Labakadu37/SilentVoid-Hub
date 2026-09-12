.class public Lcom/jzs/brawl/JzsOverlay;
.super Ljava/lang/Object;

# JZS Brawl V69.230 - Overlay text injection
# Adds "JZS Brawl V69.230 / Version testing" on top of game view

.method public static inject(Landroid/app/Activity;)V
    .registers 8
    .param p0, "activity"

    # Create a FrameLayout container
    new-instance v0, Landroid/widget/FrameLayout;
    invoke-direct {v0, p0}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    # Create LinearLayout for text block
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    # Padding: 24dp
    const/16 v2, 0x30
    invoke-virtual {v1, v2, v2, v2, v2}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    # --- Title: "JZS Brawl V69.230" ---
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    const-string v4, "JZS Brawl V69.230"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # White color
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V

    # Text size 20sp
    const/high16 v4, 0x41a00000
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V

    # Bold
    const/4 v4, 0x1
    const-string v5, "DEFAULT_BOLD"
    invoke-static {v5}, Landroid/graphics/Typeface;->create(Ljava/lang/String;I)Landroid/graphics/Typeface;
    move-result-object v5
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    # Shadow
    const v4, 0x40400000  # 3.0f radius
    const v5, 0x3f800000  # 1.0f dx
    const v6, 0x3f800000  # 1.0f dy
    const v7, -0x1000000  # black
    invoke-virtual {v3, v4, v5, v6, v7}, Landroid/widget/TextView;->setShadowLayer(FFFI)V

    # Add title to container
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # --- Subtitle: "Version testing" ---
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    const-string v4, "Version testing"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Green color (#00E5A0)
    const v4, -0xff1560
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V

    # Text size 14sp
    const/high16 v4, 0x41600000
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V

    # Shadow
    const v4, 0x40000000  # 2.0f radius
    const v5, 0x3f800000  # 1.0f dx
    const v6, 0x3f800000  # 1.0f dy
    const v7, -0x1000000  # black
    invoke-virtual {v3, v4, v5, v6, v7}, Landroid/widget/TextView;->setShadowLayer(FFFI)V

    # Add subtitle to container
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Add LinearLayout to FrameLayout
    invoke-virtual {v0, v1}, Landroid/widget/FrameLayout;->addView(Landroid/view/View;)V

    # Add overlay to activity's content view
    # Use WindowManager to add on top of everything
    invoke-virtual {p0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v2

    invoke-virtual {v2}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v2

    check-cast v2, Landroid/view/ViewGroup;

    invoke-virtual {v2, v0}, Landroid/view/ViewGroup;->addView(Landroid/view/View;)V

    return-void
.end method
