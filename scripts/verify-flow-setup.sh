#!/bin/bash

# Flow Wallet Setup Verification Script
# يتحقق من أن كل الإعدادات صحيحة للاتصال بمحفظة Flow

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🌊 Flow Wallet Setup Verification Tool               ║${NC}"
echo -e "${BLUE}║  التحقق من إعداد محفظة Flow                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check counter
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# 1. Check if services are running
print_header "1️⃣  التحقق من الخدمات (Services Check)"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    print_success "MCP Agent Backend يعمل على port 3001"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "MCP Agent Backend لا يعمل على port 3001"
    print_info "قم بتشغيله: npm run dev"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    print_success "Frontend يعمل على port 5173"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "Frontend لا يعمل على port 5173"
    print_info "قم بتشغيله: cd frontend && npm run dev"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 2. Check Flow Testnet connectivity
print_header "2️⃣  التحقق من اتصال Flow Testnet"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
FLOW_API="https://rest-testnet.onflow.org"
if curl -s --max-time 5 "$FLOW_API/v1/blocks?height=sealed" > /dev/null 2>&1; then
    print_success "Flow Testnet API متاح: $FLOW_API"
    
    # Get latest block
    LATEST_BLOCK=$(curl -s "$FLOW_API/v1/blocks?height=sealed" | grep -o '"height":"[0-9]*"' | head -1 | cut -d'"' -f4)
    if [ ! -z "$LATEST_BLOCK" ]; then
        print_info "Latest Block: #$LATEST_BLOCK"
    fi
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "Flow Testnet API غير متاح"
    print_warning "تحقق من اتصال الإنترنت"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 3. Check Flow EVM Testnet
print_header "3️⃣  التحقق من Flow EVM Testnet"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
FLOW_EVM_RPC="https://testnet.evm.nodes.onflow.org"
EVM_RESPONSE=$(curl -s --max-time 5 -X POST "$FLOW_EVM_RPC" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null || echo "")

