# ScalpGuru V10 Changelog - Buy-Only Higher High TP Edition

## Release Date: February 2026

## 🆕 Production Release Updates (Feb 1, 2026)

### Features Removed for Production
1. **Monthly Trade Filter** - Removed completely
   - No longer needed as we don't restrict trading during specific months
   - All `EnableMonthSkip` and `Skip[Month]` inputs removed
   - Logic simplified in OnTick function
   
2. **Session Filtering** - Removed completely
   - Session hour restrictions no longer needed
   - All `EnableSessionFilter`, `SessionStartHour`, and `SessionEndHour` inputs removed
   - `CheckSessionFilter()` function removed

### Input Parameter Cleanup
All input parameters have been updated with clear, descriptive comments for production use:
- Trading Configuration: Better descriptions for account balance, risk settings
- Funded Account Protection: Clear explanation of limit behaviors
- Strategy Parameters: Updated comments to explain purpose of each setting
- Volatility-Adjusted Risk: Warning notes for extreme backtest-optimized values
- Visual Settings: Clear color and display options

### Order Placement Safety
Confirmed no duplicate order bugs:
- `inTrade` flag prevents multiple simultaneous positions
- `tradesToday` counter enforces daily trade limits
- `MaxTradesPerDay` check prevents over-trading
- Margin check prevents insufficient capital trades

## 📊 Backtest Results (12.6 Months, $2,000 Account)

| Metric | Value |
|--------|-------|
| **Test Period** | M15 (2025.01.06 - 2026.01.25) |
| **Net Profit** | $2,416.68 |
| **Profit Factor** | 2.41 |
| **Total Trades** | 158 |
| **Win Rate** | 44.94% (71 wins, 87 losses) |
| **Max Drawdown** | $177.10 (4.42%) ✅ |
| **Expected Payoff** | $15.30/trade |
| **Trades/Month** | ~12.5 |
| **Monthly Profit** | $191.80 ($2K), $575 ($6K scaled) |
| **Pass Timeline** | ~1.3 months (fastest!) |

### Performance Highlights
- ✅ **Safe Drawdown:** 4.42% stays well under 6% funded limit
- ✅ **High Profit Factor:** 2.41 indicates strong edge
- ✅ **Fastest Pass Time:** ~1.3 months to 10% profit target
- ⚡ **Lower Win Rate, Higher Payoff:** Quality over quantity approach
- 📈 **Consistent Monthly Returns:** $575/month on $6K account

---

## 🚀 Major Changes

### V10 is a **Complete Redesign** - Not Built on V9
V10 represents a fundamental shift in strategy from V9, implementing a **buy-only approach with Higher High (HH) swing-based take profit** targeting. This is NOT an incremental update from V9 but rather a parallel evolution with entirely different trade management logic.

## 🎯 Core Strategy Changes

### 1. Buy-Only Trading
- **Removed:** All sell trade logic completely eliminated
- **Rationale:** Markets tend to have an upward bias over time, and buying dips in gold (XAUUSD) has historically shown higher win rates than selling rallies
- **Focus:** Capitalizes on mean reversion when price dips below Keltner lower band

### 2. Higher High (HH) Swing-Based Take Profit
- **New TP Logic:** Instead of using trailing stops, V10 identifies the last major Higher High (swing high) on the chart and sets that as the take profit target
- **Swing Detection:** 
  - `SwingLookback = 319 bars` - Searches back 319 bars to find swing highs
  - `SwingWindow = 58 bars` - A high must be higher than 58 bars on each side to qualify as a swing high
- **Fallback:** If no valid HH is found or HH is below entry, TP is set at `entry + 2*ATR`
- **Reasoning:** Price tends to retrace to the top of the dip where selling originally started - the major HH point

### 3. Partial Profit at Halfway Point
- **Trigger:** When price reaches halfway between entry and the HH take profit target
- **Action:** Close 50% of the position (if lot size permits)
- **Benefit:** Locks in profits while keeping exposure for the full move to the HH target
- **Smart Sizing:** Automatically skips partial close if remaining position would be below broker minimum

