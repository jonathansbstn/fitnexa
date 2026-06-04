import os

file_path = 'lib/screens/tab_profile.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

replacements = {
    'ðŸ“·': '📸',
    'âœ…': '✅',
    'ðŸ—‘': '🗑️',
    'ðŸŽ¯': '🎯',
    'ðŸ”¥': '🔥',
    'ðŸ’ª': '💪',
    'ðŸ †': '🏆',
    'ðŸŒŸ': '🌟',
    'ðŸš€': '🚀',
    'ðŸŽ‰': '🎉',
    'ðŸ“…': '📅',
    'ðŸŒ¿': '🌿',
    'ðŸ“‹': '📋',
    'ðŸ“ ': '📊',
    'ðŸŒ™': '🌙',
}

for bad, good in replacements.items():
    text = text.replace(bad, good)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)
print('Fixed emojis')
