# manually produce a ranking system for both sides 

# first case:
girl_rank1 = {
    "1": ["a", "c", "b", "d"],
    "2": ["d","c","b","a"],
    "3": ["b","a","d","c"],
    "4": ["c","d","a","b"]
}
boy_rank1 = {
    "a": ["3","4","2","1"],
    "b": ["1","4","2","3"],
    "c": ["2","3","1","4"],
    "d": ["3","1","2","4"]
}

# second case:
girl_rank2 = {"A": ["D","E","F"], "B": ["D","E","F"], "C": ["D","E","F"]}
boy_rank2 = {"D": ["B","A","C"], "E": ["B","A","C"], "F": ["A","B","C"]}

# third case:
boy_rank3 = {"X": ["A","B","C"], "Y": ["B", "A", "C"], "Z": ["A","B","C"]}
girl_rank3 = {"A": ["Y","X","Z"], "B": ["X","Y","Z"], "C": ["X","Y","Z"]}

#fourth case:
boy_rank4 = {
    "A": ["O","M","N","L","P"],
    "B": ["P","N","M", "L","O"],
    "C": ["M", "P", "L", "O","N"],
    "D": ["P","M","O","N","L"],
    "E": ["O","L","M","N","P"]
}
girl_rank4 = {
    "L": ["D","B","E","C","A"],
    "M": ["B","A","D","C","E"],
    "N": ["A","C","E","D","B"],
    "O": ["D","A","C","B","E"],
    "P": ["B","E","A","C","D"]
}