### 4. NO Trailing Stop
- **Removed:** Traditional trailing stop logic completely eliminated
- **Replaced:** Position rides directly to the HH take profit target
- **Trade-off:** Allows for larger winners but requires price to reach the full HH target to exit remaining position

## ⚙️ Optimized Parameters

The following parameters have been optimized through extensive backtesting:

```
ATRPeriod = 133              (vs. 20 in V9)
KeltnerPeriod = 64           (vs. 20 in V9)
KeltnerMultiplier = 3.75     (vs. 2.5 in V9)
SL_ATRMultiplier = 7.54      (vs. 1.3 in V9)
BreakevenBuffer = 2.46       (vs. 0.3 pips in V9)
RSIPeriod = 128              (vs. 14 in V9)
RSI_Oversold = 53            (vs. 30 in V9)
RSI_Overbought = 645         (vs. 70 in V9 - effectively disabled)
```

### Why These Parameters?
- **Wider Keltner Bands:** Catches more extreme dips for better entry prices
- **Wider Stop Loss:** Accommodates the larger swings when targeting HH levels
- **Longer Periods:** Reduces noise and focuses on more significant market structure
- **Relaxed RSI:** More liberal entry criteria to capture opportunities

## 📊 Volatility-Adjusted Risk Management (Retained from V9)

V10 keeps V9's data-driven volatility adjustments but with modified multipliers:

```
VolLowRiskMultiplier = 6.36   (vs. 1.2 in V9)
VolHighRiskMultiplier = 7.28  (vs. 0.8 in V9)
HighVolStopMultiplier = 2.7   (vs. 0.9 in V9)
```

**Note:** These aggressive multipliers are likely optimized for the specific backtest period and should be used with caution in live trading.

## 🎨 Enhanced Visuals (Added from V9)

V10 now includes the full visual suite from V9:

### Info Panel
- Real-time status (Scanning, In Trade, Partial Taken)
- Symbol and timeframe display
- ATR and RSI values with color coding
- Trades today counter
- Floating P/L tracker
- Entry progress indicator
- Volatility regime display (Low/Normal/High)
- Risk multiplier adjustment indicator
- **NEW:** TP Type indicator showing "HH Swing"

### Keltner Channel Display
- Upper band (Crimson)
- Middle line (DodgerBlue, dotted)
- Lower band (LimeGreen)
- Current price level indicator
- Performance optimized - only redraws on new bars

### Trade Arrows
- Buy entry arrows marked on chart
- Timestamp-based naming for clean history

## 📈 Actual Performance (Backtested)

Based on backtest results with $2,000 starting balance over 12.6 months:

| Metric | V10 (Actual) | V9 | V8 |
|--------|-------------|-----|-----|
| **Strategy Type** | Buy-Only HH TP | Dual-Direction Data-Driven | Aggressive Dual-Direction |
| **TP Method** | Higher High Swing Target | Trailing Stop | Trailing Stop |
| **Net Profit** | $2,416.68 | ~$2,640-2,880 | $2,356.71 |
| **Profit Factor** | 2.41 | ~1.7-1.8 | 1.68 |
| **Win Rate** | 44.94% | 72-75% | ~70% |
| **Max Drawdown** | 4.42% ✅ | <6% ✅ | 8.82% ⚠️ |
| **Monthly Profit** | $575 ($6K) | $220-240 ($6K) | $196 ($6K) |
| **Trades/Month** | ~12.5 | 20-23 | ~18 |
| **Pass Timeline** | 1.3 months ⚡ | 2.5 months | 3 months |
| **Risk Profile** | Medium-High reward per trade | Balanced | Aggressive |

**V10 Advantages:**
- 🔥 Fastest profit target achievement (1.3 months)
- 💰 Highest monthly profit potential ($575 vs $220-240)
- ✅ Safe drawdown control (4.42%)
- 📊 Excellent profit factor (2.41)
- 🎯 Higher payoff per trade ($15.30)

