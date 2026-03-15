# Troubleshooting

## Common Issues

### 1. Webhook not triggering

**Symptom:** Push doesn't start workflow

**Check:**
```bash
# In GitHub repo:
Settings → Webhooks → Recent Deliveries

# Should show:
# - Green checkmark
# - 200 OK response
```

**Fix:**
- Verify webhook URL is correct
- Check n8n webhook is active
- Ensure workflow is saved in n8n

---

### 2. SSH connection failed

**Symptom:** "Connection refused" or "Permission denied"

**Check:**
```bash
# Test SSH manually:
ssh -i ~/.ssh/id_ed25519 user@host

# Should connect without password
```

**Fix:**
- Add SSH key to runner: `cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys`
- Check firewall: `ufw allow 22`
- Verify key path in config

---

### 3. Command not found

**Symptom:** "npm: command not found" or similar

**Check:**
```bash
# On runner:
which npm
which python
which docker

# Should return paths
```

**Fix:**
- Install missing tools on runner
- Or use full paths: `/usr/local/bin/npm`

---

### 4. Build fails but reports success

**Symptom:** Red build in logs, green status on GitHub

**Fix:**
- Check SSH node "Continue On Fail" setting
- Should be OFF for critical steps

---

### 5. ShimWrapperCheck not working

**Symptom:** "ollama: command not found"

**Check:**
```bash
# On runner:
curl http://localhost:11434/api/tags

# Should return models
```

**Fix:**
```bash
# Install Ollama:
curl -fsSL https://ollama.com/install.sh | sh
ollama pull kimi-k2.5
```

---

### 6. GitHub API rate limit

**Symptom:** "API rate limit exceeded"

**Fix:**
- Use GitHub App instead of PAT
- Or reduce webhook frequency

---

## Debug Mode

Enable verbose logging:

```json
// In workflow-config.json
{
  "debug": true,
  "log_level": "verbose"
}
```

## Getting Help

1. Check n8n execution logs
2. Run validation script: `./scripts/validate-workflow.sh`
3. Check ARCHITECTURE.md for system overview
4. Review DETERMINISTIC_WORKFLOW.md for setup steps

## Emergency Rollback

If deployment breaks:

```bash
# On runner:
cd /var/www/app
git reset --hard HEAD~1
pm2 restart app
```