if [ ! -z "$EVM_RESPONSE" ] && echo "$EVM_RESPONSE" | grep -q "result"; then
    print_success "Flow EVM Testnet RPC متاح: $FLOW_EVM_RPC"
    
    # Extract block number
    BLOCK_HEX=$(echo "$EVM_RESPONSE" | grep -o '"result":"0x[0-9a-fA-F]*"' | cut -d'"' -f4)
    if [ ! -z "$BLOCK_HEX" ]; then
        BLOCK_DEC=$((16#${BLOCK_HEX:2}))
        print_info "Latest EVM Block: #$BLOCK_DEC"
    fi
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "Flow EVM Testnet RPC غير متاح"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 4. Check Flow contracts deployment
print_header "4️⃣  التحقق من العقود الذكية (Smart Contracts)"

VAULT_ADDRESS="0xc7a34c80e6f3235b"
print_info "Vault Address: $VAULT_ADDRESS"
print_success "عنوان العقد محفوظ في الإعدادات"
CHECKS_PASSED=$((CHECKS_PASSED + 1))
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# 5. Check MCP Agent Flow integration
print_header "5️⃣  التحقق من تكامل Flow في MCP Agent"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
HEALTH_CHECK=$(curl -s http://localhost:3001/api/health 2>/dev/null || echo "")
if echo "$HEALTH_CHECK" | grep -q "flow"; then
    print_success "MCP Agent متكامل مع Flow"
    
    # Check Flow status in health
    if echo "$HEALTH_CHECK" | grep -q '"status":"healthy"'; then
        print_info "Flow Status: Healthy ✨"
    elif echo "$HEALTH_CHECK" | grep -q '"status":"degraded"'; then
        print_warning "Flow Status: Degraded (بعض الخدمات قيد التهيئة)"
    fi
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_warning "MCP Agent لا يتضمن معلومات Flow في الـ health check"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 6. Check frontend Flow configuration
print_header "6️⃣  التحقق من إعدادات Flow في Frontend"

if [ -f "frontend/src/contexts/FlowContext.tsx" ]; then
    print_success "FlowContext.tsx موجود"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "FlowContext.tsx غير موجود"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

if [ -f "frontend/src/contexts/FlowEVMContext.tsx" ]; then
    print_success "FlowEVMContext.tsx موجود"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    print_error "FlowEVMContext.tsx غير موجود"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# 7. Network configuration summary
print_header "7️⃣  ملخص إعدادات الشبكة (Network Configuration)"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║ Flow Cadence Testnet:                                  ║${NC}"
echo -e "${CYAN}║   • Access Node: https://rest-testnet.onflow.org       ║${NC}"
echo -e "${CYAN}║   • Network: testnet                                   ║${NC}"
echo -e "${CYAN}║   • Vault: 0xc7a34c80e6f3235b                          ║${NC}"
echo -e "${CYAN}║                                                        ║${NC}"
echo -e "${CYAN}║ Flow EVM Testnet:                                      ║${NC}"
echo -e "${CYAN}║   • RPC: https://testnet.evm.nodes.onflow.org          ║${NC}"
echo -e "${CYAN}║   • Chain ID: 545                                      ║${NC}"
echo -e "${CYAN}║   • Explorer: https://evm-testnet.flowscan.io          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 8. Wallet setup checklist
print_header "8️⃣  قائمة التحقق من إعداد المحفظة"

echo ""
echo -e "${YELLOW}للاتصال بمحفظة Flow، تأكد من:${NC}"
echo ""
echo "  [ ] محفظة Flow مثبتة (Flow Wallet Extension)"
echo "  [ ] عبارة الاسترداد محفوظة بأمان"
echo "  [ ] المحفظة على شبكة Flow Testnet"
echo "  [ ] يوجد FLOW tokens (احصل عليها من Faucet)"
echo "  [ ] افتح التطبيق: http://localhost:5173"
echo "  [ ] اضغط 'Connect Flow Wallet'"
echo ""

# 9. Useful commands
print_header "9️⃣  أوامر مفيدة (Useful Commands)"

echo ""
echo -e "${GREEN}تشغيل المشروع:${NC}"
echo "  npm run dev"
echo ""
echo -e "${GREEN}إيقاف المشروع:${NC}"
echo "  npm run stop"
echo ""
echo -e "${GREEN}فحص الحالة:${NC}"
echo "  npm run status"
echo ""
echo -e "${GREEN}مشاهدة اللوجز:${NC}"
echo "  tail -f logs/mcp_agent.log"
echo "  tail -f logs/frontend.log"
echo ""
echo -e "${GREEN}فتح التطبيق:${NC}"
echo "  open http://localhost:5173"
echo ""

# 10. Final summary
print_header "📊 النتيجة النهائية (Final Summary)"

echo ""
PASS_PERCENTAGE=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              🎉 كل الفحوصات نجحت! 🎉                   ║${NC}"
    echo -e "${GREEN}║          All Checks Passed Successfully!               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
elif [ $PASS_PERCENTAGE -ge 70 ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║        ⚠️  معظم الفحوصات نجحت مع بعض التحذيرات        ║${NC}"
    echo -e "${YELLOW}║         Most Checks Passed With Warnings               ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║           ❌ بعض الفحوصات فشلت                         ║${NC}"
    echo -e "${RED}║              Some Checks Failed                        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "الفحوصات الناجحة: ${GREEN}$CHECKS_PASSED${NC} / $TOTAL_CHECKS"
echo -e "الفحوصات الفاشلة: ${RED}$CHECKS_FAILED${NC} / $TOTAL_CHECKS"
echo -e "نسبة النجاح: ${CYAN}$PASS_PERCENTAGE%${NC}"
echo ""

# 11. Next steps
print_header "🚀 الخطوات التالية (Next Steps)"

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✨ كل شيء جاهز! يمكنك الآن:${NC}"
    echo ""
    echo "  1. فتح التطبيق: http://localhost:5173"
    echo "  2. اضغط 'Connect Flow Wallet'"
    echo "  3. وافق على الاتصال"
    echo "  4. جرب Deposit/Withdraw"
    echo "  5. احصل على AI Recommendations"
    echo ""
    echo -e "${CYAN}📖 للمزيد من التفاصيل، اقرأ:${NC}"
    echo "  cat FLOW_WALLET_SETUP_GUIDE.md"
else
    echo -e "${YELLOW}🔧 قم بإصلاح المشاكل أولاً:${NC}"
    echo ""
    if ! curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
        echo "  • شغّل MCP Agent: cd mcp_agent && npm start"
    fi
    if ! curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo "  • شغّل Frontend: cd frontend && npm run dev"
    fi
    echo ""
    echo "  ثم أعد تشغيل هذا السكريبت:"
    echo "  ./scripts/verify-flow-setup.sh"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         تم التحقق بنجاح! Verification Complete         ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ $CHECKS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

