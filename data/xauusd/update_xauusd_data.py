#!/usr/bin/env python3
"""
Script to fetch and update XAUUSD historical data.
This ensures our backtests and strategy optimizations use the most current data.

Data source: Kaggle dataset (nvn01/xauusd-gold-price-tracker-2004present)
Reference: https://github.com/nvn01/XAUUSD-auto-update-kaggle-dataset

The data is automatically updated daily on Kaggle via the GitHub Actions workflow
in the reference repository.

Usage:
    python update_xauusd_data.py           # Update data files (requires kaggle API)
    python update_xauusd_data.py --analyze # Update and run analysis
    python update_xauusd_data.py --constants # Generate V10 constants from existing data
"""

import os
import sys
import subprocess
import argparse
import zipfile
from datetime import datetime
from pathlib import Path

# Configuration
KAGGLE_DATASET = "nvn01/xauusd-gold-price-tracker-2004present"
DATA_FILES = ["XAU_1h_data.csv", "XAU_1d_data.csv"]

def get_script_dir():
    """Get the directory where this script is located."""
    return Path(__file__).parent.resolve()

def check_kaggle_api():
    """Check if Kaggle API is available and configured."""
    try:
        result = subprocess.run(
            ["kaggle", "--version"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            return True
    except FileNotFoundError:
        pass
    
    # Check if kaggle is installed as a Python package
    try:
        import kaggle
        return True
    except ImportError:
        pass
    
    return False

def download_from_kaggle(destination_dir):
    """Download dataset from Kaggle."""
    print(f"Downloading from Kaggle: {KAGGLE_DATASET}")
    
    if not check_kaggle_api():
        print("ERROR: Kaggle API not available.")
        print("To install: pip install kaggle")
        print("Then configure: https://www.kaggle.com/docs/api")
        print("")
        print("Alternatively, manually download from:")
        print(f"  https://www.kaggle.com/datasets/{KAGGLE_DATASET}")
        return False
    
    try:
        # Download dataset
        result = subprocess.run(
            ["kaggle", "datasets", "download", "-d", KAGGLE_DATASET, "-p", str(destination_dir), "--unzip"],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("  -> Download successful")
            return True
        else:
            print(f"  -> Error: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"  -> Exception: {e}")
        return False

def get_data_date_range(filepath):
    """Extract the date range from a CSV data file."""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            if len(lines) < 2:
                return None, None
            
            # Skip header, get first and last data lines
            first_line = lines[1].strip().split(';')
            last_line = lines[-1].strip().split(';')
            
            first_date = first_line[0].split(' ')[0] if first_line else None
            last_date = last_line[0].split(' ')[0] if last_line else None
            
            return first_date, last_date
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None, None

def update_data():
    """Download latest XAUUSD data files."""
    data_dir = get_script_dir()
    
    print("=" * 60)
    print("XAUUSD Data Update Script")
    print(f"Data directory: {data_dir}")
    print("=" * 60)
    
    # Show existing data info
    for filename in DATA_FILES:
        filepath = data_dir / filename
        if filepath.exists():
            start, end = get_data_date_range(filepath)
            lines = sum(1 for _ in open(filepath))
            print(f"\nExisting {filename}: {start} to {end} ({lines:,} rows)")
    
    # Try to download from Kaggle
    print("\n" + "-" * 60)
    success = download_from_kaggle(data_dir)
    
    if success:
        print("\n" + "-" * 60)
        print("Updated data info:")
        for filename in DATA_FILES:
            filepath = data_dir / filename
            if filepath.exists():
                start, end = get_data_date_range(filepath)
                lines = sum(1 for _ in open(filepath))
                print(f"  {filename}: {start} to {end} ({lines:,} rows)")
    else:
        print("\nUsing existing data files (download failed or Kaggle not configured)")
        # Still return True if we have existing data
        all_exist = all((data_dir / f).exists() for f in DATA_FILES)
        if all_exist:
            print("Existing data files are available for analysis.")
            return True
    
    print("\n" + "=" * 60)
    return success

def run_analysis():
    """Run the data analysis script after updating."""
    script_dir = get_script_dir()
    analysis_script = script_dir / "analyze_gold_data.py"
    
    if not analysis_script.exists():
        print(f"Analysis script not found: {analysis_script}")
        return False
    
    print("\n" + "=" * 60)
    print("Running XAUUSD Data Analysis...")
    print("=" * 60 + "\n")
    
    # Change to data directory and run analysis
    original_dir = os.getcwd()
    os.chdir(script_dir)
    
    try:
        result = subprocess.run(
            [sys.executable, str(analysis_script)],
            capture_output=False
        )
        return result.returncode == 0
    finally:
        os.chdir(original_dir)

def generate_constants():
    """Analyze data and generate MQL5 constants for V10."""
    import csv
    import statistics
    
    script_dir = get_script_dir()
    hourly_file = script_dir / "XAU_1h_data.csv"
    
    if not hourly_file.exists():
        print("Hourly data file not found. Please ensure data files exist.")
        return None
    
    print("\n" + "=" * 60)
    print("Generating V10 Data-Driven Constants...")
    print("=" * 60)
    
    # Parse data
    data = []
    with open(hourly_file, 'r') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            try:
                data.append({
                    'datetime': row['Date'],
                    'open': float(row['Open']),
                    'high': float(row['High']),
                    'low': float(row['Low']),
                    'close': float(row['Close']),
                    'volume': int(row['Volume'])
                })
            except (ValueError, KeyError):
                continue
    
    print(f"Loaded {len(data):,} hourly candles")
    
    if len(data) < 100:
        print("Not enough data for analysis")
        return None
    
    # Calculate ATR values (20 period)
    atr_values = []
    for i in range(20, len(data)):
        tr_sum = 0
        for j in range(i-20, i):
            high = data[j]['high']
            low = data[j]['low']
            prev_close = data[j-1]['close'] if j > 0 else data[j]['open']
            tr = max(high - low, abs(high - prev_close), abs(low - prev_close))
            tr_sum += tr
        atr_values.append(tr_sum / 20)
    
    if not atr_values:
        print("Not enough data to calculate ATR")
        return None
    
    # Calculate volatility thresholds (percentiles)
    atr_sorted = sorted(atr_values)
    low_vol_threshold = atr_sorted[int(len(atr_sorted) * 0.25)]  # 25th percentile
    high_vol_threshold = atr_sorted[int(len(atr_sorted) * 0.75)]  # 75th percentile
    
    avg_atr = statistics.mean(atr_values)
    median_atr = statistics.median(atr_values)
    stdev_atr = statistics.stdev(atr_values)
    
    # Analyze by hour
    hour_stats = {}
    for i in range(1, len(data)):
        try:
            hour = int(data[i]['datetime'].split(' ')[1].split(':')[0])
            range_val = data[i]['high'] - data[i]['low']
            
            if hour not in hour_stats:
                hour_stats[hour] = []
            hour_stats[hour].append(range_val)
        except (ValueError, IndexError):
            continue
    
    # Find optimal trading hours (highest average range)
    hour_avg_range = {h: statistics.mean(ranges) for h, ranges in hour_stats.items() if ranges}
    sorted_hours = sorted(hour_avg_range.items(), key=lambda x: x[1], reverse=True)
    
    optimal_hours = [h[0] for h in sorted_hours[:8]]  # Top 8 hours
    strict_optimal_hours = [h[0] for h in sorted_hours[:5]]  # Top 5 hours
    
    # Get date range
    date_range = get_data_date_range(hourly_file)
    
    # Generate constants
    constants = {
        'VOL_LOW_THRESHOLD': round(low_vol_threshold, 2),
        'VOL_HIGH_THRESHOLD': round(high_vol_threshold, 2),
        'AVG_ATR': round(avg_atr, 2),
        'MEDIAN_ATR': round(median_atr, 2),
        'STDEV_ATR': round(stdev_atr, 2),
        'OPTIMAL_HOURS': optimal_hours,
        'STRICT_OPTIMAL_HOURS': strict_optimal_hours,
        'DATA_DATE_RANGE': date_range,
        'CANDLES_ANALYZED': len(data)
    }
    
    print(f"\nVolatility Thresholds (based on {len(data):,} candles):")
    print(f"  Low volatility threshold (25th %ile): ${constants['VOL_LOW_THRESHOLD']}")
    print(f"  High volatility threshold (75th %ile): ${constants['VOL_HIGH_THRESHOLD']}")
    print(f"  Average ATR: ${constants['AVG_ATR']}")
    print(f"  Median ATR: ${constants['MEDIAN_ATR']}")
    print(f"  Std Dev ATR: ${constants['STDEV_ATR']}")
    print(f"\nOptimal Trading Hours (top 8): {constants['OPTIMAL_HOURS']}")
    print(f"Strict Optimal Hours (top 5): {constants['STRICT_OPTIMAL_HOURS']}")
    print(f"\nData range: {constants['DATA_DATE_RANGE'][0]} to {constants['DATA_DATE_RANGE'][1]}")
    
    # Write constants to a file for reference
    constants_file = script_dir / "v10_constants.txt"
    with open(constants_file, 'w') as f:
        f.write(f"// V10 Data-Driven Constants\n")
        f.write(f"// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"// Data range: {constants['DATA_DATE_RANGE'][0]} to {constants['DATA_DATE_RANGE'][1]}\n")
        f.write(f"// Candles analyzed: {constants['CANDLES_ANALYZED']:,}\n\n")
        f.write(f"// Volatility thresholds based on 20-period ATR percentiles\n")
        f.write(f"#define VOL_LOW_THRESHOLD {constants['VOL_LOW_THRESHOLD']}    // 25th percentile ATR\n")
        f.write(f"#define VOL_HIGH_THRESHOLD {constants['VOL_HIGH_THRESHOLD']}   // 75th percentile ATR\n")
        f.write(f"#define AVG_ATR {constants['AVG_ATR']}\n")
        f.write(f"#define MEDIAN_ATR {constants['MEDIAN_ATR']}\n")
        f.write(f"\n// Optimal hours (top 8 by volatility): {constants['OPTIMAL_HOURS']}\n")
        f.write(f"// Strict optimal hours (top 5): {constants['STRICT_OPTIMAL_HOURS']}\n")
        f.write(f"\n// Use these in IsOptimalTradingHour() function:\n")
        f.write(f"// Standard mode hours: {', '.join(str(h) for h in constants['OPTIMAL_HOURS'])}\n")
        f.write(f"// Strict mode hours: {', '.join(str(h) for h in constants['STRICT_OPTIMAL_HOURS'])}\n")
    
    print(f"\nConstants written to: {constants_file}")
    
    return constants

def main():
    parser = argparse.ArgumentParser(
        description="Update XAUUSD historical data for ScalpGuru backtesting"
    )
    parser.add_argument(
        '--analyze', '-a',
        action='store_true',
        help='Run data analysis after updating'
    )
    parser.add_argument(
        '--constants', '-c',
        action='store_true',
        help='Generate V10 data-driven constants'
    )
    parser.add_argument(
        '--all',
        action='store_true',
        help='Update data, run analysis, and generate constants'
    )
    parser.add_argument(
        '--skip-download',
        action='store_true',
        help='Skip downloading, just analyze existing data'
    )
    
    args = parser.parse_args()
    
    # Update data unless skipped
    if not args.skip_download:
        update_data()
    
    # Run optional steps
    if args.analyze or args.all:
        run_analysis()
    
    if args.constants or args.all:
        generate_constants()
    
    print("\nDone!")
    sys.exit(0)

if __name__ == '__main__':
    main()
