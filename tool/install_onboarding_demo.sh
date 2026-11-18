#!/bin/bash
# Install a separate simulator app without changing Runner's production identity.
set -euo pipefail
cd "$(dirname "$0")/.."
device_id="${1:-booted}"
flutter build ios --simulator --debug --no-pub -t tool/onboarding_demo.dart
python3 - <<'PY'
from pathlib import Path
import plistlib
import shutil
source = Path('build/ios/iphonesimulator/Runner.app')
target = Path('build/onboarding-demo/AsteriaOnboarding.app')
if target.exists():
    shutil.rmtree(target)
shutil.copytree(source, target, symlinks=True)
p = target / 'Info.plist'
with p.open('rb') as f:
    info = plistlib.load(f)
info['CFBundleIdentifier'] = 'com.toolsafesolutions.asteria.onboardingdemo'
info['CFBundleDisplayName'] = 'Астерия Онбординг'
info['CFBundleName'] = 'Астерия Онбординг'
# The demo must not claim the main app's payment-return deep link.
info.pop('CFBundleURLTypes', None)
with p.open('wb') as f:
    plistlib.dump(info, f)
for localized in target.glob('*.lproj/InfoPlist.strings'):
    with localized.open('rb') as f:
        values = plistlib.load(f)
    values['CFBundleDisplayName'] = 'Астерия Онбординг'
    with localized.open('wb') as f:
        plistlib.dump(values, f)
PY
codesign --force --sign - build/onboarding-demo/AsteriaOnboarding.app
xcrun simctl install "$device_id" build/onboarding-demo/AsteriaOnboarding.app