**V10 Trade-offs:**
- Lower win rate (45% vs 72-75% in V9)
- Fewer trades per month (12.5 vs 20-23 in V9)
- Larger stop losses required (7.54x ATR)
- Works best in trending markets

## 🔄 Differences from V9

| Feature | V9 | V10 |
|---------|-----|-----|
| **Trade Direction** | Buy + Sell (with filters) | **Buy Only** |
| **Exit Strategy** | Trailing Stop (0.8-1.5x ATR) | **HH Swing Target + Partial** |
| **Partial Profit** | At 1:1 R:R | **At 50% to HH Target** |
| **Parameter Set** | Conservative (ATR 20, KC 20) | **Aggressive (ATR 133, KC 64)** |
| **Stop Loss** | 1.3x ATR (tight) | **7.54x ATR (wide)** |
| **Risk Multipliers** | 0.8-1.2x | **6.36-7.28x (extreme)** |
| **Optimal Hour Filter** | ✅ Enabled | ❌ Not in current version |
| **Philosophy** | Data-driven frequent trades | **Big swings, big targets** |

## ⚠️ Important Considerations

### 1. Aggressive Parameter Set
The V10 parameters (especially risk multipliers 6.36-7.28x) are significantly more aggressive than V9. These appear to be curve-fitted to a specific backtest period.

**Recommendation for Live Trading:**
- Start with V9's conservative multipliers (0.8-1.2x)
- Test the HH TP logic first with standard parameters
- Gradually adjust based on live performance

### 2. Wide Stop Losses
7.54x ATR stop loss is very wide and may:
- Require more capital per trade
- Expose you to larger drawdowns
- Work better in strongly trending markets
- Struggle in choppy/ranging conditions

### 3. No Trailing Protection
Without trailing stops, V10 is fully committed to reaching the HH target. This means:
- ✅ Larger winners when price reaches the HH
- ❌ May give back profits if price reverses before HH
- ❌ Less adaptive to changing market conditions

### 4. Backtesting vs Live Performance
The extreme parameters suggest this was heavily optimized for a specific dataset. Always:
- Forward test before going live
- Use smaller position sizes initially
- Monitor performance in different market conditions
- Consider reverting to V9 if drawdowns exceed expectations

## 🛡️ Funded Account Compatibility

V10 retains V9's funded account protection:
- Daily loss limit: 2.5%
- Max drawdown: 5.5%
- Profit target: 10%
- Auto-stop trading at limits

**Note:** The wide stop losses (7.54x ATR) may consume significant account equity per trade, potentially limiting the number of simultaneous trades you can take while staying within drawdown limits.

## 📝 Usage Recommendations

### Best Use Cases for V10:
1. **Strong trending markets** where HH targets are regularly achieved
2. **High volatility gold trading** where wide stops are necessary
3. **Longer-term swing trading** approach (wider targets take longer to hit)
4. **Traders who prefer fewer, larger winners** vs. many small wins

### Consider Using V9 Instead If:
1. You prefer **consistent smaller gains** with tighter risk control
2. Trading in **ranging/choppy markets** where wide stops get hit often
3. You need **faster capital turnover** (V9 closes trades faster with trailing)
4. **Funded account challenge** with strict drawdown rules (V9's tighter stops safer)

## 🔍 Key Takeaway

**V10 is NOT "V9 improved"** - it's a completely different strategy philosophy:
- **V9:** Adaptive, data-driven, defensive with trailing protection
- **V10:** Aggressive, swing-trading, offensive with big targets

Choose based on your:
- Risk tolerance
- Trading style (scalping vs. swing)
- Market conditions
- Account size and rules

## 📂 Files Updated
- `/src/ScalpGuruV10.mq5` - Complete rewrite with HH TP logic
- `/backtests/v10 backtest/` - Backtest results and reports
- This changelog

## 🎯 Next Steps
1. Review backtest results in `/backtests/v10 backtest/`
2. Compare with V8 and V9 results
3. Test on demo account before live trading
4. Monitor performance metrics
5. Adjust parameters based on your risk tolerance

---

**Created by go0ph | February 2026**
