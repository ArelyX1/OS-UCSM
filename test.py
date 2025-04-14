import pandas as pd

def test():
    # Create a sample DataFrame
    data = {
        'A': [1, 2, 3],
        'B': [4, 5, 6],
        'C': [7, 8, 9]
    }
    df = pd.DataFrame(data)
    # Print the DataFrame
    print("DataFrame:")
    print(df)

test()