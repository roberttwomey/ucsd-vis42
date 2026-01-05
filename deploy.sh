#!/bin/bash

# deploy.sh - Build Jekyll site and deploy to remote server
# Usage: ./deploy.sh [remote_user@remote_host:remote_path]
# Example: ./deploy.sh user@vis42.roberttwomey.com:/var/www/html
# Or set DEPLOY_TARGET environment variable

set -e  # Exit on error

# Get deployment target from argument or environment variable
DEPLOY_TARGET="${1:-${DEPLOY_TARGET}}"

if [ -z "$DEPLOY_TARGET" ]; then
    echo "Error: Deployment target not specified."
    echo ""
    echo "Usage: ./deploy.sh [user@host:path]"
    echo "   or: DEPLOY_TARGET=user@host:path ./deploy.sh"
    echo ""
    echo "Example: ./deploy.sh user@vis42.roberttwomey.com:/var/www/html"
    exit 1
fi

# Check if bundle is installed
if ! command -v bundle &> /dev/null; then
    echo "Error: Bundler is not installed."
    echo ""
    echo "Please install Bundler:"
    echo "  gem install bundler"
    exit 1
fi

# Check if Gemfile exists
if [ ! -f "Gemfile" ]; then
    echo "Error: Gemfile not found."
    echo "Please create a Gemfile with Jekyll dependencies."
    exit 1
fi

# Check if dependencies are installed, install if not
if ! bundle check &> /dev/null; then
    echo "Installing Jekyll dependencies..."
    bundle install
fi

echo "Building Jekyll site..."
bundle exec jekyll build

if [ ! -d "_site" ]; then
    echo "Error: Build directory '_site' not found. Build may have failed."
    exit 1
fi

echo ""
echo "Deploying to $DEPLOY_TARGET..."
echo ""

# Try rsync first, fallback to scp if rsync is not available
if command -v rsync &> /dev/null; then
    echo "Using rsync..."
    rsync -avz --delete \
        --exclude='.DS_Store' \
        --exclude='.git' \
        --exclude='.gitignore' \
        _site/ "$DEPLOY_TARGET/"
    echo ""
    echo "Deployment complete!"
    echo "Site should be live at: http://$(echo $DEPLOY_TARGET | cut -d: -f1 | cut -d@ -f2)"
elif command -v scp &> /dev/null; then
    echo "rsync not found, using scp (fallback)..."
    echo "Note: scp will copy files but won't delete remote files that don't exist locally."
    scp -r _site/* "$DEPLOY_TARGET/"
    echo ""
    echo "Deployment complete!"
    echo "Site should be live at: http://$(echo $DEPLOY_TARGET | cut -d: -f1 | cut -d@ -f2)"
else
    echo "Error: Neither rsync nor scp is available."
    echo "Please install rsync or scp to deploy."
    exit 1
fi

