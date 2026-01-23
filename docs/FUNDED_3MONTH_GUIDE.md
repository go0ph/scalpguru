# ScalpGuru V7 - 3-Month Funded Account Pass Guide

## 🎯 Objective: Pass $6,000 FundedNext Stellar 1-Step in 3 Months

This guide provides optimized settings to realistically pass the funded account challenge in approximately **3 months** while staying within risk limits.

## ⚠️ Important Disclaimers

1. Trading involves risk. Past backtest performance does not guarantee future results.
2. These settings push closer to the funded account limits - discipline is critical.
3. Always test on demo first before applying to a real funded challenge.

## 📊 The Math

| Metric | Calculation |
|--------|-------------|
| **Profit Target** | $600 (10% of $6,000) |
| **Target Timeline** | 3 months |
| **Required Monthly Profit** | $200/month |
| **V7 Default Performance** | ~$119/month (5 months to pass) |
| **V6 Performance** | ~$163/month (3.7 months to pass) |
| **Gap to Close** | Need +22-68% more profit |

## 🚀 Aggressive Settings for 3-Month Pass

### Settings to Change from V7 Defaults:

```
=== Trading Configuration ===
RiskPerTradePercent = 1.0      // Changed from 0.5 (doubles profit potential)
MaxTradesPerDay = 3            // Changed from 2 (50% more opportunities)

=== Funded Account Protection ===
DailyLossLimitPercent = 2.9    // Changed from 2.5 (closer to 3% limit)
MaxDrawdownPercent = 5.8       // Changed from 5.5 (closer to 6% limit)

=== Entry Filters ===
RSI_Oversold = 32              // Changed from 30 (slightly relaxed for more trades)
RequireKeltnerRetest = false   // Changed from true (more trade opportunities)

=== Keep These Settings ===
AllowSellTrades = false        // Sells remain disabled (underperforming)
EnableFundedMode = true        // Protection remains active
EnablePartialProfit = true     // Keep partial profit taking
```

### Full Settings File (Copy/Paste Ready):

```ini
; ScalpGuru V7 - Aggressive 3-Month Preset
; For FundedNext Stellar 1-Step $6K Challenge

[Trading Configuration]
MagicNumber=15137
AllowSellTrades=false
AllowBuyTrades=true
AccountBalance=6000.0
RiskPerTradePercent=1.0
EnableRiskPerTrade=true
MaxTradesPerDay=3
EnableMaxTradesPerDay=true

[Funded Account Protection]
EnableFundedMode=true
DailyLossLimitPercent=2.9
MaxDrawdownPercent=5.8
ProfitTargetPercent=10.0

[Strategy Parameters]
ATRPeriod=20
KeltnerPeriod=20
KeltnerMultiplier=2.5
SL_ATRMultiplier=1.3
TrailingStop_ATRMultiplier=0.8
BreakevenBuffer=0.3

[Profit Taking]
EnablePartialProfit=true
PartialProfitPercent=50.0
ExtendedTrailMultiplier=1.5

[Entry Filters]
EnableMomentumFilter=true
RSIPeriod=14
RSI_Oversold=32
RSI_Overbought=70
EnableVolumeFilter=false
EnableCandleConfirmation=true
RequireKeltnerRetest=false

[Session Filter]
EnableSessionFilter=false

[Day Filtering]
EnableDaySkip=true
SkipFriday=true
```

## 📈 Expected Performance with Aggressive Settings

| Metric | V7 Default | V7 Aggressive | Change |
|--------|------------|---------------|--------|
| Risk per trade | 0.5% | 1.0% | +100% |
| Max trades/day | 2 | 3 | +50% |
| Est. monthly profit | $119 | $200-220 | +70-85% |
| Time to pass | ~5 months | ~2.8-3 months | -40% |
| Max daily loss | 1% | 3% | Higher risk |

## ⚡ Risk Analysis

### Daily Loss Scenarios

| Scenario | Daily P/L | Outcome |
|----------|-----------|---------|
| Best case (3 wins) | +3% gain | +$60 to +$90 profit |
| Mixed (2 wins, 1 loss) | +1% gain | +$20 to +$50 profit |
| Bad day (1 win, 2 losses) | -1% loss | -$30 to -$60 loss |
| Worst case (3 losses) | -3% loss | -$180 loss (hits daily limit) |

### Weekly Expectations

- **Good week**: $150-200 profit (4 good days, 1 flat)
- **Average week**: $50-100 profit (mixed results)
- **Bad week**: $0 to -$100 (some losing days)

### Monthly Targets

| Month | Target | Running Total | Notes |
|-------|--------|---------------|-------|
| Month 1 | $200 | $200 | Building confidence |
| Month 2 | $200 | $400 | Staying consistent |
| Month 3 | $200 | $600 | 🎉 Challenge passed! |

## 🛡️ Risk Management Rules

### Daily Rules (CRITICAL)
1. **Stop trading after 2 consecutive losses** - Take the rest of the day off
2. **Stop trading if daily P/L reaches -2%** - Don't push to -3%
3. **Don't revenge trade** - Losses are part of the system
4. **Check balance before each trade** - Ensure you have room for potential loss

### Weekly Rules
1. **Target minimum 4 trading days** - Don't skip too many days
2. **Review weekend** - Analyze wins and losses
3. **If -5% for week, reduce to 2 trades/day next week**

### Monthly Checkpoints

| Checkpoint | Action |
|------------|--------|
| +$100 or more | ✅ On track, continue |
| $0 to +$100 | ⚠️ Slight concern, review entries |
| Negative | 🛑 Switch to conservative settings for 1 week |

## 🔄 Alternative: Conservative 4-Month Approach

If 3 months feels too aggressive, here's a safer alternative:

```
RiskPerTradePercent = 0.75    // Middle ground
MaxTradesPerDay = 3           // Keep extra opportunities
DailyLossLimitPercent = 2.25  // More buffer
RSI_Oversold = 31             // Slightly tighter
```

Expected: ~$160-175/month → 3.5-4 months to pass

## 📋 Pre-Launch Checklist

Before going live with aggressive settings:

- [ ] Backtest with these exact settings for at least 3 months of historical data
- [ ] Demo trade for minimum 2 weeks
- [ ] Calculate your personal risk tolerance
- [ ] Set up trade journal to track all trades
- [ ] Verify broker spread/commission on XAUUSD
- [ ] Confirm your broker allows EAs on funded accounts
- [ ] Have the EA send you alerts (email/push) for trade activity

## 🎓 Psychology Tips

1. **Trust the system** - Don't second-guess entries
2. **Accept losses** - They're built into the expected 27% loss rate
3. **Celebrate small wins** - Each profitable day compounds
4. **Take breaks** - After hitting daily target, consider stopping
5. **Weekend review** - Learn from the week, don't dwell

## 📞 Troubleshooting

### "I hit the daily limit"
- Stop trading for the day (EA should auto-stop)
- Review what happened - was it market conditions or system error?
- Return tomorrow with fresh mindset

### "No trades are triggering"
- Check if market is in strong trend (fewer mean reversion opportunities)
- Verify session times (avoid Asian session for gold)
- Confirm all filters aren't too restrictive

### "Win rate seems lower than expected"
- Ensure you're trading during optimal hours (London/NY)
- Check if volatility is abnormally high
- Consider tightening RSI back to 30

---

**Remember**: The goal is to pass the challenge, not to maximize every dollar. Consistency beats aggression.

*Good luck! 🍀*
