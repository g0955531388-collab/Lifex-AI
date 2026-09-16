# Lifex-AI

منظومة Lifex-AI الصحية. التطبيق في `Lifex-AI/lifex_ai`.

## التشغيل المحلي

```powershell
cd Lifex-AI/lifex_ai
$env:JAVA_TOOL_OPTIONS = "-Duser.language=en -Duser.country=US"
flutter pub get
flutter run
```

## البناء على GitHub

كل دفع إلى `main` يشغّل GitHub Actions: تحليل، اختبارات، ثم APK للتجربة.
يمكن تشغيل البناء يدوياً من تبويب Actions → Lifex-AI → Run workflow.
