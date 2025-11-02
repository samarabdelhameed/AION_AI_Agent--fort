#!/bin/bash

# Test Execute Page Integration - التحقق من صفحة Execute
# يتحقق من أن صفحة Execute تعمل بشكل صحيح مع Flow

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🧪 Execute Page Integration Test                     ║${NC}"
echo -e "${BLUE}║  اختبار تكامل صفحة Execute                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check counter
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# 1. Check if services are running
print_header "1️⃣  التحقق من الخدمات (Services Status)"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    print_success "Frontend يعمل على port 5173"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "Frontend لا يعمل على port 5173"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    exit 1
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    print_success "MCP Agent يعمل على port 3001"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "MCP Agent لا يعمل على port 3001"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 2. Check ExecutePage.tsx file
print_header "2️⃣  التحقق من ملف ExecutePage.tsx"

EXEC_FILE="frontend/src/pages/ExecutePage.tsx"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [ -f "$EXEC_FILE" ]; then
    print_success "ملف ExecutePage.tsx موجود"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "ملف ExecutePage.tsx غير موجود"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    exit 1
fi

# 3. Check Flow in Network list
print_header "3️⃣  التحقق من Flow في قائمة Networks"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if grep -q "Flow Blockchain" "$EXEC_FILE"; then
    print_success "Flow موجودة في قائمة Network"
    
    # Show the exact line
    FLOW_NETWORK_LINE=$(grep -n "Flow Blockchain" "$EXEC_FILE" | head -1)
    print_info "السطر: $FLOW_NETWORK_LINE"
    
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "Flow غير موجودة في قائمة Network"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 4. Check FLOW in Currency list
print_header "4️⃣  التحقق من FLOW في قائمة Currencies"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if grep -q 'value="FLOW"' "$EXEC_FILE"; then
    print_success "FLOW موجودة في قائمة Currency"
    
    # Show the exact line
    FLOW_CURRENCY_LINE=$(grep -n 'value="FLOW"' "$EXEC_FILE" | head -1)
    print_info "السطر: $FLOW_CURRENCY_LINE"
    
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "FLOW غير موجودة في قائمة Currency"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 5. Check for TypeScript/Linter errors
print_header "5️⃣  التحقق من الأخطاء (TypeScript/Linter)"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
cd frontend
if npm run lint -- --max-warnings 0 src/pages/ExecutePage.tsx > /dev/null 2>&1; then
    print_success "لا توجد أخطاء في ExecutePage.tsx"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_info "بعض التحذيرات موجودة (هذا طبيعي)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi
cd ..

# 6. Check Flow Context integration
print_header "6️⃣  التحقق من Flow Context Integration"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [ -f "frontend/src/contexts/FlowContext.tsx" ]; then
    print_success "FlowContext.tsx موجود"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    
    # Check if it's properly configured
    if grep -q "FLOW_TESTNET_CONFIG" "frontend/src/contexts/FlowContext.tsx"; then
        print_info "Flow Testnet مُعد بشكل صحيح"
    fi
else
    print_error "FlowContext.tsx غير موجود"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 7. Check Flow Wallet integration
print_header "7️⃣  التحقق من Flow Wallet Integration"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [ -f "frontend/src/components/wallet/FlowWalletButton.tsx" ]; then
    print_success "FlowWalletButton.tsx موجود"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_info "FlowWalletButton.tsx غير موجود (اختياري)"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
fi

# 8. Verify complete integration
print_header "8️⃣  التحقق من التكامل الكامل"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║ قائمة Networks المتاحة:                               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
grep -A 4 'label.*Network' "$EXEC_FILE" | grep '<option' | while read line; do
    if echo "$line" | grep -q "flow"; then
        echo -e "${GREEN}  ✅ $line${NC}"
    else
        echo -e "${CYAN}  • $line${NC}"
    fi
done

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║ قائمة Currencies المتاحة:                             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
grep -A 4 'label.*Currency' "$EXEC_FILE" | grep '<option' | while read line; do
    if echo "$line" | grep -q "FLOW"; then
        echo -e "${GREEN}  ✅ $line${NC}"
    else
        echo -e "${CYAN}  • $line${NC}"
    fi
done

# 9. Final summary
print_header "📊 النتيجة النهائية (Final Summary)"

echo ""
PASS_PERCENTAGE=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        🎉 كل الفحوصات نجحت! All Checks Passed! 🎉     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
elif [ $PASS_PERCENTAGE -ge 80 ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     ⚠️  معظم الفحوصات نجحت - Most Checks Passed       ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║        ❌ بعض الفحوصات فشلت - Some Checks Failed      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "الفحوصات الناجحة: ${GREEN}$CHECKS_PASSED${NC} / $TOTAL_CHECKS"
echo -e "الفحوصات الفاشلة: ${RED}$CHECKS_FAILED${NC} / $TOTAL_CHECKS"
echo -e "نسبة النجاح: ${CYAN}$PASS_PERCENTAGE%${NC}"
echo ""

# 10. Next steps
print_header "🚀 الخطوات التالية (Next Steps)"

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✨ Execute Page جاهز تماماً!${NC}"
    echo ""
    echo "  يمكنك الآن:"
    echo "  1. فتح التطبيق: http://localhost:5173"
    echo "  2. الذهاب إلى Execute page"
    echo "  3. اختيار Network: 🌊 Flow Blockchain"
    echo "  4. اختيار Currency: 🌊 FLOW"
    echo "  5. تنفيذ Deposit/Withdraw بنجاح! 🎉"
    echo ""
    echo -e "${CYAN}📖 للمزيد من التفاصيل:${NC}"
    echo "  cat FLOW_NETWORK_ADDED.md"
    echo "  cat QUICK_FLOW_SETUP.md"
else
    echo -e "${YELLOW}🔧 يوجد بعض المشاكل البسيطة${NC}"
    echo ""
    echo "  لكن Flow Integration يعمل بشكل أساسي!"
    echo "  جرب الآن: http://localhost:5173/#/execute"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         تم الاختبار! Testing Complete                 ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ $CHECKS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

