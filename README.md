# n8n Dev Actions Template

**Deterministische CI/CD Workflows für alle Projekte**

Dieses Repository ist ein **GitHub Template**. Für jedes neue Projekt:

1. **Template verwenden** → "Use this template" → "Create a new repository"
2. **Anpassen** → `workflow-config.json` editieren
3. **Importieren** → JSON in n8n importieren
4. **Fertig** → Webhook aktivieren

---

## 📁 Repository-Struktur

```
n8n-dev-actions-template/
├── 📄 README.md                          # Diese Datei
├── 📄 DETERMINISTIC_WORKFLOW.md          # Schritt-für-Schritt Anleitung
├── 📄 workflow-config.json               # Konfiguration für dieses Projekt
├── 📁 templates/                         # n8n Workflow JSONs
│   ├── 📄 01-base-template.json          # Basis: Checkout → Build → Test
│   ├── 📄 02-node-template.json          # Node.js spezifisch
│   ├── 📄 03-python-template.json        # Python spezifisch
│   ├── 📄 04-docker-template.json        # Docker Builds
│   ├── 📄 05-quality-gate-template.json # Mit ShimWrapperCheck
│   └── 📄 06-deploy-template.json        # Deployment zu VPS
├── 📁 scripts/                           # Hilfsskripte
│   ├── 📄 setup-webhook.sh               # GitHub Webhook einrichten
│   └── 📄 validate-workflow.sh           # Workflow validieren
└── 📁 docs/                              # Dokumentation
    ├── 📄 ARCHITECTURE.md                # System-Architektur
    ├── 📄 TROUBLESHOOTING.md             # Fehlerbehebung
    └── 📄 SECURITY.md                     # Sicherheitsrichtlinien
```

---

## 🚀 Schnellstart

### 1. Neues Projekt aus Template erstellen

```bash
# Auf GitHub: Use this template → Create new repository
# Oder via CLI:
gh repo create mein-projekt --template iamthamanic/n8n-dev-actions-template --public
```

### 2. Konfiguration anpassen

Editiere `workflow-config.json`:

```json
{
  "project": {
    "name": "mein-projekt",
    "type": "node",
    "repository": "iamthamanic/mein-projekt"
  },
  "workflow": {
    "template": "02-node-template.json",
    "stages": ["install", "lint", "test", "build", "quality-gate"]
  },
  "notifications": {
    "telegram": true,
    "chat_id": "5220247822"
  }
}
```

### 3. In n8n importieren

1. n8n öffnen → Workflows → Import from File
2. `templates/02-node-template.json` auswählen
3. Webhook URL kopieren
4. In `workflow-config.json` eintragen

### 4. GitHub Webhook aktivieren

```bash
./scripts/setup-webhook.sh
```

---

## 📋 Deterministischer Workflow

**Jedes Mal gleiche Schritte:**

1. **Template klonen** (immer gleicher Startpunkt)
2. **Konfiguration anpassen** (nur `workflow-config.json`)
3. **Template auswählen** (passend zum Projekt-Typ)
4. **In n8n importieren** (JSON → Workflow)
5. **Webhook einrichten** (GitHub → n8n)
6. **Testen** (Push auslösen → Ergebnis prüfen)
7. **Fertig** (läuft automatisch bei jedem Push)

**Details:** Siehe `DETERMINISTIC_WORKFLOW.md`

---

## 🛠️ Verfügbare Templates

| Template | Zweck | Enthält |
|----------|-------|---------|
| `01-base-template.json` | Alle Projekte | Checkout, Build, Test |
| `02-node-template.json` | Node.js | npm ci, eslint, jest, build |
| `03-python-template.json` | Python | pip install, pytest, flake8 |
| `04-docker-template.json` | Container | docker build, push, scan |
| `05-quality-gate-template.json` | Code-Review | ShimWrapperCheck + Kimi |
| `06-deploy-template.json` | Deployment | SSH deploy, health check |

---

## 🔧 Anpassung

### Eigene Stages hinzufügen

In `workflow-config.json`:

```json
{
  "custom_stages": [
    {
      "name": "security-scan",
      "command": "npm audit --audit-level=high",
      "fail_on_error": true
    }
  ]
}
```

### Secrets konfigurieren

In n8n: Settings → Credentials → Add Credential

- `GITHUB_TOKEN` → Für Status API
- `TELEGRAM_BOT_TOKEN` → Für Notifications
- `SSH_PRIVATE_KEY` → Für Deployment

---

## 📊 Monitoring

Alle Workflows loggen zu:
- **n8n Executions** → In n8n UI sichtbar
- **GitHub Status** → In PRs als Checks
- **Telegram** → Bei Fehlern (optional)

---

## 🆘 Support

Bei Problemen:
1. `docs/TROUBLESHOOTING.md` lesen
2. `./scripts/validate-workflow.sh` ausführen
3. Logs in n8n prüfen (Executions → Error)

---

**Template Version:** 1.0.0  
**Letzte Aktualisierung:** 2026-03-15  
**Maintainer:** Raccoovaclaw
