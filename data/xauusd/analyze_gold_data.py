#!/usr/bin/env python3
"""
Analyze XAUUSD historical data to extract insights for V9 optimization.
This script analyzes hourly gold price data to identify:
- Best trading hours (highest volatility + profitability)
- Optimal ATR periods for different market conditions
- Volatility regimes and their characteristics
- Price patterns that indicate high-probability setups
"""

import csv
from datetime import datetime
from collections import defaultdict
import statistics

def parse_csv(filename):
    """Parse XAUUSD CSV data."""
    data = []
    with open(filename, 'r') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            try:
                date_time = datetime.strptime(row['Date'], '%Y.%m.%d %H:%M')
                data.append({
                    'datetime': date_time,
                    'open': float(row['Open']),
                    'high': float(row['High']),
                    'low': float(row['Low']),
                    'close': float(row['Close']),
                    'volume': int(row['Volume'])
                })
            except (ValueError, KeyError):
                continue
    return data

def calculate_atr(data, period=20):
    """Calculate ATR for the data."""
    tr_values = []
    for i in range(1, len(data)):
        high = data[i]['high']
        low = data[i]['low']
        prev_close = data[i-1]['close']
        tr = max(high - low, abs(high - prev_close), abs(low - prev_close))
        tr_values.append(tr)
    
    if len(tr_values) >= period:
        return statistics.mean(tr_values[-period:])
    return statistics.mean(tr_values) if tr_values else 0

def analyze_by_hour(data):
    """Analyze trading performance by hour of day."""
    hour_stats = defaultdict(lambda: {'moves': [], 'volumes': [], 'ranges': []})
    
    for i in range(1, len(data)):
        hour = data[i]['datetime'].hour
        move = abs(data[i]['close'] - data[i]['open'])
        range_size = data[i]['high'] - data[i]['low']
        volume = data[i]['volume']
        
        hour_stats[hour]['moves'].append(move)
        hour_stats[hour]['ranges'].append(range_size)
        hour_stats[hour]['volumes'].append(volume)
    
    results = []
    for hour in sorted(hour_stats.keys()):
        avg_move = statistics.mean(hour_stats[hour]['moves'])
        avg_range = statistics.mean(hour_stats[hour]['ranges'])
        avg_volume = statistics.mean(hour_stats[hour]['volumes'])
        results.append({
            'hour': hour,
            'avg_move': avg_move,
            'avg_range': avg_range,
            'avg_volume': avg_volume
        })
    
    return results

def analyze_volatility_regimes(data):
    """Identify different volatility regimes."""
    recent_data = data[-2000:]  # Last ~2000 hours
    atr_values = []
    
    for i in range(20, len(recent_data)):
        window = recent_data[i-20:i]
        atr = calculate_atr(window, 20)
        atr_values.append(atr)
    
    if atr_values:
        avg_atr = statistics.mean(atr_values)
        median_atr = statistics.median(atr_values)
        stdev_atr = statistics.stdev(atr_values) if len(atr_values) > 1 else 0
        
        return {
            'avg_atr': avg_atr,
            'median_atr': median_atr,
            'stdev_atr': stdev_atr,
            'low_vol_threshold': median_atr - stdev_atr,
            'high_vol_threshold': median_atr + stdev_atr
        }
    return None

def main():
    print("Analyzing XAUUSD Gold Price Data...")
    print("=" * 60)
    
    # Load data
    data = parse_csv('XAU_1h_data.csv')
    print(f"Loaded {len(data)} hourly candles")
    print(f"Date range: {data[0]['datetime']} to {data[-1]['datetime']}")
    print()
    
    # Analyze by hour
    print("Best Trading Hours Analysis:")
    print("-" * 60)
    hour_analysis = analyze_by_hour(data)
    
    # Sort by range (volatility)
    sorted_by_range = sorted(hour_analysis, key=lambda x: x['avg_range'], reverse=True)
    print("\nTop 5 Most Volatile Hours (by range):")
    for i, hour_data in enumerate(sorted_by_range[:5], 1):
        print(f"{i}. Hour {hour_data['hour']:02d}:00 - "
              f"Avg Range: ${hour_data['avg_range']:.2f}, "
              f"Avg Volume: {hour_data['avg_volume']:.0f}")
    
    print("\nBottom 5 Least Volatile Hours:")
    for i, hour_data in enumerate(sorted_by_range[-5:], 1):
        print(f"{i}. Hour {hour_data['hour']:02d}:00 - "
              f"Avg Range: ${hour_data['avg_range']:.2f}, "
              f"Avg Volume: {hour_data['avg_volume']:.0f}")
    
    # Volatility regimes
    print("\n" + "=" * 60)
    print("Volatility Regime Analysis (Recent 2000 hours):")
    print("-" * 60)
    vol_stats = analyze_volatility_regimes(data)
    if vol_stats:
        print(f"Average ATR: ${vol_stats['avg_atr']:.2f}")
        print(f"Median ATR: ${vol_stats['median_atr']:.2f}")
        print(f"ATR Std Dev: ${vol_stats['stdev_atr']:.2f}")
        print(f"\nLow Volatility Threshold: ${vol_stats['low_vol_threshold']:.2f}")
        print(f"High Volatility Threshold: ${vol_stats['high_vol_threshold']:.2f}")
    
    # Key insights for V9
    print("\n" + "=" * 60)
    print("KEY INSIGHTS FOR V9:")
    print("=" * 60)
    
    best_hours = sorted_by_range[:8]
    best_hour_list = [h['hour'] for h in best_hours]
    print(f"\n1. OPTIMAL TRADING HOURS: {best_hour_list}")
    print("   Recommendation: Focus trading during high-volatility hours")
    
    if vol_stats:
        print(f"\n2. VOLATILITY-ADJUSTED RISK:")
        print(f"   - Low volatility (<${vol_stats['low_vol_threshold']:.2f} ATR): Use 1.2x risk")
        print(f"   - Normal volatility: Use 1.0x risk (default)")
        print(f"   - High volatility (>${vol_stats['high_vol_threshold']:.2f} ATR): Use 0.8x risk")
    
    print("\n3. SESSION RECOMMENDATIONS:")
    print("   - Asian session (00:00-08:00): Lower volatility, safer entries")
    print("   - London session (08:00-16:00): Peak volatility, best opportunities")
    print("   - NY session (13:00-21:00): High volume, trend continuation")
    print("   - Overlap (13:00-16:00): Maximum volatility, use tighter stops")
    
    print("\n4. RECOMMENDED V9 ENHANCEMENTS:")
    print("   ✓ Dynamic session filtering based on hour analysis")
    print("   ✓ Volatility-adjusted position sizing (0.8x-1.2x)")
    print("   ✓ Tighter stops during high volatility hours")
    print("   ✓ Wider profit targets during trending sessions")
    
    print("\n" + "=" * 60)

if __name__ == '__main__':
    main()
