import os
import re

dir_path = r"c:\laragon\www\project-tiga\mobile_flutter\lib"

# Fix 1: .withOpacity -> .withValues
opacity_regex = re.compile(r'\.withOpacity\(([^)]+)\)')

for root, _, files in os.walk(dir_path):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = opacity_regex.sub(r'.withValues(alpha: \1)', content)
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                    print(f"Fixed opacity in {file}")

# Fix 2: Remove unused fields in mjpeg_live_view.dart
mjpeg_path = os.path.join(dir_path, "presentation", "widgets", "mjpeg_live_view.dart")
if os.path.exists(mjpeg_path):
    with open(mjpeg_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'\s*static const List<int> _jpegStart = \[0xFF, 0xD8\];', '', content)
    content = re.sub(r'\s*static const List<int> _jpegEnd = \[0xFF, 0xD9\];', '', content)
    with open(mjpeg_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed mjpeg_live_view.dart unused fields")

# Fix 3: Remove unused gradeText in qc_state_provider.dart
qc_path = os.path.join(dir_path, "providers", "qc_state_provider.dart")
if os.path.exists(qc_path):
    with open(qc_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'\s*String gradeText = "";', '', content)
    content = content.replace('print(', 'debugPrint(')
    if 'import \'package:flutter/foundation.dart\';' not in content and 'debugPrint(' in content:
        content = "import 'package:flutter/foundation.dart';\n" + content
    with open(qc_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed qc_state_provider.dart")

# Fix 4: Fix print in laravel_api_service.dart
api_path = os.path.join(dir_path, "services", "laravel_api_service.dart")
if os.path.exists(api_path):
    with open(api_path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace('print(', 'debugPrint(')
    if 'import \'package:flutter/foundation.dart\';' not in content and 'debugPrint(' in content:
        content = "import 'package:flutter/foundation.dart';\n" + content
    with open(api_path, 'w', encoding='utf-8') as f:
        f.write(content)
        print("Fixed laravel_api_service.dart")

