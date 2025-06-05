import csv
from Levenshtein import distance

def calculate_msd(s1, s2):
    return distance(s1, s2)

def calculate_adjusted_wpm(time_ms, typed_text, target_text):
    if not typed_text:
        return 0
    time_min = time_ms / 60000.0
    raw_wpm = (len(typed_text) / 5) / time_min if time_min > 0 else 0
    msd = calculate_msd(typed_text, target_text[:len(typed_text)])
    error_rate = msd / max(len(typed_text), 1)
    return max(0, raw_wpm * (1 - error_rate))

def analyze_csv(file_path):
    # Group rows by sentence
    data = {}
    with open(file_path, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 3:
                continue
            time_ms_str, typed_text, target_text = row
            time_ms = int(time_ms_str)
            if target_text not in data:
                data[target_text] = []
            data[target_text].append((time_ms, typed_text))

    # Print results for each sentence
    print(f"\nAnalysis for {file_path}:")
    for sentence, entries in data.items():
        final_time, final_text = entries[-1]
        final_msd = calculate_msd(final_text, sentence)
        final_wpm = calculate_adjusted_wpm(final_time, final_text, sentence)
        final_time_seconds = final_time / 1000.0
        print(f"Sentence: '{sentence}'")
        print(f"  Final typed text: '{final_text}'")
        print(f"  Time (seconds): {final_time_seconds:.2f}")
        print(f"  MSD: {final_msd}")
        print(f"  Adjusted WPM: {final_wpm:.2f}")

def main():
    # add more files here later!
    for csv_file in ["p1.csv", "p2.csv", "p3.csv", "p4.csv", "p5.csv", "p6.csv", "p7.csv", "p8.csv", "p9.csv", "p10.csv", "p11.csv", "p12(prof-williams).csv"]:
        file_path = f"{csv_file}"
        analyze_csv(file_path)

if __name__ == "__main__":
    main()

# for the 20 trials:
#The average wpm for p9.csv was 11.07 with MSD of 0.
#The average wpm for p12(prof-williams).csv was 11.7 with a MSD of 1.