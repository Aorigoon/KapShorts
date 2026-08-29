import sys

with open('lib/main.dart', 'r') as f:
    lines = f.readlines()

# Add imports around line 47
# Remove AppColors: lines 48-58 (index 47-57)
# Remove VideoProject, ProjectsController, providers: lines 116-317 (index 115-316)

new_lines = []
for i, line in enumerate(lines):
    if i == 47: # before AppColors
        new_lines.append("import 'core/app_colors.dart';\n")
        new_lines.append("import 'core/models/video_project.dart';\n")
        new_lines.append("import 'core/controllers/projects_controller.dart';\n")
        new_lines.append("import 'core/providers.dart';\n\n")
        continue
    
    # Skip AppColors
    if 47 <= i <= 57:
        continue
        
    # Skip VideoProject to providers
    if 115 <= i <= 316:
        continue
        
    new_lines.append(line)

with open('lib/main.dart', 'w') as f:
    f.writelines(new_lines)
