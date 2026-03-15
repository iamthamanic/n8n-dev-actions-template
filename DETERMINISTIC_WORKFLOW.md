# Deterministischer Workflow

**"Immer gleich, immer funktioniert"**

Dieses Dokument beschreibt den EXAKTEN Prozess, der bei jedem neuen Projekt befolgt werden muss.

---

## 🎯 Prinzip

> **Gleicher Input → Gleicher Prozess → Gleiches Ergebnis**

Egal welches Projekt, welcher Tag, welcher Entwickler - dieser Workflow funktioniert immer.

---

## 📋 Schritt-für-Schritt

### Phase 1: Vorbereitung (5 Minuten)

#### Schritt 1.1: Template klonen
```bash
# Auf GitHub:
# 1. Gehe zu: https://github.com/iamthamanic/n8n-dev-actions-template
# 2. Klicke: "Use this template" → "Create a new repository"
# 3. Name: [projekt-name]-ci
# 4. Visibility: Private (empfohlen für CI)
# 5. Klicke: "Create repository"

# Oder via CLI:
gh repo create [projekt-name]-ci \
  --template iamthamanic/n8n-dev-actions-template \
  --private
```

**ERWARTETES ERGEBNIS:** Neues Repository existiert mit allen Template-Dateien

**VALIDIERUNG:**
```bash
git clone https://github.com/iamthamanic/[projekt-name]-ci.git
cd [projekt-name]-ci
ls templates/  # Sollte 6 JSON-Dateien zeigen
```

---

#### Schritt 1.2: Projekt-Typ identifizieren

| Projekt-Typ | Template-Datei | Begründung |
|-------------|----------------|------------|
| Node.js/React/Vite | `02-node-template.json` | npm, eslint, jest |
| Python/Django/Flask | `03-python-template.json` | pip, pytest, flake8 |
| Docker/Microservices | `04-docker-template.json` | docker build, scan |
| Qualitäts-Check wichtig | `05-quality-gate-template.json` | ShimWrapperCheck |
| Deployment nötig | `06-deploy-template.json` | SSH, health check |
| Einfaches Projekt | `01-base-template.json` | Minimal setup |

**ENTSCHEIDUNG:** Welches Template passt am besten?

---

### Phase 2: Konfiguration (10 Minuten)

#### Schritt 2.1: workflow-config.json anpassen

Öffne `workflow-config.json` und fülle aus:

```json
{
  "project": {
    "name": "DEIN_PROJEKT_NAME",
    "type": "node|python|docker|base",
    "repository": "iamthamanic/DEIN_REPO"
  },
  "workflow": {
    "template": "XX-TEMPLATE_NAME.json",
    "stages": [
      "install",
      "lint",
      "test",
      "build",
      "quality-gate"
    ],
    "webhook": {
      "url": "WIRD_IN_SCHRITT_3_AUSGEFÜLLT"
    }
  },
  "runner": {
    "host": "DEIN_VPS_IP",
    "user": "root",
    "ssh_key": "~/.ssh/id_ed25519"
  },
  "notifications": {
    "telegram": {
      "enabled": true,
      "chat_id": "5220247822"
    }
  },
  "secrets": {
    "github_token": "ENV:GITHUB_TOKEN",
    "telegram_token": "ENV:TELEGRAM_BOT_TOKEN"
  }
}
```

**PFLICHTFELDER:**
- `project.name` → Muss eindeutig sein
- `project.repository` → Format: `owner/repo`
- `workflow.template` → Muss existierende JSON-Datei sein
- `runner.host` → IP oder Domain deines VPS

**OPTIONAL:**
- `notifications.telegram.chat_id` → Deine Telegram ID
- `workflow.stages` → Welche Schritte ausführen?

---

#### Schritt 2.2: Template validieren

```bash
# Im Repository-Verzeichnis:
./scripts/validate-workflow.sh

# ERWARTETE AUSGABE:
# ✅ Config-Datei ist valides JSON
# ✅ Template-Datei existiert: templates/XX-template.json
# ✅ Alle Pflichtfelder vorhanden
# ✅ Repository-Format korrekt
# ✅ SSH-Verbindung testbar
```

**WENN FEHLER:**
- Config-Datei korrigieren
- Erneut validieren
- Bis alle Checks grün sind

---

### Phase 3: n8n Import (10 Minuten)

#### Schritt 3.1: In n8n einloggen

```
URL: https://n8n-xpip.srv1492167.hstgr.cloud/
Login: (deine Credentials)
```

---

#### Schritt 3.2: Workflow importieren

1. **Linke Seite:** "Workflows" klicken
2. **Oben rechts:** "Import from File" klicken
3. **Datei auswählen:** `templates/XX-TEMPLATE_NAME.json`
4. **Name vergeben:** `[projekt-name]-ci`
5. **Speichern:** Ctrl+S (oder Cmd+S)

**ERWARTETES ERGEBNIS:** Workflow erscheint in der Liste

---

#### Schritt 3.3: Webhook konfigurieren

