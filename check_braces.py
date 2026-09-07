with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

count = 0
line_no = 1
for c in text:
    if c == '{': count += 1
    elif c == '}': count -= 1
    elif c == '\n': line_no += 1
    if count < 0:
        print(f"Extra closing brace at line {line_no}")
        break
if count > 0:
    print(f"Missing {count} closing braces")
elif count == 0:
    print("Braces match!")
