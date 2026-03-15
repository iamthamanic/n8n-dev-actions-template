# Security Guidelines

## Credentials

### SSH Keys
- **Never commit** private keys to git
- Use **passwordless** keys for automation
- Rotate keys every **90 days**
- Store in n8n credentials, not in config files

### GitHub Token
- Use **fine-grained** PAT (Personal Access Token)
- Scope: `repo` only
- Expiration: **90 days**
- Never log or expose token

### Telegram Bot
- Keep bot token **private**
- Use dedicated bot for CI
- Don't share chat ID publicly

## Network Security

### Webhook Security
- Use **HTTPS** only
- Validate webhook signature (GitHub secret)
- IP whitelist GitHub IPs (optional)

### SSH Security
- Disable root login: `PermitRootLogin no`
- Use key auth only: `PasswordAuthentication no`
- Firewall: Only allow SSH from n8n server

## Runner Security

### Isolation
- Each build in **separate directory**
- Clean up after build: `rm -rf /tmp/ci/repo`
- Don't share secrets between builds

### Permissions
- Runner user: **non-root** (recommended)
- Sudo access: Only for specific commands
- File permissions: `600` for sensitive files

## Secrets Management

### n8n Credentials
```
Settings → Credentials → Add Credential
- Name: descriptive (e.g., "github-token-easyploy")
- Type: correct type (OAuth2, SSH, etc.)
- Value: never shown in UI after save
```

### Environment Variables
```json
// In workflow-config.json
{
  "secrets": {
    "api_key": {
      "source": "env",
      "key": "API_KEY"
    }
  }
}
```

## Audit Trail

### Logging
- All SSH commands logged in n8n
- GitHub status updates logged
- Telegram notifications for failures

### Retention
- n8n executions: 30 days
- GitHub status: Permanent
- Telegram: Until deleted

## Incident Response

### If compromised:
1. Revoke GitHub token immediately
2. Rotate SSH keys
3. Check runner for unauthorized access
4. Review n8n execution logs
5. Notify team via Telegram

## Best Practices

1. **Principle of least privilege**
2. **Regular rotation** of credentials
3. **Monitor** execution logs
4. **Test** security in staging first
5. **Document** all access

## Compliance

- **GDPR**: No personal data in logs
- **SOC 2**: Audit trail required
- **ISO 27001**: Access control

---

**Last updated:** 2026-03-15  
**Version:** 1.0.0
