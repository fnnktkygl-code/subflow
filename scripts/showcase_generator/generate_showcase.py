import os
import subprocess

OUTPUT_DIR = "/Users/richard/Developer/subflow/apps/web/public/showcase"
CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs("/tmp/subflow_cards", exist_ok=True)

COMMON_CSS = """
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Segoe UI", Roboto, sans-serif;
  -webkit-font-smoothing: antialiased;
}
.font-serif { font-family: Georgia, "Times New Roman", serif; font-style: italic; }

/* Phone Mockup Frame */
.phone-chassis {
  width: 320px;
  height: 640px;
  background: #1B3B2F;
  border-radius: 44px;
  padding: 10px;
  box-shadow: 0 35px 80px -15px rgba(27, 59, 47, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.1);
  border: 2px solid rgba(255, 255, 255, 0.2);
  display: flex;
  flex-direction: column;
  position: relative;
  flex-shrink: 0;
}
.phone-notch {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 18px 6px;
  color: #F5EFE6;
  font-size: 11px;
  font-weight: 600;
}
.dynamic-island {
  width: 88px;
  height: 18px;
  background: #000;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 8px;
}
.phone-screen {
  background: #FAF7F2;
  border-radius: 34px;
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  box-shadow: inset 0 0 10px rgba(0,0,0,0.04);
}
.screen-header {
  padding: 12px 14px 8px;
  border-bottom: 1px solid #E8E4DC;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #FAF7F2;
}
.screen-body {
  padding: 12px 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  overflow: hidden;
}

/* Card components */
.sub-card {
  background: #FFFFFF;
  border: 1px solid #EAE6DE;
  border-radius: 14px;
  padding: 10px 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 5px rgba(27,59,47,0.03);
}
.sub-info {
  display: flex;
  align-items: center;
  gap: 10px;
}
.sub-icon {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
}
.sub-names strong {
  display: block;
  font-size: 12px;
  color: #1B3B2F;
}
.sub-names span {
  font-size: 10px;
  color: #7A8275;
}
.sub-price {
  font-size: 12px;
  font-weight: 700;
  color: #1B3B2F;
}
"""

