#!/bin/bash

# Test all language versions of Pocket Gallery website
BASE_URL="http://localhost:8080/pocket-gallery"

echo "Testing Pocket Gallery VuePress v2 Migration"
echo "=============================================="
echo ""

# Test function
test_page() {
  local url=$1
  local name=$2
  local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  
  if [ "$status" = "200" ]; then
    echo "✅ $name - OK"
    return 0
  else
    echo "❌ $name - FAILED (HTTP $status)"
    return 1
  fi
}

# Counter
total=0
passed=0

# Test all language home pages
languages=(
  "/:English"
  "/zh-hans/:简体中文"
  "/zh-hant/:繁體中文"
  "/ja-jp/:日本語"
  "/es/:Español"
  "/fr/:Français"
  "/de/:Deutsch"
  "/it/:Italiano"
  "/ko/:한국어"
)

echo "Testing Home Pages:"
echo "-------------------"
for lang in "${languages[@]}"; do
  IFS=':' read -r path name <<< "$lang"
  total=$((total + 1))
  if test_page "${BASE_URL}${path}" "$name Home"; then
    passed=$((passed + 1))
  fi
done

echo ""
echo "Testing English Pages:"
echo "----------------------"
pages=(
  "/release-notes/:Release Notes"
  "/faq/:FAQ"
  "/others/:Others"
)

for page in "${pages[@]}"; do
  IFS=':' read -r path name <<< "$page"
  total=$((total + 1))
  if test_page "${BASE_URL}${path}" "$name"; then
    passed=$((passed + 1))
  fi
done

echo ""
echo "Testing Chinese (Simplified) Pages:"
echo "------------------------------------"
for page in "${pages[@]}"; do
  IFS=':' read -r path name <<< "$page"
  total=$((total + 1))
  if test_page "${BASE_URL}/zh-hans${path}" "简体中文 - $name"; then
    passed=$((passed + 1))
  fi
done

echo ""
echo "=============================================="
echo "Results: $passed/$total tests passed"
if [ $passed -eq $total ]; then
  echo "✅ All tests passed!"
  exit 0
else
  echo "❌ Some tests failed"
  exit 1
fi
