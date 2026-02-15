#!/bin/bash
# ============================================================================
# DEPLOY-MILA.sh — Professional OC-AI Deployment for Missy McDonald
# Single script deployment - Client #001
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "\n${BLUE}▸ $1${NC}"; }
print_ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
print_err()  { echo -e "${RED}  ✗ $1${NC}"; exit 1; }

echo ""
echo "============================================"
echo "  🤖 MILA DEPLOYMENT for Missy McDonald"
echo "  Client #001 - Professional Setup"
echo "============================================"
echo ""

# Credentials
AI_NAME="Mila"
CLIENT_NAME="Missy McDonald"
BOT_TOKEN="8442805517:AAH4HyaoLAXvgCKOrxo4_qugLWpFSGmXft0"
USER_ID="8169513720"
ANTHROPIC_KEY="sk-ant-api03-aaZ-8kVrIIgA18z6bMGpYo9Me5JMtcku_caFSOfjq61z3OjJBVyqrvtMhhzy18BtVTNkB0DOdA-4kgQHgAA"
BRAVE_KEY="BSA8N55_5Iy3H9X_h8IIxRUXLQuEfxu"
GMAIL="missy@mcdonald-net.com"

# -----------------------------------------------------------
# Step 1: Auto-Install Prerequisites
# -----------------------------------------------------------
print_step "Installing prerequisites"

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_ok "Homebrew installed"
else
    print_ok "Homebrew already installed"
fi

# Install Node.js if missing
if ! command -v node &> /dev/null; then
    print_step "Installing Node.js..."
    brew install node
    print_ok "Node.js installed"
fi
NODE_VERSION=$(node --version)
print_ok "Node.js $NODE_VERSION"

# Install OpenClaw if missing
if ! command -v openclaw &> /dev/null; then
    print_step "Installing OpenClaw..."
    npm install -g openclaw
    print_ok "OpenClaw installed"
fi
OPENCLAW_VERSION=$(openclaw --version)
print_ok "OpenClaw $OPENCLAW_VERSION"

# -----------------------------------------------------------
# Step 2: Create Directory Structure
# -----------------------------------------------------------
print_step "Setting up workspace"

# Create all directories at once
mkdir -p ~/.openclaw/workspace/memory
mkdir -p ~/.openclaw/logs

# Create identity files
echo "$AI_NAME" > ~/.openclaw/.ai-name
echo "$CLIENT_NAME" > ~/.openclaw/.client-name

print_ok "Workspace created"

# -----------------------------------------------------------
# Step 3: Create Configuration
# -----------------------------------------------------------
print_step "Creating OpenClaw configuration"

cat > ~/.openclaw/workspace/gateway.yaml << EOF
gateway:
  mode: local

apiKeys:
  anthropic: "$ANTHROPIC_KEY"
  braveSearch: "$BRAVE_KEY"

agents:
  defaults:
    model: "claude-3-5-sonnet-20241022"
    
channels:
  telegram:
    enabled: true
    botToken: "$BOT_TOKEN"
    allowedUsers: ["$USER_ID"]
EOF

print_ok "Configuration created"

# -----------------------------------------------------------
# Step 4: Create Mila's Personality Files
# -----------------------------------------------------------
print_step "Setting up Mila's personality"

cat > ~/.openclaw/workspace/SOUL.md << 'EOF'
# Mila - Missy's Personal AI Assistant

You are Mila, Missy's personal AI assistant. You live on her Mac Mini and help with daily tasks.

## Your Personality
- Warm and friendly, like talking to a helpful friend
- Professional but approachable
- Proactive - you anticipate needs
- Reliable and trustworthy

## Your Capabilities
- Email monitoring and summaries
- Calendar management and reminders
- Web research and information
- Weather and daily briefings
- General conversation and support

## Your Role
You're here to make Missy's life easier and more organized. Be helpful, be kind, and be yourself.
EOF

cat > ~/.openclaw/workspace/USER.md << 'EOF'
# About Missy

- **Name:** Missy McDonald  
- **Location:** McDonough, GA
- **Email:** missy@mcdonald-net.com
- **Timezone:** Eastern US (EST/EDT)
- **Married to:** Stacey (runs Overclocked Technologies)

You are her personal AI assistant named Mila.
EOF

cat > ~/.openclaw/workspace/IDENTITY.md << 'EOF'
# Mila - AI Assistant

- **Name:** Mila
- **Role:** Personal AI Assistant for Missy McDonald
- **Created by:** Overclocked Technologies
- **Client:** #001
EOF

print_ok "Personality configured"

# -----------------------------------------------------------
# Step 5: Start OpenClaw Gateway
# -----------------------------------------------------------
print_step "Starting OpenClaw gateway"

# Stop any existing gateway
openclaw gateway stop 2>/dev/null || true
sleep 2

# Start the gateway
openclaw gateway start

# Wait for startup
sleep 5

# Check status
if openclaw status | grep -q "unreachable"; then
    print_err "Gateway failed to start"
fi

print_ok "Gateway running"

# -----------------------------------------------------------
# Step 6: Test Bot Connection
# -----------------------------------------------------------
print_step "Testing Telegram bot"

# Test bot token
BOT_TEST=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe")
if [[ $BOT_TEST == *"ok\":true"* ]]; then
    print_ok "Bot token valid"
else
    print_err "Bot token invalid"
fi

print_ok "Bot connection verified"

# -----------------------------------------------------------
# Step 7: Final Instructions
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  🎉 MILA DEPLOYMENT COMPLETE!"
echo "============================================"
echo ""
echo "📱 NEXT STEPS:"
echo "1. Have Missy message the Mila bot on Telegram"
echo "2. She'll get a pairing code message"  
echo "3. Approve her with: openclaw pairing approve [user_id] [code]"
echo "4. She can then chat with Mila!"
echo ""
echo "✅ Client #001 (Missy McDonald) is ready!"
echo ""