def render_screenshot(html_content, output_png, width=1200, height=675):
    tmp_html = f"/tmp/subflow_cards/{os.path.basename(output_png)}.html"
    with open(tmp_html, "w", encoding="utf-8") as f:
        f.write(html_content)
    
    cmd = [
        CHROME_BIN,
        "--headless",
        "--disable-gpu",
        "--force-device-scale-factor=2",
        f"--window-size={width},{height}",
        f"--screenshot={output_png}",
        f"file://{tmp_html}"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        print(f"✅ Generated: {output_png} ({os.path.getsize(output_png)} bytes)")
    else:
        print(f"❌ Failed to generate {output_png}: {res.stderr}")

# ==========================================
# 0. MASTER BANNER (README HERO)
# ==========================================
BANNER_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 560px;
  background: radial-gradient(circle at 75% 40%, #E8ECDF 0%, #FAF7F2 60%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 40px 70px;
  color: #1B3B2F;
  overflow: hidden;
  position: relative;
}}
.banner-badge {{
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: #1B3B2F;
  color: #F5EFE6;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
}}
.banner-left {{
  max-width: 540px;
  display: flex;
  flex-direction: column;
  gap: 18px;
  z-index: 10;
}}
.banner-title {{
  font-size: 52px;
  line-height: 1.08;
  letter-spacing: -2px;
  font-weight: 550;
}}
.banner-desc {{
  font-size: 18px;
  line-height: 1.6;
  color: #5A6354;
}}
.banner-tags {{
  display: flex;
  gap: 12px;
  margin-top: 6px;
}}
.tag-item {{
  background: rgba(27, 59, 47, 0.07);
  border: 1px solid rgba(27, 59, 47, 0.12);
  padding: 6px 14px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  color: #244737;
}}
.devices-wrapper {{
  position: relative;
  width: 520px;
  height: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
}}
.desktop-preview {{
  position: absolute;
  left: 0;
  width: 440px;
  height: 290px;
  background: #FFFFFF;
  border-radius: 14px;
  box-shadow: 0 25px 60px rgba(27,59,47,0.18), 0 0 0 1px rgba(0,0,0,0.06);
  overflow: hidden;
  border: 1px solid #EAE6DE;
  transform: translateY(20px);
}}
.desktop-bar {{
  background: #F4F1EA;
  padding: 8px 12px;
  display: flex;
  align-items: center;
  gap: 6px;
  border-bottom: 1px solid #E5E1D7;
}}
.dot {{ width: 8px; height: 8px; border-radius: 50%; display: inline-block; }}
.dot-red {{ background: #FF5F56; }}
.dot-yellow {{ background: #FFBD2E; }}
.dot-green {{ background: #27C93F; }}
.phone-overlap {{
  position: absolute;
  right: 10px;
  transform: scale(0.82) rotate(4deg);
  transform-origin: center right;
  z-index: 5;
}}
</style>
</head>
<body>
  <div class="banner-left">
    <div class="banner-badge">
      <span style="width: 7px; height: 7px; background: #6A8754; border-radius: 50%;"></span>
      SUBFLOW APP · 100% LOCAL-FIRST
    </div>
    <h1 class="banner-title">
      Vos prélèvements.<br>
      Votre <span class="font-serif" style="color: #6C7D57;">tranquillité.</span>
    </h1>
    <p class="banner-desc">
      Suivi serein, simulation What-If d'économies, calendrier des débits et assistant résiliation Loi Châtel. Vos données restent privées sur votre appareil.
    </p>
    <div class="banner-tags">
      <div class="tag-item">🌸 Esthétique Japandi</div>
      <div class="tag-item">🔮 Mode What-If</div>
      <div class="tag-item">📅 Calendrier Prévisionnel</div>
      <div class="tag-item">⚖️ Loi Châtel</div>
    </div>
  </div>

  <div class="devices-wrapper">
    <!-- Desktop Mockup -->
    <div class="desktop-preview">
      <div class="desktop-bar">
        <span class="dot dot-red"></span>
        <span class="dot dot-yellow"></span>
        <span class="dot dot-green"></span>
        <span style="font-size: 10px; color: #7A8275; margin-left: auto;">subflowapp.vercel.app</span>
      </div>
      <div style="padding: 16px; background: #FAF7F2; height: 100%;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
          <div>
            <div style="font-size: 9px; color: #7A8275; text-transform: uppercase;">Coût mensuel équivalent</div>
            <div style="font-size: 26px; font-weight: 700; color: #1B3B2F;">67,37 € <span style="font-size: 12px; font-weight: normal; color: #7A8275;">/ mois</span></div>
          </div>
          <div style="background: #E8ECDF; padding: 4px 10px; border-radius: 20px; font-size: 10px; font-weight: 700; color: #244737;">Budget 80 € OK</div>
        </div>
        <div style="height: 6px; background: #E8E4DC; border-radius: 4px; overflow: hidden; margin-bottom: 14px;">
          <div style="width: 84%; height: 100%; background: #2A5443; border-radius: 4px;"></div>
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px;">
          <div style="display: flex; justify-content: space-between; font-size: 11px; padding: 6px 10px; background: white; border-radius: 8px; border: 1px solid #EAE6DE;">
            <span>🎬 Netflix</span><strong>13,49 €</strong>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 11px; padding: 6px 10px; background: white; border-radius: 8px; border: 1px solid #EAE6DE;">
            <span>🎵 Spotify Premium</span><strong>11,99 €</strong>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 11px; padding: 6px 10px; background: white; border-radius: 8px; border: 1px solid #EAE6DE;">
            <span>🏋️ Basic-Fit</span><strong>29,99 €</strong>
          </div>
        </div>
      </div>
    </div>

    <!-- Phone Mockup Overlap -->
    <div class="phone-overlap">
      <div class="phone-chassis">
        <div class="phone-notch">
          <span>09:41</span>
          <div class="dynamic-island">
            <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
            <span style="font-size: 8px; color: #F5EFE6;">SubFlow</span>
            <span></span>
          </div>
          <span>5G</span>
        </div>
        <div class="phone-screen">
          <div class="screen-header">
            <strong style="font-size: 12px; color: #1B3B2F;">∿ SubFlow.</strong>
            <span style="background: #244737; color: white; padding: 3px 8px; border-radius: 6px; font-size: 9px;">+ Ajouter</span>
          </div>
          <div class="screen-body">
            <div style="background: white; border: 1px solid #EAE6DE; border-radius: 14px; padding: 12px;">
              <span style="font-size: 9px; color: #7A8275;">COÛT MENSUEL</span>
              <div style="font-size: 22px; font-weight: 700; color: #1B3B2F;">67,37 €</div>
              <div style="font-size: 9px; color: #6A8754; font-weight: 600; margin-top: 2px;">Soit 808,44 € / an</div>
            </div>
            <div class="sub-card">
              <div class="sub-info">
                <div class="sub-icon" style="background: #000; color: #E50914;">N</div>
                <div class="sub-names"><strong>Netflix</strong><span>14 du mois</span></div>
              </div>
              <span class="sub-price">13,49 €</span>
            </div>
            <div class="sub-card">
              <div class="sub-info">
                <div class="sub-icon" style="background: #1DB954; color: #fff;">♫</div>
                <div class="sub-names"><strong>Spotify</strong><span>18 du mois</span></div>
              </div>
              <span class="sub-price">11,99 €</span>
            </div>
            <div class="sub-card">
              <div class="sub-info">
                <div class="sub-icon" style="background: #FF6600; color: #fff;">BF</div>
                <div class="sub-names"><strong>Basic-Fit</strong><span>28 du mois</span></div>
              </div>
              <span class="sub-price">29,99 €</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>"""

# ==========================================
# 1. CARD 1: DASHBOARD & SÉRÉNITÉ BUDGÉTAIRE
# ==========================================
CARD_1_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 675px;
  background: #FAF7F2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 50px 80px;
  color: #1B3B2F;
  overflow: hidden;
}}
.pill-tag {{
  background: #E8ECDF;
  color: #244737;
  border: 1px solid #D2DBC5;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
  width: fit-content;
}}
.marketing-col {{
  max-width: 530px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}}
.marketing-title {{
  font-size: 46px;
  line-height: 1.12;
  letter-spacing: -1.8px;
  font-weight: 550;
}}
.marketing-desc {{
  font-size: 17px;
  line-height: 1.65;
  color: #5A6354;
}}
.feature-bullet {{
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 15px;
  color: #2C3E33;
  font-weight: 500;
}}
.bullet-icon {{
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #244737;
  color: #FAF7F2;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}}
</style>
</head>
<body>
  <div class="marketing-col">
    <div class="pill-tag">01 · PILOTAGE BUDGÉTAIRE</div>
    <h1 class="marketing-title">
      Une vue claire.<br>
      Des décisions <span class="font-serif" style="color: #6C7D57;">sereines.</span>
    </h1>
    <p class="marketing-desc">
      Retrouvez tous vos abonnements et prélèvements récurrents en un clin d’œil. Coût mensuel équivalent, répartition par catégorie et suivi de votre budget sans friction.
    </p>
    <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 10px;">
      <div class="feature-bullet">
        <span class="bullet-icon">✓</span>
        <span>Coût mensuel consolidé & annualisé sans calcul mental</span>
      </div>
      <div class="feature-bullet">
        <span class="bullet-icon">✓</span>
        <span>Jauge bienveillante de respect de votre objectif budgétaire</span>
      </div>
      <div class="feature-bullet">
        <span class="bullet-icon">✓</span>
        <span>Graphique en anneau Japandi (Streaming, Sport, Télécoms)</span>
      </div>
    </div>
  </div>

  <div class="phone-chassis">
    <div class="phone-notch">
      <span>09:41</span>
      <div class="dynamic-island">
        <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
        <span style="font-size: 8px; color: #F5EFE6;">SubFlow</span>
        <span></span>
      </div>
      <span>5G</span>
    </div>
    <div class="phone-screen">
      <div class="screen-header">
        <div>
          <span style="font-size: 9px; color: #7A8275;">ESPACE PERSONNEL</span>
          <div style="font-size: 14px; font-weight: 700; color: #1B3B2F;">Bonjour, Camille</div>
        </div>
        <span style="background: #244737; color: white; padding: 4px 10px; border-radius: 8px; font-size: 10px; font-weight: 600;">+ Ajouter</span>
      </div>
      <div class="screen-body">
        <!-- Notification Pill -->
        <div style="background: #F3EFE6; border: 1px solid #E5DFD3; padding: 8px 12px; border-radius: 10px; font-size: 10px; color: #7C6D54; display: flex; align-items: center; gap: 6px;">
          <span>⏰</span> <span>Prélèvement Netflix dans 2 jours (13,49 €)</span>
        </div>

        <!-- Budget Hero Card -->
        <div style="background: white; border: 1px solid #EAE6DE; border-radius: 16px; padding: 14px; box-shadow: 0 4px 12px rgba(27,59,47,0.03);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <span style="font-size: 9px; color: #7A8275; text-transform: uppercase;">Coût mensuel équivalent</span>
              <div style="font-size: 26px; font-weight: 800; color: #1B3B2F; line-height: 1.1; margin-top: 2px;">
                67,37 € <span style="font-size: 11px; font-weight: normal; color: #7A8275;">/ mois</span>
              </div>
            </div>
            <span style="background: #E8ECDF; color: #244737; padding: 3px 8px; border-radius: 99px; font-size: 9px; font-weight: 700;">
              808,44 € / an
            </span>
          </div>
          <div style="margin-top: 12px;">
            <div style="display: flex; justify-content: space-between; font-size: 9px; margin-bottom: 4px;">
              <span style="color: #7A8275;">Budget cible : 80,00 €</span>
              <strong style="color: #244737;">12,63 € restants</strong>
            </div>
            <div style="height: 6px; background: #E8E4DC; border-radius: 4px; overflow: hidden;">
              <div style="width: 84%; height: 100%; background: #2A5443; border-radius: 4px;"></div>
            </div>
          </div>
        </div>

        <!-- Subscription Items -->
        <div style="font-size: 10px; font-weight: 700; color: #7A8275; letter-spacing: 0.5px; margin-top: 4px;">ABONNEMENTS ACTIFS (5)</div>
        <div class="sub-card">
          <div class="sub-info">
            <div class="sub-icon" style="background: #000; color: #E50914;">N</div>
            <div class="sub-names"><strong>Netflix</strong><span>Divertissement · 14 du mois</span></div>
          </div>
          <span class="sub-price">13,49 €</span>
        </div>
        <div class="sub-card">
          <div class="sub-info">
            <div class="sub-icon" style="background: #1DB954; color: #fff;">♫</div>
            <div class="sub-names"><strong>Spotify Premium</strong><span>Musique · 18 du mois</span></div>
          </div>
          <span class="sub-price">11,99 €</span>
        </div>
        <div class="sub-card">
          <div class="sub-info">
            <div class="sub-icon" style="background: #FF6600; color: #fff;">BF</div>
            <div class="sub-names"><strong>Basic-Fit</strong><span>Sport & Forme · 28 du mois</span></div>
          </div>
          <span class="sub-price">29,99 €</span>
        </div>
      </div>
    </div>
  </div>
</body>
</html>"""

# ==========================================
# 2. CARD 2: SIMULATEUR WHAT-IF
# ==========================================
CARD_2_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 675px;
  background: radial-gradient(circle at 20% 50%, #FAF7F2 0%, #EBF0E6 100%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 50px 80px;
  color: #1B3B2F;
  overflow: hidden;
}}
.pill-tag {{
  background: #244737;
  color: #F5EFE6;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
  width: fit-content;
}}
.marketing-col {{
  max-width: 530px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}}
.marketing-title {{
  font-size: 46px;
  line-height: 1.12;
  letter-spacing: -1.8px;
  font-weight: 550;
}}
.marketing-desc {{
  font-size: 17px;
  line-height: 1.65;
  color: #5A6354;
}}
.savings-callout {{
  background: #244737;
  color: #F5EFE6;
  border-radius: 16px;
  padding: 18px 22px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 10px 30px rgba(27,59,47,0.15);
}}
</style>
</head>
<body>
  <div class="marketing-col">
    <div class="pill-tag">02 · SIMULATEUR WHAT-IF</div>
    <h1 class="marketing-title">
      Simulez vos économies.<br>
      <span class="font-serif" style="color: #6C7D57;">Sans rien résilier.</span>
    </h1>
    <p class="marketing-desc">
      Explorez vos arbitrages en un clic. Isolez un ou plusieurs prélèvements et visualisez immédiatement l'impact direct sur votre budget mensuel et annuel sans toucher à vos vrais contrats.
    </p>
    <div class="savings-callout">
      <div>
        <div style="font-size: 11px; text-transform: uppercase; color: #A7C1AE; font-weight: 700;">Économie mensuelle simulée</div>
        <div style="font-size: 28px; font-weight: 800; color: #34D399; margin-top: 2px;">+43,48 € / mois</div>
      </div>
      <div style="text-align: right;">
        <div style="font-size: 11px; color: #A7C1AE;">Sur 12 mois</div>
        <div style="font-size: 20px; font-weight: 700; color: #F5EFE6;">+521,76 €</div>
      </div>
    </div>
  </div>

  <div class="phone-chassis">
    <div class="phone-notch">
      <span>09:41</span>
      <div class="dynamic-island">
        <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
        <span style="font-size: 8px; color: #F5EFE6;">Simulation</span>
        <span></span>
      </div>
      <span>5G</span>
    </div>
    <div class="phone-screen">
      <div class="screen-header" style="background: #244737; color: white;">
        <div style="display: flex; align-items: center; gap: 6px;">
          <span style="font-size: 13px;">🔮</span>
          <strong style="font-size: 12px;">Mode What-If Actif</strong>
        </div>
        <span style="background: #34D399; color: #1B3B2F; padding: 2px 8px; border-radius: 99px; font-size: 9px; font-weight: 800;">-63%</span>
      </div>
      <div class="screen-body">
        <!-- New Balance Card -->
        <div style="background: #E8ECDF; border: 1px solid #C4D3B8; border-radius: 14px; padding: 12px;">
          <div style="font-size: 9px; color: #5A6A50; font-weight: 700; text-transform: uppercase;">Nouveau Coût Projeté</div>
          <div style="display: flex; align-items: baseline; gap: 8px; margin-top: 2px;">
            <span style="font-size: 24px; font-weight: 800; color: #244737;">23,89 €</span>
            <span style="font-size: 11px; text-decoration: line-through; color: #8F9988;">67,37 €</span>
          </div>
          <div style="font-size: 9px; color: #244737; font-weight: 600; margin-top: 4px;">
            🎉 Gain annuel : <strong>+521,76 €</strong> préservés
          </div>
        </div>

        <div style="font-size: 10px; font-weight: 700; color: #7A8275;">CLIQUEZ POUR EXCLURE / RÉACTIVER</div>

        <!-- Excluded Netflix -->
        <div class="sub-card" style="opacity: 0.55; background: #F5F3ED; border-style: dashed;">
          <div class="sub-info">
            <div class="sub-icon" style="background: #333; color: #aaa;">N</div>
            <div class="sub-names">
              <strong style="text-decoration: line-through;">Netflix</strong>
              <span style="color: #E50914; font-weight: 600;">-13,49 € exclu</span>
            </div>
          </div>
          <span style="font-size: 11px; background: #E8E4DC; padding: 2px 6px; border-radius: 4px; color: #666;">Off</span>
        </div>

        <!-- Excluded Basic-Fit -->
        <div class="sub-card" style="opacity: 0.55; background: #F5F3ED; border-style: dashed;">
          <div class="sub-info">
            <div class="sub-icon" style="background: #888; color: #fff;">BF</div>
            <div class="sub-names">
              <strong style="text-decoration: line-through;">Basic-Fit</strong>
              <span style="color: #FF6600; font-weight: 600;">-29,99 € exclu</span>
            </div>
          </div>
          <span style="font-size: 11px; background: #E8E4DC; padding: 2px 6px; border-radius: 4px; color: #666;">Off</span>
        </div>

        <!-- Kept Spotify -->
        <div class="sub-card" style="border: 2px solid #244737; box-shadow: 0 4px 10px rgba(36,71,55,0.08);">
          <div class="sub-info">
            <div class="sub-icon" style="background: #1DB954; color: #fff;">♫</div>
            <div class="sub-names">
              <strong>Spotify Premium</strong>
              <span style="color: #244737; font-weight: 600;">Conservé</span>
            </div>
          </div>
          <span class="sub-price">11,99 €</span>
        </div>
      </div>
    </div>
  </div>
</body>
</html>"""

# ==========================================
# 3. CARD 3: CALENDRIER DES ÉCHÉANCES
# ==========================================
CARD_3_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 675px;
  background: #FAF7F2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 50px 80px;
  color: #1B3B2F;
  overflow: hidden;
}}
.pill-tag {{
  background: #E8ECDF;
  color: #244737;
  border: 1px solid #D2DBC5;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
  width: fit-content;
}}
.marketing-col {{
  max-width: 530px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}}
.marketing-title {{
  font-size: 46px;
  line-height: 1.12;
  letter-spacing: -1.8px;
  font-weight: 550;
}}
.marketing-desc {{
  font-size: 17px;
  line-height: 1.65;
  color: #5A6354;
}}
.calendar-grid {{
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  text-align: center;
}}
.cal-cell {{
  height: 32px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  font-size: 10px;
  position: relative;
}}
.cal-active {{
  background: #1B3B2F;
  color: #FAF7F2;
  font-weight: bold;
}}
.cal-dot {{
  width: 4px;
  height: 4px;
  border-radius: 50%;
  position: absolute;
  bottom: 2px;
}}
</style>
</head>
<body>
  <div class="marketing-col">
    <div class="pill-tag">03 · CALENDRIER PRÉVISIONNEL</div>
    <h1 class="marketing-title">
      Anticipez chaque débit.<br>
      <span class="font-serif" style="color: #6C7D57;">Zéro mauvaise surprise.</span>
    </h1>
    <p class="marketing-desc">
      Visualisez vos échéances récurrentes jour par jour. Sachez exactement quel montant sera prélevé et quand, pour garder l’esprit serein à l'approche de la fin de mois.
    </p>
    <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 10px;">
      <div style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500;">
        <span style="width: 24px; height: 24px; border-radius: 50%; background: #244737; color: #FAF7F2; display: flex; align-items: center; justify-content: center; font-size: 12px;">✓</span>
        <span>Dates clés identifiées avec pastilles de logos officiels</span>
      </div>
      <div style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500;">
        <span style="width: 24px; height: 24px; border-radius: 50%; background: #244737; color: #FAF7F2; display: flex; align-items: center; justify-content: center; font-size: 12px;">✓</span>
        <span>Alerte proactive 2 jours avant chaque échéance</span>
      </div>
      <div style="display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500;">
        <span style="width: 24px; height: 24px; border-radius: 50%; background: #244737; color: #FAF7F2; display: flex; align-items: center; justify-content: center; font-size: 12px;">✓</span>
        <span>Détection des prélèvements groupés sur la même journée</span>
      </div>
    </div>
  </div>

  <div class="phone-chassis">
    <div class="phone-notch">
      <span>09:41</span>
      <div class="dynamic-island">
        <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
        <span style="font-size: 8px; color: #F5EFE6;">Calendrier</span>
        <span></span>
      </div>
      <span>5G</span>
    </div>
    <div class="phone-screen">
      <div class="screen-header">
        <div>
          <span style="font-size: 9px; color: #7A8275;">ÉCHÉANCIER</span>
          <div style="font-size: 13px; font-weight: 700; color: #1B3B2F;">Septembre 2026</div>
        </div>
        <span style="font-size: 11px; color: #244737; font-weight: 600;">Ce mois : 67,37 €</span>
      </div>
      <div class="screen-body">
        <!-- Calendar Matrix -->
        <div style="background: white; border: 1px solid #EAE6DE; border-radius: 14px; padding: 10px;">
          <div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; text-align: center; font-size: 9px; color: #9A9E96; margin-bottom: 6px; font-weight: 700;">
            <span>L</span><span>M</span><span>M</span><span>J</span><span>V</span><span>S</span><span>D</span>
          </div>
          <div class="calendar-grid">
            <span class="cal-cell" style="color: #bbb;">31</span>
            <span class="cal-cell">1</span>
            <span class="cal-cell" style="background: #E8ECDF; font-weight: bold;">2<span class="cal-dot" style="background: #3B82F6;"></span></span>
            <span class="cal-cell">3</span>
            <span class="cal-cell">4</span>
            <span class="cal-cell">5</span>
            <span class="cal-cell">6</span>
            <span class="cal-cell">7</span>
            <span class="cal-cell">8</span>
            <span class="cal-cell">9</span>
            <span class="cal-cell">10</span>
            <span class="cal-cell">11</span>
            <span class="cal-cell">12</span>
            <span class="cal-cell">13</span>
            <span class="cal-cell cal-active">14<span class="cal-dot" style="background: #E50914;"></span></span>
            <span class="cal-cell">15</span>
            <span class="cal-cell">16</span>
            <span class="cal-cell">17</span>
            <span class="cal-cell" style="background: #E8ECDF; font-weight: bold;">18<span class="cal-dot" style="background: #1DB954;"></span></span>
            <span class="cal-cell">19</span>
            <span class="cal-cell">20</span>
            <span class="cal-cell">21</span>
            <span class="cal-cell">22</span>
            <span class="cal-cell">23</span>
            <span class="cal-cell">24</span>
            <span class="cal-cell">25</span>
            <span class="cal-cell">26</span>
            <span class="cal-cell">27</span>
            <span class="cal-cell" style="background: #E8ECDF; font-weight: bold;">28<span class="cal-dot" style="background: #FF6600;"></span></span>
            <span class="cal-cell">29</span>
            <span class="cal-cell">30</span>
          </div>
        </div>

        <!-- Detail of Selected Day -->
        <div style="font-size: 10px; font-weight: 700; color: #7A8275;">ÉCHÉANCES DU 14 SEPTEMBRE</div>
        <div class="sub-card" style="border-left: 3px solid #E50914;">
          <div class="sub-info">
            <div class="sub-icon" style="background: #000; color: #E50914;">N</div>
            <div class="sub-names"><strong>Netflix</strong><span>Prélèvement mensuel</span></div>
          </div>
          <span class="sub-price">13,49 €</span>
        </div>

        <div style="font-size: 10px; font-weight: 700; color: #7A8275; margin-top: 4px;">PROCHAINEMENT CE MOIS</div>
        <div class="sub-card" style="border-left: 3px solid #1DB954;">
          <div class="sub-info">
            <div class="sub-icon" style="background: #1DB954; color: #fff;">♫</div>
            <div class="sub-names"><strong>Spotify Premium</strong><span>18 septembre</span></div>
          </div>
          <span class="sub-price">11,99 €</span>
        </div>
      </div>
    </div>
  </div>
</body>
</html>"""

# ==========================================
# 4. CARD 4: CATALOGUE & LOGOS VECTORIELS
# ==========================================
CARD_4_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 675px;
  background: radial-gradient(circle at 80% 30%, #EBF0E6 0%, #FAF7F2 60%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 50px 80px;
  color: #1B3B2F;
  overflow: hidden;
}}
.pill-tag {{
  background: #244737;
  color: #F5EFE6;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
  width: fit-content;
}}
.marketing-col {{
  max-width: 530px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}}
.marketing-title {{
  font-size: 46px;
  line-height: 1.12;
  letter-spacing: -1.8px;
  font-weight: 550;
}}
.marketing-desc {{
  font-size: 17px;
  line-height: 1.65;
  color: #5A6354;
}}
.svg-badge-grid {{
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  margin-top: 10px;
}}
.svg-card-sample {{
  background: white;
  border: 1px solid #EAE6DE;
  border-radius: 12px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: 600;
  color: #244737;
}}
</style>
</head>
<body>
  <div class="marketing-col">
    <div class="pill-tag">04 · LOGOS VECTORIELS & PRESETS</div>
    <h1 class="marketing-title">
      350+ presets prêts.<br>
      <span class="font-serif" style="color: #6C7D57;">Logos vectoriels nets.</span>
    </h1>
    <p class="marketing-desc">
      Saisie ultra-rapide avec détection automatique du montant et de la périodicité. Chaque catégorie bénéficie d'une bibliothèque de logos SVG natifs haute définition, sans aucun pixel flou.
    </p>
    <div class="svg-badge-grid">
      <div class="svg-card-sample">
        <span style="font-size: 20px;">🎬</span>
        <span>Streaming</span>
      </div>
      <div class="svg-card-sample">
        <span style="font-size: 20px;">🏋️</span>
        <span>Sport</span>
      </div>
      <div class="svg-card-sample">
        <span style="font-size: 20px;">⚡</span>
        <span>Énergie</span>
      </div>
      <div class="svg-card-sample">
        <span style="font-size: 20px;">📱</span>
        <span>Téléphonie</span>
      </div>
    </div>
  </div>

  <div class="phone-chassis">
    <div class="phone-notch">
      <span>09:41</span>
      <div class="dynamic-island">
        <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
        <span style="font-size: 8px; color: #F5EFE6;">Ajout</span>
        <span></span>
      </div>
      <span>5G</span>
    </div>
    <div class="phone-screen">
      <div class="screen-header">
        <strong style="font-size: 13px; color: #1B3B2F;">Ajouter un abonnement</strong>
        <span style="font-size: 12px; color: #7A8275;">✕</span>
      </div>
      <div class="screen-body">
        <!-- Logo Avatar Header in Modal -->
        <div style="display: flex; align-items: center; gap: 12px; background: white; border: 1px solid #EAE6DE; border-radius: 14px; padding: 10px 14px;">
          <div style="width: 44px; height: 44px; border-radius: 12px; background: #1B3B2F; color: #F5EFE6; display: flex; align-items: center; justify-content: center; font-size: 20px;">
            🏋️
          </div>
          <div>
            <strong style="font-size: 13px; color: #1B3B2F; display: block;">Salle de sport</strong>
            <span style="font-size: 10px; color: #6A8754; font-weight: 600;">Catégorie : Sport & Bien-être</span>
          </div>
        </div>

        <!-- Preset Selector Grid -->
        <div style="font-size: 10px; font-weight: 700; color: #7A8275;">SÉLECTION DE L'ICÔNE VECTORIELLE</div>
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px;">
          <div style="background: #244737; color: white; border-radius: 10px; height: 38px; display: flex; align-items: center; justify-content: center; font-size: 16px; border: 2px solid #34D399;">🏋️</div>
          <div style="background: white; border: 1px solid #EAE6DE; border-radius: 10px; height: 38px; display: flex; align-items: center; justify-content: center; font-size: 16px;">🚴</div>
          <div style="background: white; border: 1px solid #EAE6DE; border-radius: 10px; height: 38px; display: flex; align-items: center; justify-content: center; font-size: 16px;">🥊</div>
          <div style="background: white; border: 1px solid #EAE6DE; border-radius: 10px; height: 38px; display: flex; align-items: center; justify-content: center; font-size: 16px;">🧘</div>
        </div>

        <!-- Form fields -->
        <div style="display: flex; flex-direction: column; gap: 6px; margin-top: 4px;">
          <div style="background: white; border: 1px solid #EAE6DE; border-radius: 10px; padding: 8px 12px; font-size: 11px;">
            <span style="font-size: 9px; color: #7A8275; display: block;">MONTANT</span>
            <strong>29,99 €</strong>
          </div>
          <div style="background: white; border: 1px solid #EAE6DE; border-radius: 10px; padding: 8px 12px; font-size: 11px;">
            <span style="font-size: 9px; color: #7A8275; display: block;">FRÉQUENCE</span>
            <strong>Mensuel (le 28 du mois)</strong>
          </div>
        </div>

        <button style="margin-top: 8px; background: #244737; color: white; border: none; padding: 12px; border-radius: 12px; font-size: 12px; font-weight: 700; width: 100%;">
          Enregistrer le prélèvement
        </button>
      </div>
    </div>
  </div>
</body>
</html>"""

# ==========================================
# 5. CARD 5: LOI CHÂTEL & CONFIDENTIALITÉ
# ==========================================
CARD_5_HTML = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
{COMMON_CSS}
body {{
  width: 1200px;
  height: 675px;
  background: #FAF7F2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 50px 80px;
  color: #1B3B2F;
  overflow: hidden;
}}
.pill-tag {{
  background: #E8ECDF;
  color: #244737;
  border: 1px solid #D2DBC5;
  padding: 7px 16px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 1.5px;
  width: fit-content;
}}
.marketing-col {{
  max-width: 530px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}}
.marketing-title {{
  font-size: 46px;
  line-height: 1.12;
  letter-spacing: -1.8px;
  font-weight: 550;
}}
.marketing-desc {{
  font-size: 17px;
  line-height: 1.65;
  color: #5A6354;
}}
.security-badge {{
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: #244737;
  color: #F5EFE6;
  padding: 10px 16px;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
}}
</style>
</head>
<body>
  <div class="marketing-col">
    <div class="pill-tag">05 · LOI CHÂTEL & LOCAL-FIRST</div>
    <h1 class="marketing-title">
      Résiliation en 3 clics.<br>
      <span class="font-serif" style="color: #6C7D57;">100% Local-First.</span>
    </h1>
    <p class="marketing-desc">
      Générez instantanément votre lettre recommandée certifiée conforme à l'article L215-1 du Code de la consommation. Vos données financières restent exclusivement stockées sur votre appareil.
    </p>
    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
      <div class="security-badge">
        <span>🔒</span>
        <span>Local-First & Export Chiffré</span>
      </div>
      <div class="security-badge">
        <span>📜</span>
        <span>Loi Châtel Conforme</span>
      </div>
      <div class="security-badge">
        <span>🛡️</span>
        <span>Zéro revente de données</span>
      </div>
    </div>
  </div>

  <div class="phone-chassis">
    <div class="phone-notch">
      <span>09:41</span>
      <div class="dynamic-island">
        <span style="width: 5px; height: 5px; background: #34D399; border-radius: 50%;"></span>
        <span style="font-size: 8px; color: #F5EFE6;">Loi Châtel</span>
        <span></span>
      </div>
      <span>5G</span>
    </div>
    <div class="phone-screen">
      <div class="screen-header" style="background: #244737; color: white;">
        <strong style="font-size: 12px;">⚖️ Assistant Résiliation</strong>
        <span style="font-size: 11px;">✕</span>
      </div>
      <div class="screen-body">
        <!-- Law Chatel Notice Card -->
        <div style="background: #FDFBF7; border: 1px solid #EAE6DE; border-radius: 12px; padding: 12px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
            <span style="font-size: 9px; font-weight: 700; color: #6A8754; text-transform: uppercase;">Modèle certifié</span>
            <span style="font-size: 9px; color: #7A8275;">Art. L215-1</span>
          </div>
          <div style="font-size: 10px; color: #2C3E33; line-height: 1.5; font-family: monospace; background: #FAF7F2; padding: 8px; border-radius: 6px; border: 1px dashed #D6D2C4;">
            « Objet : Résiliation à échéance du contrat Salle de sport n° 849204... »
          </div>
        </div>

        <!-- Action Buttons -->
        <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 4px;">
          <button style="background: #244737; color: white; border: none; padding: 10px; border-radius: 10px; font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 6px;">
            <span>📋</span> Copier la lettre officielle
          </button>
          <button style="background: #E8ECDF; color: #244737; border: 1px solid #C4D3B8; padding: 10px; border-radius: 10px; font-size: 11px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 6px;">
            <span>↗</span> Lien direct résiliation
          </button>
        </div>

        <!-- Privacy reassurance -->
        <div style="margin-top: 6px; background: white; border: 1px solid #EAE6DE; border-radius: 12px; padding: 10px; font-size: 10px; color: #5A6354; display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 16px;">🛡️</span>
          <span>Stockage strictement local dans votre navigateur. Sauvegarde Google Drive optionnelle.</span>
        </div>
      </div>
    </div>
  </div>
</body>
</html>"""

# Execute rendering
print("Rendering Showcase Cards...")
render_screenshot(BANNER_HTML, f"{OUTPUT_DIR}/showcase_banner.png", width=1200, height=560)
render_screenshot(CARD_1_HTML, f"{OUTPUT_DIR}/card_01_dashboard.png", width=1200, height=675)
render_screenshot(CARD_2_HTML, f"{OUTPUT_DIR}/card_02_whatif.png", width=1200, height=675)
render_screenshot(CARD_3_HTML, f"{OUTPUT_DIR}/card_03_calendar.png", width=1200, height=675)
render_screenshot(CARD_4_HTML, f"{OUTPUT_DIR}/card_04_logos.png", width=1200, height=675)
render_screenshot(CARD_5_HTML, f"{OUTPUT_DIR}/card_05_loichatel_privacy.png", width=1200, height=675)

print("All cards successfully created.")
