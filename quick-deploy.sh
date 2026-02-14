#!/bin/bash

# OC-AI Quick Deployment for Mac Mini
# Run this on the target Mac Mini to download and deploy

echo "🚀 OC-AI Deployment Starting..."
echo "Downloading latest deployment scripts..."

# Download from GitHub
curl -L https://github.com/OCTechTron/oc-ai-deployment/archive/refs/heads/master.zip -o oc-ai-deployment.zip
unzip oc-ai-deployment.zip
cd oc-ai-deployment-master

echo "✅ Scripts downloaded. Ready to deploy!"
echo ""
echo "Next steps:"
echo "1. Run: ./01-macos-prep.sh"
echo "2. Run: ./02-openclaw-install.sh"
echo "3. Run: ./03-telegram-setup.sh"
echo "4. Run: ./04-gmail-setup.sh"
echo "5. Copy client config files"
echo "6. Run: ./06-harden.sh"
echo ""
echo "🤖 Client will be ready for AI interaction!"