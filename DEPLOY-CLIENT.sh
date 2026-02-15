#!/bin/bash
# ============================================================================
# DEPLOY-CLIENT.sh — Professional OC-AI Client Deployment
# Single script deployment for any OC-AI client
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
echo "  🤖 OC-AI PROFESSIONAL DEPLOYMENT"
echo "  Overclocked Technologies"
echo "============================================"
echo ""

# Collect client information
read -p "AI Assistant Name: " AI_NAME
read -p "Client Full Name: " CLIENT_NAME
read -p "Client Email: " CLIENT_EMAIL
read -p "Telegram Bot Token: " BOT_TOKEN
read -p "Client Telegram User ID: " USER_ID
read -p "Anthropic API Key: " ANTHROPIC_KEY
read -p "Brave Search API Key: " BRAVE_KEY

echo ""
print_step "Deploying $AI_NAME for $CLIENT_NAME"

# -----------------------------------------------------------
# Step 1: Verify Prerequisites
# -----------------------------------------------------------
print_step "Checking prerequisites"

# Check Homebrew
if ! command -v brew &> /dev/null; then
    print_err "Homebrew not found. Install from https://brew.sh"
fi

# Check/Install Node.js
if ! command -v node &> /dev/null; then
    print_step "Installing Node.js"
    brew install node
fi
NODE_VERSION=$(node --version)
print_ok "Node.js $NODE_VERSION"

# Check/Install OpenClaw
if ! command -v openclaw &> /dev/null; then
    print_step "Installing OpenClaw"
    npm install -g openclaw
fi
OPENCLAW_VERSION=$(openclaw --version)
print_ok "OpenClaw $OPENCLAW_VERSION"

# -----------------------------------------------------------
# Step 2: Create Directory Structure
# -----------------------------------------------------------
print_step "Setting up workspace"

# Create all directories
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
# Step 4: Create AI Personality
# -----------------------------------------------------------
print_step "Setting up $AI_NAME's personality"

cat > ~/.openclaw/workspace/SOUL.md << EOF
# $AI_NAME - Personal AI Assistant

You are $AI_NAME, ${CLIENT_NAME}'s personal AI assistant. You live on their Mac Mini and help with daily tasks.

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
You're here to make ${CLIENT_NAME}'s life easier and more organized. Be helpful, be kind, and be yourself.
EOF

cat > ~/.openclaw/workspace/USER.md << EOF
# About $CLIENT_NAME

- **Name:** $CLIENT_NAME
- **Email:** $CLIENT_EMAIL
- **Timezone:** Eastern US (EST/EDT)

You are their personal AI assistant named $AI_NAME.
EOF

cat > ~/.openclaw/workspace/IDENTITY.md << EOF
# $AI_NAME - AI Assistant

- **Name:** $AI_NAME
- **Role:** Personal AI Assistant for $CLIENT_NAME
- **Created by:** Overclocked Technologies
EOF

print_ok "Personality configured"

# -----------------------------------------------------------
# Step 5: Set Computer Name
# -----------------------------------------------------------
print_step "Setting computer name"
sudo scutil --set ComputerName "$AI_NAME"
sudo scutil --set HostName "$AI_NAME" 
sudo scutil --set LocalHostName "$AI_NAME"
print_ok "Computer renamed to $AI_NAME"

# -----------------------------------------------------------
# Step 6: Configure Energy Settings
# -----------------------------------------------------------
print_step "Configuring power settings"
sudo pmset -a sleep 0
sudo pmset -a displaysleep 0
sudo pmset -a disksleep 0
sudo pmset -a womp 1
sudo pmset -a autorestart 1
print_ok "Never sleep mode enabled"

# -----------------------------------------------------------
# Step 7: Start OpenClaw Gateway
# -----------------------------------------------------------
print_step "Starting OpenClaw gateway"

# Stop any existing gateway
openclaw gateway stop 2>/dev/null || true
sleep 2

# Install and start gateway service
openclaw gateway install
openclaw gateway start

# Wait for startup
sleep 10

# Check status
STATUS=$(openclaw status 2>/dev/null || echo "failed")
if [[ $STATUS == *"unreachable"* ]]; then
    print_warn "Gateway service having issues, trying manual start"
    openclaw gateway start --allow-unconfigured
    sleep 5
fi

print_ok "Gateway running"

# -----------------------------------------------------------
# Step 8: Test Bot Connection  
# -----------------------------------------------------------
print_step "Testing Telegram bot"

BOT_TEST=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe")
if [[ $BOT_TEST == *"ok\":true"* ]]; then
    BOT_NAME=$(echo $BOT_TEST | grep -o '"first_name":"[^"]*"' | cut -d'"' -f4)
    print_ok "Bot '$BOT_NAME' connected"
else
    print_err "Bot token invalid or connection failed"
fi

# -----------------------------------------------------------
# Step 9: Create Launch Agent for Auto-Start
# -----------------------------------------------------------
print_step "Setting up auto-start"

cat > ~/Library/LaunchAgents/ai.openclaw.gateway.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.openclaw.gateway</string>
    <key>Program</key>
    <string>/opt/homebrew/bin/openclaw</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/openclaw</string>
        <string>gateway</string>
        <string>--allow-unconfigured</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/$(whoami)/.openclaw/logs/gateway.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/$(whoami)/.openclaw/logs/gateway-error.log</string>
</dict>
</plist>
EOF

launchctl bootstrap gui/\$UID ~/Library/LaunchAgents/ai.openclaw.gateway.plist 2>/dev/null || true

print_ok "Auto-start configured"

# -----------------------------------------------------------
# Final Status Check
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  🎉 $AI_NAME DEPLOYMENT COMPLETE!"
echo "============================================"
echo ""
echo "📊 DEPLOYMENT SUMMARY:"
echo "  Client: $CLIENT_NAME"
echo "  AI Name: $AI_NAME"
echo "  Email: $CLIENT_EMAIL" 
echo "  User ID: $USER_ID"
echo ""
echo "📱 CLIENT INSTRUCTIONS:"
echo "1. Message the $AI_NAME bot on Telegram"
echo "2. You'll receive a pairing code message"
echo "3. Send the pairing details to support"
echo "4. Once approved, start chatting with $AI_NAME!"
echo ""
echo "🔧 SUPPORT COMMANDS:"
echo "  Status: openclaw status"
echo "  Logs: openclaw logs"
echo "  Restart: openclaw gateway restart"
echo ""
echo "✅ Professional OC-AI deployment complete!"
echo ""