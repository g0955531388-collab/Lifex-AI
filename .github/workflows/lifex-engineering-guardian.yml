name: Lifex-AI Engineering Guardian
description: Autonomous engineering agent for safe diagnosis, repair, testing, and maintenance of Lifex-AI.

on:
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write
  issues: read
  actions: read

jobs:
  guardian:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Verify Package ID & Structure
        run: |
          echo "Verifying Lifex-AI repository structure..."
          if [ ! -f "pubspec.yaml" ]; then
            echo "Error: pubspec.yaml not found!"
            exit 1
          fi
          echo "Package structure verified successfully."

      - name: Run Flutter Analyze & Tests
        run: |
          flutter pub get
          flutter analyze
          flutter test
