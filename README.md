# 📊 ScalpGuru - Advanced Keltner Channel Trading System

> **Professional MT5 Expert Advisor for XAUUSD Gold Trading**

---

## 🎯 QUICK NAVIGATION

<table>
<tr>
<td width="33%" valign="top">

### 📌 ACTIVE VERSIONS
- [V10 - HH Swing Trading](#-v10---buy-only-higher-high-tp-edition-newest)
- [V9 - Data-Driven](#-v9---data-driven-gold-trading-edition)
- [V8 - Aggressive Growth](#-v8---aggressive-3-month-pass-edition)

</td>
<td width="33%" valign="top">

### 📈 PERFORMANCE
- [Version Comparison](#-version-comparison-matrix)
- [Backtest Results](#-backtest-results)
- [Funded Account Guide](#-funded-account-setup)

</td>
<td width="33%" valign="top">

### 📚 DOCUMENTATION
- [Installation](#-installation)
- [Parameters](#-key-parameters)
- [Strategy Overview](#-strategy-overview)

</td>
</tr>
</table>

---

## 🏆 VERSION COMPARISON MATRIX

<table>
<tr>
<th>Feature</th>
<th>V10 HH Swing<br/>⭐ NEWEST</th>
<th>V9 Data-Driven<br/>🔬 SMART</th>
<th>V8 Aggressive<br/>⚡ FAST</th>
</tr>

<tr>
<td><strong>Strategy Type</strong></td>
<td>🎯 Buy-Only<br/>HH TP Targets</td>
<td>🔄 Dual Direction<br/>Data-Driven</td>
<td>🔄 Dual Direction<br/>Aggressive</td>
</tr>

<tr>
<td><strong>Exit Method</strong></td>
<td>📍 Higher High<br/>Swing Targets</td>
<td>📉 Trailing Stop<br/>Adaptive</td>
<td>📉 Trailing Stop<br/>Standard</td>
</tr>

<tr>
<td><strong>Risk Profile</strong></td>
<td>⚠️ High<br/>Wide stops, big targets</td>
<td>✅ Balanced<br/>Smart volatility adj</td>
<td>⚡ Aggressive<br/>Fast growth</td>
</tr>

<tr>
<td><strong>Best For</strong></td>
<td>• Trending markets<br/>• Swing traders<br/>• Big winner seekers</td>
<td>• All conditions<br/>• Funded challenges<br/>• Consistent growth</td>
<td>• Fast prop growth<br/>• Higher risk tolerance<br/>• 3-month targets</td>
</tr>

<tr>
<td><strong>Trades/Month</strong></td>
<td>~12-13</td>
<td>20-23</td>
<td>~18</td>
</tr>

<tr>
<td><strong>Win Rate</strong></td>
<td>~45%</td>
<td>72-75%</td>
<td>~70%</td>
</tr>

<tr>
<td><strong>Monthly Profit</strong></td>
<td>$575<br/>($6K account)</td>
<td>$220-240<br/>($6K account)</td>
<td>$196<br/>($6K account)</td>
</tr>

<tr>
<td><strong>Max Drawdown</strong></td>
<td>4.42%<br/>✅ Safe</td>
<td><6%<br/>✅ Safe</td>
<td>8.82%<br/>⚠️ Over limit</td>
</tr>

<tr>
<td><strong>Pass Timeline</strong></td>
<td>~1.3 months<br/>⚡ FASTEST</td>
<td>~2.5 months<br/>⚡ Fast</td>
<td>~3 months<br/>(DD risk)</td>
</tr>

<tr>
<td><strong>Status</strong></td>
<td>🔥 <strong>Latest</strong><br/>Feb 2026</td>
<td>⭐ <strong>Recommended</strong><br/>Best overall</td>
<td>⚠️ DD Warning<br/>Use with caution</td>
</tr>

<tr>
<td><strong>Documentation</strong></td>
<td><a href="docs/CHANGELOG_V10.md">📘 V10 Docs</a></td>
<td><a href="docs/CHANGELOG_V9.md">📘 V9 Docs</a></td>
<td><a href="docs/CHANGELOG_V8.md">📘 V8 Docs</a></td>
</tr>

<tr>
<td><strong>Backtest Results</strong></td>
<td><a href="backtests/v10 backtest/">📊 V10 Results</a></td>
<td><a href="backtests/v9 report/">📊 V9 Results</a></td>
<td><a href="backtests/v8 report/">📊 V8 Results</a></td>
</tr>
</table>

---

## 📋 DETAILED VERSION BOARDS

### 🔥 V10 - Buy-Only Higher High TP Edition [NEWEST]

<table>
<tr>
<td width="50%" valign="top">

#### ✨ HIGHLIGHTS
- 🎯 **Buy-Only Strategy** - No sell trades
- 📍 **HH Swing Targets** - TP at last major Higher High
- ⚡ **50% Partial at Halfway** - Lock profits early
- 📊 **No Trailing Stop** - Ride to full target
- 🎨 **Full V9 Visuals** - Enhanced info panel

#### ⚙️ OPTIMIZED FOR
```
✓ Trending gold markets
✓ Swing trading style
✓ Large reward per trade
✓ Patient traders
✓ High volatility periods
```

</td>
<td width="50%" valign="top">

#### 📊 KEY METRICS
```
ATR Period:        133 bars
Keltner Period:    64 bars
KC Multiplier:     3.75x
Stop Loss:         7.54x ATR
Swing Lookback:    319 bars
Swing Window:      58 bars
Risk per Trade:    1.0%
Max Trades/Day:    4
Trades/Month:      ~12-13
Win Rate:          ~45%
Profit Factor:     2.41
```

#### 📈 BACKTEST PERFORMANCE
```
Test Period:       12.6 months
Net Profit:        $2,416.68 ($2K)
Monthly Average:   $191.80 ($2K)
                   $575 ($6K account)
Max Drawdown:      4.42% ✅
Expected Payoff:   $15.30/trade
Pass Timeline:     ~1.3 months ⚡
```

#### ⚠️ IMPORTANT NOTES
```
⚠ Very wide stop losses (7.54x ATR)
⚠ Lower win rate (~45%) but higher payoff
⚠ Aggressive risk multipliers (backtested)
⚠ No trailing stop protection
✓ Best in strong uptrends
✓ Fastest profit target achievement
✓ Safe drawdown control (4.42%)
```

</td>
</tr>
</table>

**🔗 Files:** [`src/ScalpGuruV10.mq5`](src/ScalpGuruV10.mq5) | [📘 Full Changelog](docs/CHANGELOG_V10.md) | [📊 Backtest Results](backtests/v10%20backtest/)

---

### ⭐ V9 - Data-Driven Gold Trading Edition [RECOMMENDED]

<table>
<tr>
<td width="50%" valign="top">

#### ✨ HIGHLIGHTS
- 🔬 **20+ Years XAUUSD Data** - Built on 122K candles
- 📊 **Volatility-Adjusted Risk** - Dynamic 0.8-1.2x
- ⏰ **Optimal Hour Filter** - Trade best hours only
- 🎯 **Smart Stop Placement** - Volatility-aware SL
- 📉 **Adaptive Trailing** - Extends after partial profit

#### 🎯 WHY V9 IS BEST
```
✓ Data-driven decisions (20yr analysis)
✓ Safest drawdown control (<6%)
✓ Fastest funded pass (~2.5 months)
✓ Best win rate (72-75%)
✓ Adapts to market conditions
✓ Works in all market types
```

</td>
<td width="50%" valign="top">

#### 📊 PERFORMANCE TARGETS
```
Monthly Profit:    $220-240 (6K acct)
Time to Pass:      ~2.5 months
Trades/Month:      20-23
Win Rate:          72-75%
Max Drawdown:      <6% ✅
Sharpe Ratio:      Excellent
Expected Payoff:   $12-14/trade
```

#### 🔬 V9 DATA INSIGHTS
```
Best Hours:        14-19 GMT
Volatility Zones:
  Low:    <$5.58 ATR (↑ risk)
  Normal: $5.58-14.74 (→ standard)
  High:   >$14.74 (↓ risk, tighter SL)
```

</td>
</tr>
</table>

**🔗 Files:** [`src/ScalpGuruV9.mq5`](src/ScalpGuruV9.mq5) | [📘 Full Changelog](docs/CHANGELOG_V9.md) | [📊 vs V8 Analysis](docs/V8_VS_V9_ANALYSIS.md)

---

### ⚡ V8 - Aggressive 3-Month Pass Edition

<table>
<tr>
<td width="50%" valign="top">

#### ✨ HIGHLIGHTS
- ⚡ **Aggressive Growth** - 1% risk, 3 trades/day
- 🎯 **Enhanced Sell Logic** - Stochastic + Trend filter
- 📊 **Faster Profits** - ~$200/month target
- 🔄 **Dual Direction** - Buy + improved sell signals
- ⏱️ **3-Month Timeline** - Faster than V7

#### ⚠️ WARNING
```
⚠ Max Drawdown: 8.82%
⚠ EXCEEDS 6% funded limit!
⚠ Not recommended for strict prop firms
→ Consider V9 instead for safety
```

</td>
<td width="50%" valign="top">

#### 📊 METRICS
```
Monthly Profit:    ~$196 (6K acct)
Time to Pass:      ~3 months
Trades/Month:      ~18
Win Rate:          ~70%
Max Drawdown:      8.82% ⚠️
Risk per Trade:    1.0%
Max Trades/Day:    3
```

#### 🔧 PARAMETERS
```
ATR Period:        20
Keltner Period:    20
KC Multiplier:     2.5x
SL Multiplier:     1.3x
RSI Oversold:      32
Stochastic:        Enabled (80/20)
Trend Filter:      H1 EMA-50
```

</td>
</tr>
</table>

**🔗 Files:** [`src/ScalpGuruV8.mq5`](src/ScalpGuruV8.mq5) | [📘 Full Changelog](docs/CHANGELOG_V8.md)

---

## 📊 BACKTEST RESULTS

### Performance Comparison (12-Month XAUUSD M15)

| Version | Net Profit | Profit Factor | Win Rate | Max DD | Monthly Avg | Pass Time | Status |
|---------|-----------|---------------|----------|--------|-------------|-----------|--------|
| **V10** | $2,416.68 | 2.41 | ~45% | 4.42% ✅ | $575 | 1.3 mo | 🔥 **Fastest** |
| **V9** | ~$2,640-2,880 | ~1.7-1.8 | 72-75% | <6% ✅ | $220-240 | 2.5 mo | ⭐ **Consistent** |
| **V8** | $2,356.71 | 1.68 | ~70% | 8.82% ⚠️ | $196 | 3 mo | ⚠️ DD Risk |

**Account Size:** $6,000 starting balance (V10 tested on $2,000, scaled)  
**Symbol:** XAUUSD  
**Timeframe:** M15  
**Target:** $600 profit (10%)

### Visual Results

| Version | Equity Curve | Trade History | MAE/MFE |
|---------|-------------|---------------|---------|
| V10 | [📊 View](backtests/v10%20backtest/2.png) | [📈 History](backtests/v10%20backtest/2-hst.png) | [📉 Analysis](backtests/v10%20backtest/2-mfemae.png) |
| V9 | [📊 View](backtests/v9%20report/) | Available | Available |
| V8 | [📊 View](backtests/v8%20report/) | Available | Available |

---

## 💡 STRATEGY OVERVIEW

### Core Methodology: Keltner Channel Mean Reversion

```
📉 BUY SIGNAL (All Versions)
├─ Price dips below lower Keltner band
├─ Price reverses and closes above lower band  
├─ RSI confirms (not overbought)
├─ Volume/Session filters pass
└─ ✅ Open LONG position

📈 SELL SIGNAL (V8/V9 Only - NOT V10)
├─ Price extends above upper Keltner band
├─ Price reverses and closes below upper band
├─ RSI/Stochastic confirm (not oversold)
├─ Trend filter confirms (V8/V9)
└─ ✅ Open SHORT position

🎯 EXIT LOGIC
V10: TP at Higher High swing target + 50% partial at halfway
V9:  Trailing stop (0.8-1.5x ATR) + 50% partial at 1:1 RR
V8:  Trailing stop (0.8x ATR) + 50% partial at 1:1 RR
```

### Why It Works
- **Mean Reversion:** Markets tend to return to average after extreme moves
- **Keltner Bands:** Identify oversold/overbought conditions based on volatility
- **Risk Management:** Partial profits + stop loss protection
- **Adaptive:** V9 adjusts to volatility, V10 targets swing highs

---

## 🛡️ FUNDED ACCOUNT SETUP

### FundedNext Stellar 1-Step ($6K Challenge)

<table>
<tr>
<td width="33%" valign="top">

#### V10 Settings
```mql5
AccountBalance = 6000
EnableFundedMode = true
RiskPerTradePercent = 1.0
MaxTradesPerDay = 4
DailyLossLimitPercent = 2.5
MaxDrawdownPercent = 5.5
AllowSellTrades = false
```
**Timeline:** ~1.3 months ⚡  
**Monthly:** $575  
**Safety:** ✅ Best choice for speed

</td>
<td width="33%" valign="top">

#### V9 Settings ⭐
```mql5
AccountBalance = 6000
EnableFundedMode = true
RiskPerTradePercent = 1.0
MaxTradesPerDay = 4
EnableVolatilityAdjustedRisk = true
EnableOptimalHourFilter = true
DailyLossLimitPercent = 2.5
MaxDrawdownPercent = 5.5
```
**Timeline:** ~2.5 months  
**Monthly:** $220-240  
**Safety:** ✅ Best choice

</td>
<td width="33%" valign="top">

#### V8 Settings
```mql5
AccountBalance = 6000
EnableFundedMode = true
RiskPerTradePercent = 1.0
MaxTradesPerDay = 3
DailyLossLimitPercent = 2.9
MaxDrawdownPercent = 5.8
AllowSellTrades = false
```
**Timeline:** ~3 months  
**Monthly:** ~$196  
**Safety:** ⚠️ 8.82% DD risk

</td>
</tr>
</table>

### Protection Features
- ⚠️ **Warning at 80%** of daily limit
- 🛑 **Auto-stop** at daily limit (no new trades)
- ⚠️ **Warning at 90%** of max drawdown
- 🛑 **Emergency close** all positions at max drawdown
- 🎯 **Notification** when profit target reached

---

## 📦 INSTALLATION

### Quick Start

1. **Download EA**
   ```bash
   src/ScalpGuruV10.mq5  # Latest - HH Swing Trading
   src/ScalpGuruV9.mq5   # Recommended - Data-Driven
   src/ScalpGuruV8.mq5   # Alternative - Aggressive
   ```

2. **Install in MT5**
   - Copy `.mq5` file to `MQL5/Experts/` directory
   - Open MetaEditor (F4 in MT5)
   - Compile the EA (F7)

3. **Attach to Chart**
   - Open XAUUSD M15 chart
   - Drag EA from Navigator to chart
   - Configure parameters (see below)
   - Enable AutoTrading

4. **Verify Setup**
   - Check info panel appears (if enabled)
   - Verify Keltner bands display (if enabled)
   - Monitor Experts log for initialization messages

---

## ⚙️ KEY PARAMETERS

### Trading Configuration (All Versions)

| Parameter | V10 | V9 | V8 | Description |
|-----------|-----|----|----|-------------|
| **AccountBalance** | 6000 | 6000 | 6000 | For risk calculations |
| **RiskPerTradePercent** | 1.0% | 1.0% | 1.0% | Risk per trade |
| **MaxTradesPerDay** | 4 | 4 | 3 | Daily trade limit |
| **DailyLossLimit** | 2.5% | 2.5% | 2.9% | Max daily loss |
| **MaxDrawdown** | 5.5% | 5.5% | 5.8% | Max overall DD |

### Strategy Parameters

| Parameter | V10 | V9 | V8 | Purpose |
|-----------|-----|----|----|---------|
| **ATRPeriod** | 133 | 20 | 20 | ATR calculation |
| **KeltnerPeriod** | 64 | 20 | 20 | EMA period |
| **KeltnerMultiplier** | 3.75 | 2.5 | 2.5 | Band width |
| **SL_ATRMultiplier** | 7.54 | 1.3 | 1.3 | Stop loss distance |

### V10 Unique Parameters

```mql5
SwingLookback = 319          // Bars to search for HH
SwingWindow = 58             // Width for swing high detection
EnablePartialProfit = true   // Take 50% at halfway to TP
PartialProfitPercent = 50.0  // % to close at partial
```

### V9 Unique Parameters

```mql5
EnableVolatilityAdjustedRisk = true    // Dynamic 0.8-1.2x risk
EnableOptimalHourFilter = true          // Trade peak hours only
UseStrictOptimalHours = false           // Top 5 vs top 8 hours
EnableVolatilityAdjustedStops = true   // Tighter SL in high vol
```

---

## 📂 REPOSITORY STRUCTURE

```
scalpguru/
├── src/
│   ├── ScalpGuruV10.mq5         # 🔥 Latest - HH Swing TP
│   ├── ScalpGuruV9.mq5          # ⭐ Recommended - Data-Driven
│   └── ScalpGuruV8.mq5          # ⚡ Alternative - Aggressive
│
├── backtests/
│   ├── v10 backtest/            # V10 results & reports
│   ├── v9 report/               # V9 results & reports
│   └── v8 report/               # V8 results & reports
│
├── docs/
│   ├── CHANGELOG_V10.md         # 🔥 V10 detailed changelog
│   ├── CHANGELOG_V9.md          # V9 data-driven features
│   ├── CHANGELOG_V8.md          # V8 aggressive mode
│   ├── V8_VS_V9_ANALYSIS.md     # Comparison analysis
│   └── FUNDED_3MONTH_GUIDE.md   # Funded account guide
│
├── data/
│   └── xauusd/                  # 20+ years XAUUSD data
│       ├── XAU_1h_data.csv      # 122K hourly candles
│       └── analyze_gold_data.py # Analysis scripts
│
├── archive/                     # Old versions (V5-V7)
│   ├── src/                     # Archived source files
│   ├── docs/                    # Archived documentation
│   └── backtests/               # Archived backtest results
│
└── README.md                    # 📍 This file
```

---

## 🎓 CHOOSING THE RIGHT VERSION

### Decision Tree

```
START: What's your priority?
│
├─ ⚡ Fastest Profit Target (Higher Risk/Reward)
│  └─ 🔥 USE V10
│     • Fastest pass time (~1.3 months)
│     • Higher monthly profits
│     • Lower win rate but bigger wins
│     • Safe drawdown (4.42%)
│
├─ 🎯 Maximum Safety & Consistency
│  └─ ⭐ USE V9
│     • Best drawdown control
│     • Highest win rate (72-75%)
│     • Data-driven decisions
│     • Works in all conditions
│
├─ ⚡ Fastest Growth (High Risk)
│  └─ ⚠️ V8 (Drawdown Warning)
│     • Fast profit accumulation
│     • 8.82% max DD (over limit)
│     • Better for personal accounts
│     • Not for strict prop firms
│
└─ 🤔 Not Sure?
   └─ 🔥 TRY V10 FIRST
      • Fastest to profit target
      • Safe drawdown control
      • Higher profit potential
      • Fall back to V9 if needed
```

---

## 📊 COMPARISON TABLES

### Technical Specifications

| Feature | V10 | V9 | V8 |
|---------|-----|----|----|
| **MQL5 Version** | 10.00 | 9.00 | 8.00 |
| **Magic Number** | 15140 | 15139 | 15139 |
| **Code Lines** | ~1050 | ~1670 | ~1400 |
| **Indicators Used** | ATR, EMA, RSI | ATR, EMA, RSI, Stoch, H1 EMA | ATR, EMA, RSI, Stoch, H1 EMA |
| **Trade Directions** | Buy Only | Buy + Sell | Buy + Sell |
| **Visual Panel** | ✅ Enhanced | ✅ Full | ✅ Full |
| **Keltner Display** | ✅ Yes | ✅ Yes | ✅ Yes |

### Risk Management Comparison

| Feature | V10 | V9 | V8 |
|---------|-----|----|----|
| **Base Risk/Trade** | 1.0% | 1.0% | 1.0% |
| **Risk Adjustment** | 6.36-7.28x ⚠️ | 0.8-1.2x ✅ | None |
| **Stop Loss Width** | 7.54x ATR ⚠️ | 1.3x ATR ✅ | 1.3x ATR |
| **Trailing Stop** | ❌ None | ✅ Adaptive | ✅ Standard |
| **Partial Profit** | 50% at halfway to HH | 50% at 1:1 RR | 50% at 1:1 RR |
| **Max Loss Protection** | ✅ 1% | ✅ 1% | ✅ 1% |
| **Funded Protection** | ✅ Yes | ✅ Yes | ✅ Yes |

---

## 📞 SUPPORT & RESOURCES

### Documentation
- 📘 [V10 Changelog](docs/CHANGELOG_V10.md) - Complete V10 documentation
- 📘 [V9 Changelog](docs/CHANGELOG_V9.md) - V9 data-driven features
- 📘 [V8 Changelog](docs/CHANGELOG_V8.md) - V8 aggressive mode
- 📊 [V8 vs V9 Analysis](docs/V8_VS_V9_ANALYSIS.md) - Detailed comparison
- 💰 [Funded Account Guide](docs/FUNDED_3MONTH_GUIDE.md) - Prop firm setup

### Data & Analysis
- 📊 [XAUUSD Historical Data](data/xauusd/) - 20+ years of data
- 🔬 [Gold Analysis Scripts](data/xauusd/analyze_gold_data.py) - Python tools
- 📈 [Backtest Reports](backtests/) - All version results

### Community
- 🐛 **Issues:** [GitHub Issues](../../issues)
- 💬 **Discussions:** [GitHub Discussions](../../discussions)
- ⭐ **Star this repo** if you find it useful!

---

## ⚖️ LICENSE

Copyright © go0ph

---

## 🏁 QUICK ACTION ITEMS

### For New Users
1. ⭐ **Star this repository**
2. 📖 **Read** [V10 Changelog](docs/CHANGELOG_V10.md) (fastest version) or [V9 Changelog](docs/CHANGELOG_V9.md) (most consistent)
3. 📊 **Review** backtest results in [`backtests/v10 backtest/`](backtests/v10%20backtest/) or [`backtests/v9 report/`](backtests/v9%20report/)
4. 💾 **Download** `src/ScalpGuruV10.mq5` (fastest) or `src/ScalpGuruV9.mq5` (safest)
5. 🧪 **Test** on demo account first
6. ✅ **Start** with conservative settings

### For Existing Users
1. 🔥 **Check out** new V10 - [Changelog](docs/CHANGELOG_V10.md)
2. ⚠️ **Read** V10 warnings before switching
3. 🧪 **Test** V10 on demo first
4. 📊 **Compare** your results with backtests
5. 💬 **Share** feedback in Issues

### For Funded Traders
1. 🔥 **Use V10** for fastest pass time (1.3 months) with safe drawdown
2. ⭐ **Or use V9** for most consistent/highest win rate (2.5 months)
3. ⚙️ **Set** FundedMode = true
4. 📉 **Configure** daily/overall limits
5. 🎯 **Target** 1.3-2.5 month pass timeline
6. 📊 **Monitor** daily P/L and drawdown
7. ✅ **Verify** EA stops at limits

---

<div align="center">

## 🎯 RECOMMENDED STARTING POINT

### 🔥 Start with V10 - Fastest Pass Time Edition

**Why V10?**
✅ Fastest pass time (~1.3 months)  
✅ Highest monthly profit ($575)  
✅ Safe drawdown (4.42%)  
✅ Proven backtest results  
✅ Lower win rate but larger winners  

**Alternative: V9 for Consistency**
✅ Higher win rate (72-75%)  
✅ More trades per month  
✅ Works in all market conditions  
✅ Balanced risk/reward  

[📥 Download V10](src/ScalpGuruV10.mq5) | [📘 Read V10 Docs](docs/CHANGELOG_V10.md) | [📊 View V10 Results](backtests/v10%20backtest/)

**OR**

[📥 Download V9](src/ScalpGuruV9.mq5) | [📘 Read V9 Docs](docs/CHANGELOG_V9.md) | [📊 View V9 Results](backtests/v9%20report/)

---

**Built with 📊 by go0ph | Updated February 2026**

</div>
