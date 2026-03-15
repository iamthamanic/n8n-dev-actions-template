# System Architecture

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub                                   │
│  ┌─────────────┐    Push/PR    ┌─────────────┐                  │
│  │   Repository │ ────────────▶ │   Webhook   │                  │
│  └─────────────┘               └──────┬──────┘                  │
└───────────────────────────────────────┼─────────────────────────┘
                                        │
                                        │ POST /webhook/ci-xxx
                                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                         n8n                                     │
│  ┌─────────────┐    Trigger    ┌─────────────┐                  │
│  │   Webhook   │ ────────────▶ │  Workflow   │                  │
│  └─────────────┘               └──────┬──────┘                  │
│                                        │                         │
│  ┌─────────────────────────────────────┼─────────────────────┐  │
│  │                                     │                     │  │
│  ▼                                     ▼                     ▼  │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │
│ │ Checkout │─▶│  Build   │─▶│   Test   │─▶│  Report  │      │  │
│ └──────────┘  └──────────┘  └──────────┘  └──────────┘      │  │
│                                                           │  │
└───────────────────────────────────────────────────────────┼──┘
                                                            │
                                                            │ SSH
                                                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CI Runner (VPS)                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  /tmp/ci/repo-name/                                     │  │
│  │  ├── git clone / pull                                   │  │
│  │  ├── npm install / pip install                          │  │
│  │  ├── npm run build                                      │  │
│  │  ├── npm test                                           │  │
│  │  └── reports/                                           │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Services:                                              │  │
│  │  ├── Docker (for container builds)                     │  │
│  │  ├── Ollama (for AI code review)                        │  │
│  │  └── PM2 (for deployment)                              │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. GitHub Repository
- **Webhook**: Sends events (push, PR) to n8n
- **Status API**: Receives CI results
- **Branch Protection**: Can require CI to pass

### 2. n8n Workflow
- **Webhook Node**: Receives GitHub events
- **SSH Node**: Executes commands on runner
- **HTTP Node**: Reports status to GitHub
- **Telegram Node**: Sends notifications

### 3. CI Runner (VPS)
- **Workspace**: `/tmp/ci/repo-name/`
- **Tools**: git, node, python, docker
- **Services**: Ollama (for AI), PM2 (for deployment)

## Data Flow

```
1. Developer pushes code
   ↓
2. GitHub sends webhook to n8n
   ↓
3. n8n workflow starts
   ↓
4. SSH to runner, execute commands
   ↓
5. Report results to GitHub
   ↓
6. Notify via Telegram (optional)
```

## Security

- **SSH Keys**: Passwordless auth to runner
- **GitHub Token**: Scoped to repo only
- **Secrets**: Stored in n8n credentials
- **Isolation**: Each build in separate directory

## Scaling

- **Multiple Runners**: Distribute load
- **Queue**: n8n handles concurrent executions
- **Caching**: Dependencies cached on runner

## Monitoring

- **n8n Executions**: View all runs
- **GitHub Status**: See in PRs
- **Telegram**: Real-time notifications
- **Logs**: SSH output in n8n
