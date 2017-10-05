#!/usr/bin/env python3

import fileinput
from re import match

colors = ["#ffad82", "#ffec82", "#b5ff96", "#9effe3", "#deafff", "#ffa8a8"]

def equiv_add(equiv, paradigm, case_to_add):
    added = False
    for class_of_eq in equiv:
        for elem in class_of_eq:
            if paradigm[elem] == paradigm[case_to_add]:
                class_of_eq.append(case_to_add)
                added = True
                break
        if added: break
    if not added:
        equiv.append([case_to_add])

def equiv_find(equiv, case_to_find):
    if not equiv:
        return -2
    for i in range(len(equiv)):
        for elem in equiv[i]:
            if elem == case_to_find:
                return i
    return -1

def print_head():
    print ('''<!DOCTYPE html>
<html lang="cs">
  <head>
    <meta charset="utf-8">
    <title>Vzory</title>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>''')

def print_info_table():
    print("<table class='bordered'>")
    print('<tr><th>Tense')
    print("<tr><td>Nominative<td>Accusative<td>Genitive")
    print("<tr><td>Instrumental<td>Dative<td>Locative")
    print("</table>")
    print("<p class='indented'>{}</p>".format("Vocative"))

def print_table_row(equiv, paradigm, tense, cases):
    print("<tr>", end='')
    for case in cases:
        class_of_eq = equiv_find(equiv, case + tense)
        if class_of_eq >= 0:
            print("<td bgcolor=" + colors[class_of_eq] + ">", end='')
        else:
            print("<td>", end='')
        print(paradigm[case + tense], end='')
    print()

def print_table(equiv, paradigm, tense):
    tense_str = {
        "s": "Singular",
        "d": "Dual",
        "p": "Plural"
    }
    print("<table class='bordered'>")
    print('<tr><th>' + tense_str[tense])
    print_table_row(equiv, paradigm, tense, ["N", "A", "G"])
    print_table_row(equiv, paradigm, tense, ["I", "D", "L"])
    print("</table>")
    if "V" + tense in paradigm.keys():
        class_of_eq = equiv_find(equiv, "V" + tense)
        if class_of_eq >= 0:
            print("<p class='indented'><span style=\"background-color: {}\">{}</span></p>".format(colors[class_of_eq], paradigm["V" + tense]))
        else:
            print("<p class='indented'>{}</p>".format(paradigm["Vs"]))

print_head()
print_info_table()
paradigm = {}
equiv_sg = []
equiv_du = []
equiv_pl = []

for line in fileinput.input():
    line = line.strip()
    line = line.replace('[edit]', '')
    if line.find('-', 0, 1) == 0: continue
    field = line.split("\t")
    if field and match(r'^[NAGIDLV]$', field[0]):
        paradigm[field[0] + "s"] = field[1].strip()
        paradigm[field[0] + "d"] = field[2].strip()
        paradigm[field[0] + "p"] = field[3].strip()
        equiv_add(equiv_sg, paradigm, field[0] + "s")
        equiv_add(equiv_du, paradigm, field[0] + "d")
        equiv_add(equiv_pl, paradigm, field[0] + "p")
    else:
        if "Ns" in paradigm.keys():
            equiv_sg = [class_of_eq for class_of_eq in equiv_sg if len(class_of_eq) > 1]
            equiv_du = [class_of_eq for class_of_eq in equiv_du if len(class_of_eq) > 1]
            equiv_pl = [class_of_eq for class_of_eq in equiv_pl if len(class_of_eq) > 1]

            print_table(equiv_sg, paradigm, "s")
            if paradigm["Nd"] != "-":
                print_table(equiv_du, paradigm, "d")
            if paradigm["Np"] != "-":
                print_table(equiv_pl, paradigm, "p")
        if match("\S", line):
            print("<h3>" + line + "</h3>")
        else:
            print()
        paradigm = {}
        equiv_sg = []
        equiv_du = []
        equiv_pl = []
print("</body></html>")
