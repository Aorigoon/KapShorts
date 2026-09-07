with open('lib/screens/editor_screen.dart', 'r') as f:
    text = f.read()

import re

old_sheet = """  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Preview Mode', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 24,
            runSpacing: 24,
            children: ["""

new_sheet = """  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black87,
    builder: (context) => Container(
      padding: const EdgeInsets.only(top: 24, bottom: 40, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Preview Mode', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 32,
            runSpacing: 32,
            children: ["""

text = text.replace(old_sheet, new_sheet)

with open('lib/screens/editor_screen.dart', 'w') as f:
    f.write(text)