1. **Workflow öffnen**
2. **Erster Node:** "Webhook" klicken
3. **HTTP-Methode:** POST
4. **Path:** `ci-[projekt-name]` (z.B. `ci-easyploy`)
5. **Response Mode:** Last Node
6. **Speichern**

**WEBHOOK URL KOPIEREN:**
```
https://n8n-xpip.srv1492167.hstgr.cloud/webhook/ci-[projekt-name]
```

**In `workflow-config.json` eintragen:**
```json
"webhook": {
  "url": "https://n8n-xpip.srv1492167.hstgr.cloud/webhook/ci-DEIN_PROJEKT"
}
```

---

#### Schritt 3.4: Credentials setzen

1. **Settings** (Zahnrad oben rechts)
2. **Credentials**
3. **Add Credential**

**GitHub Token:**
- Name: `github-token-[projekt-name]`
- Type: `GitHub OAuth2 API`
- Token: (dein GitHub Personal Access Token)

**Telegram Bot:**
- Name: `telegram-bot`
- Type: `Telegram API`
- Bot Token: (dein Bot Token)

**SSH Key:**
- Name: `vps-ssh-key`
- Type: `SSH Passwordless`
- Private Key: (dein SSH Private Key)

---

### Phase 4: GitHub Integration (5 Minuten)

#### Schritt 4.1: Webhook einrichten

```bash
# Im Repository-Verzeichnis:
./scripts/setup-webhook.sh

# Oder manuell auf GitHub:
# 1. Repository → Settings → Webhooks
# 2. Add webhook
# 3. Payload URL: (aus Schritt 3.3)
# 4. Content type: application/json
# 5. Events: Push, Pull Request
# 6. Active: ✓
# 7. Add webhook
```

**VALIDIERUNG:**
- Webhook erscheint in GitHub
- Status: ✓ (grüner Haken nach erstem Test)

---

#### Schritt 4.2: Branch Protection (optional)

```
GitHub → Settings → Branches → Add rule
Branch name pattern: main
✓ Require status checks to pass
✓ Status check: ci/[projekt-name]
✓ Require branches to be up to date
```

---

### Phase 5: Test (5 Minuten)

#### Schritt 5.1: Test-Push auslösen

```bash
# Im Ziel-Repository (nicht das CI-Repo):
cd /pfad/zu/deinem/projekt

# Kleine Änderung machen:
echo "# Test" >> README.md
git add README.md
git commit -m "test: CI workflow"
git push origin main
```

---

#### Schritt 5.2: Ergebnisse prüfen

**In n8n:**
1. **Executions** öffnen
2. **Neueste Execution** suchen
3. **Status:** Sollte "Success" sein
4. **Logs:** Alle Stages sollten grün sein

**In GitHub:**
1. **Repository** → **Actions** (oder direkt im PR)
2. **Status-Check** sollte erscheinen
3. **Grüner Haken** = Erfolg

**In Telegram:**
- Nachricht bei Erfolg/Fehler (falls konfiguriert)

---

#### Schritt 5.3: Fehlerbehebung

**WENN FEHLER:**

1. **n8n Logs prüfen:**
   - Welcher Node ist rot?
   - Fehlermeldung lesen

2. **Häufige Fehler:**
   - `SSH connection failed` → SSH Key prüfen
   - `Repository not found` → GitHub Token prüfen
   - `Command not found` → Runner hat nicht das Tool

3. **Dokumentation:**
   - `docs/TROUBLESHOOTING.md` lesen

---

### Phase 6: Fertigstellung (2 Minuten)

#### Schritt 6.1: Änderungen committen

```bash
cd [projekt-name]-ci
git add workflow-config.json
git commit -m "ci: configure n8n workflow for [projekt-name]"
git push origin main
```

---

#### Schritt 6.2: Dokumentation aktualisieren

In `README.md` deines CI-Repos:

```markdown
## Projekt: [projekt-name]

- **Template:** XX-template.json
- **Webhook:** https://n8n-xpip.../webhook/ci-[projekt-name]
- **Status:** ✅ Aktiv
- **Letzter Test:** 2026-03-15
```

---

## ✅ Checkliste

Vor dem Abschluss prüfen:

- [ ] Template geklont
- [ ] workflow-config.json angepasst
- [ ] Template validiert (grün)
- [ ] In n8n importiert
- [ ] Webhook URL kopiert
- [ ] Credentials gesetzt
- [ ] GitHub Webhook aktiv
- [ ] Test-Push erfolgreich
- [ ] Dokumentation aktualisiert

**WENN ALLE CHECKS GRÜN:** 🎉 Fertig!

---

## 🔄 Wartung

**Monatlich:**
- [ ] n8n Updates prüfen
- [ ] Logs auf Fehler durchsuchen
- [ ] SSH Keys rotieren (alle 3 Monate)

**Bei Problemen:**
- `docs/TROUBLESHOOTING.md`
- `./scripts/validate-workflow.sh`

---

**Version:** 1.0.0  
**Letzte Aktualisierung:** 2026-03-15  
**Gültig für:** Alle Projekte
